//
//  FluentFirebirdDatabase.swift
//
//
//  Created by Ugo Cottin on 15/03/2021.
//

public struct FluentFirebirdDatabase {
	public let database: FirebirdDatabase
	public let context: DatabaseContext
	public let configuration: FirebirdDatabaseConfiguration
	public let inTransaction: Bool
}

extension FluentFirebirdDatabase: Database {
	public func execute(query: DatabaseQuery, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
		let expression = SQLQueryConverter(delegate: FirebirdConverterDelegate()).convert(query)
		
		let database = FirebirdSQLDatabase(database: self.database)
		
		let (sql, binds) = database.serialize(expression)
		
		do {
			let results = self.database.query(sql, try binds.map { try database.encoder.encode($0) })
			return results.map { results in
				for row in results.rows {
					onOutput(FirebirdDatabaseOutput(row: row, decoder: database.decoder))
				}
			}
		} catch {
			return self.eventLoop.makeFailedFuture(error)
		}
	}
	
	public func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
		print(schema)
		fatalError("unsupported")
//		return self.eventLoop.makeSucceededVoidFuture()
	}
	
	public func execute(enum: DatabaseEnum) -> EventLoopFuture<Void> {
		print(`enum`)
		fatalError("unsupported")
//		return self.eventLoop.makeSucceededVoidFuture()
	}
	
	public func transaction<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		guard !self.inTransaction else {
			return closure(self)
		}
		
		return self.database.withConnection { conn in
			conn.startTransaction(on: conn).flatMap { transaction in
				let db = FluentFirebirdDatabase(
					database: conn,
					context: self.context,
					configuration: self.configuration,
					inTransaction: true)
				
				return closure(db).flatMap { result in
					conn.commitTransaction(transaction).map { _ in
						result
					}
					.flatMapError { error in
						conn.rollbackTransaction(transaction).flatMapThrowing { _ in
							throw error
						}
					}
				}
			}
		}
	}
	
	public func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.database.withConnection { connection in
			closure(FluentFirebirdDatabase(
						database: self.database,
						context: self.context,
						configuration: self.configuration,
						inTransaction: self.inTransaction))
		}
	}
}

private struct FirebirdDatabaseOutput: DatabaseOutput {
	let row: FirebirdRow
	let decoder: FirebirdDecoder
	
	func schema(_ schema: String) -> DatabaseOutput {
		return _SchemaDatabaseOutput(output: self, schema: schema)
	}
	
	func contains(_ key: FieldKey) -> Bool {
		return self.row.values.keys.contains(self.columnName(key))
	}
	
	func decodeNil(_ key: FieldKey) throws -> Bool {
		if let data = self.row.values[self.columnName(key)] {
			return data.value == nil
		}
		
		return true
	}
	
	func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T where T : Decodable {
		let column = self.columnName(key)
		
		guard let data = self.row.values[column] else {
			fatalError("no field")
		}
		
		return try self.decoder.decode(T.self, from: data)
	}
	
	var description: String { row.values.description }
	
	func columnName(_ key: FieldKey) -> String {
		switch key {
			case .id:
				return "id"
			case .aggregate:
				return key.description
			case .string(let name):
//				var components = name.split(separator: "_")
//				components.removeFirst()
//				return components.joined(separator: "_").uppercased()
				return name.uppercased()
			case .prefix( _, let key):
				return self.columnName(key)
		}
	}
}

private struct _SchemaDatabaseOutput: DatabaseOutput {
	let output: DatabaseOutput
	let schema: String
	
	var description: String {
		self.output.description
	}
	
	func schema(_ schema: String) -> DatabaseOutput {
		self.output.schema(schema)
	}
	
	func contains(_ key: FieldKey) -> Bool {
		self.output.contains(self.key(key))
	}
	
	func decodeNil(_ key: FieldKey) throws -> Bool {
		try self.output.decodeNil(self.key(key))
	}
	
	func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T
	where T: Decodable
	{
		try self.output.decode(self.key(key), as: T.self)
	}
	
	private func key(_ key: FieldKey) -> FieldKey {
		.prefix(.string(self.schema + "_"), key)
	}
}

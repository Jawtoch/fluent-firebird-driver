//
//  FluentFirebirdDatabase.swift
//
//
//  Created by Ugo Cottin on 15/03/2021.
//

public struct FluentFirebirdDatabase {
	public let database: FirebirdNIODatabase
	public let context: DatabaseContext
	public let inTransaction: Bool
}

extension FluentFirebirdDatabase: Database {
	public func execute(query: DatabaseQuery, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
		let expression = SQLQueryConverter(delegate: FirebirdConverterDelegate()).convert(query)
		
		let sqlDatabase = FirebirdSQLDatabase(database: self.database)
			
		return sqlDatabase.execute(sql: expression) { sqlRow in
			if let row = sqlRow as? FirebirdSQLRow {
				onOutput(FirebirdDatabaseOutput(row: row.row, decoder: sqlDatabase.decoder))
			}
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
		
		return self.database.withTransaction { conn in
			let db = FluentFirebirdDatabase(database: conn, context: self.context, inTransaction: true)
			return closure(db)
		}
	}
	
	public func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.database.withConnection { connection in
			closure(FluentFirebirdDatabase(
						database: self.database,
						context: self.context,
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

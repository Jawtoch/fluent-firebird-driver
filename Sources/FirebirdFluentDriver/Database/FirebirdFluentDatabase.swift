import FluentKit
import Firebird
import FluentSQL
import FirebirdSQL

public struct FirebirdFluentDatabase {
	
	public let database: FirebirdDatabase
	
	public let context: DatabaseContext

	public let inTransaction: Bool
	
	public var converterDelegate: SQLConverterDelegate = FirebirdSQLConverterDelegate()
	
	public var decoder: FirebirdDecoder
}

private extension FirebirdFluentDatabase {
	
	func execute(sql query: SQLExpression, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
		let sqlDatabase = self.database.sql(decoder: self.decoder)
		
		return sqlDatabase.execute(sql: query) { row in
			guard let sqlRow = row as? FirebirdSQLRow else {
				return
			}
			
			let output = FirebirdDatabaseOutput(row: sqlRow)
			onOutput(output)
		}
	}
	
	func execute(sql query: SQLExpression) -> EventLoopFuture<Void> {
		let sqlDatabase = self.database.sql(decoder: self.decoder)
		
		return sqlDatabase.execute(sql: query) { _ in }
	}
	
}

extension FirebirdFluentDatabase: Database {
		
	public func execute(query: DatabaseQuery, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
		let converter = SQLQueryConverter(delegate: self.converterDelegate)
		let expression = converter.convert(query)
		
		return self.execute(sql: expression, onOutput: onOutput)
	}
	
	public func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
		let converter = SQLSchemaConverter(delegate: self.converterDelegate)
		let expression = converter.convert(schema)
		
		return self.execute(sql: expression)
	}
	
	public func execute(enum: DatabaseEnum) -> EventLoopFuture<Void> {
		self.eventLoop.makeFailedFuture(FirebirdFluentDatabaseError.notSupported)
	}
	
	public func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.database.withConnection { database in
			let db = FirebirdFluentDatabase(database: database,
											context: self.context,
											inTransaction: self.inTransaction,
											decoder: self.decoder)
			return closure(db)
		}
	}
	
	public func transaction<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.database.withTransaction { database in
			let db = FirebirdFluentDatabase(database: database,
											context: self.context,
											inTransaction: true,
											decoder: self.decoder)
			return closure(db)
		}
	}
	
}

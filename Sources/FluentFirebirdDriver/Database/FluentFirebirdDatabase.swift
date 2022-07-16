import Firebird
import FirebirdSQL
import FluentSQL

public struct FluentFirebirdDatabase {
	
	public let database: FirebirdDatabase
	
	public let context: DatabaseContext

	public let inTransaction: Bool
	
	public var converterDelegate: SQLConverterDelegate = FirebirdSQLConverterDelegate()
	
}

private extension FluentFirebirdDatabase {
	
	func execute(sql query: SQLExpression, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
		let sqlDatabase = self.database.sql()
		
		return sqlDatabase.execute(sql: query) { row in
			guard let sqlRow = row as? FirebirdSQLRow else {
				return
			}
			
			let output = FirebirdDatabaseOutput(row: sqlRow)
			onOutput(output)
		}
	}
	
	func execute(sql query: SQLExpression) -> EventLoopFuture<Void> {
		self.execute(sql: query) { _ in }
	}
	
}

extension FluentFirebirdDatabase: Database {
		
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
		self.eventLoop.makeFailedFuture(FluentFirebirdDatabaseError.operationNotSupported)
	}
	
	public func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.database.withConnection { database in
			let db = FluentFirebirdDatabase(database: database,
											context: self.context,
											inTransaction: self.inTransaction)
			return closure(db)
		}
	}
	
	public func transaction<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.database.withTransaction { database in
			let db = FluentFirebirdDatabase(database: database,
											context: self.context,
											inTransaction: true)
			return closure(db)
		}
	}
	
}

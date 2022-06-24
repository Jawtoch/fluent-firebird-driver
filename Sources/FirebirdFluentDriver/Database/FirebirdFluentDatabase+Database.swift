import FirebirdSQL
import FluentKit
import FluentSQL

public extension FirebirdSQLRow {
	
	func databaseOutput() -> DatabaseOutput {
		FirebirdDatabaseOutput(row: self)
	}
	
}

public protocol AsyncDatabase: Database {
	
	func execute(
		query: DatabaseQuery,
		onOutput: @escaping (DatabaseOutput) -> ()
	) async throws
	
	func execute(
		schema: DatabaseSchema
	) async throws
	
	func execute(
		enum: DatabaseEnum
	) async throws
	
	func transaction<T>(
		_ closure: (Database) async throws -> T
	) async throws -> T
	
	func withConnection<T>(
		_ closure: (Database) async throws -> T
	) async throws -> T
}

public extension AsyncDatabase {
	
	func execute(query: DatabaseQuery, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
		self.eventLoop.performWithTask {
			try await self.execute(query: query, onOutput: onOutput)
		}
	}
	
	func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
		self.eventLoop.performWithTask {
			try await self.execute(schema: schema)
		}
	}
	
	func execute(enum: DatabaseEnum) -> EventLoopFuture<Void> {
		self.eventLoop.performWithTask {
			try await self.execute(enum: `enum`)
		}
	}
	
	func transaction<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.eventLoop.performWithTask {
			try await self.transaction { database async throws -> T in
				try await closure(database).get()
			}
		}
	}
	
	func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.eventLoop.performWithTask {
			try await self.withConnection { database async throws -> T in
				try await closure(database).get()
			}
		}
	}
}

extension FirebirdFluentDatabase: AsyncDatabase {
	
	public func withConnection<T>(_ closure: (Database) async throws -> T) async throws -> T {
		try await self.database.withConnection { connection in
			let db = FirebirdFluentDatabase(database: connection,
											context: self.context,
											inTransaction: self.inTransaction)
			return try await closure(db)
		}
	}
	
	
	public func transaction<T>(_ closure: (Database) async throws -> T) async throws -> T {
		guard !self.inTransaction else {
			return try await closure(self)
		}
		
		return try await self.database.withTransaction { transaction in
			let db = FirebirdFluentDatabase(database: self.database,
											context: self.context,
											inTransaction: true)
			return try await closure(db)
		}
	}
	
	public func execute(enum: DatabaseEnum) async throws {
		fatalError()
	}
	
	public func execute(schema: DatabaseSchema) async throws {
		fatalError()
	}
	
	public func execute(query: DatabaseQuery, onOutput: @escaping (DatabaseOutput) -> ()) async throws {
		let delegate = FirebirdSQLConverterDelegate()
		let converter = SQLQueryConverter(delegate: delegate)
		let expression = converter.convert(query)
		
		let sqlDatabase = self.database.sql(decoder: .init(), on: self.eventLoop)
		try await sqlDatabase.execute(sql: expression) { row in
			guard let row = row as? FirebirdSQLRow else {
				return
			}
			
			let rowOutput = row.databaseOutput()
			onOutput(rowOutput)
		}
	}
	
}

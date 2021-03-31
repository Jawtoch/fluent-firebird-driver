//import AsyncKit
//import FirebirdNIO
//

public struct FluentFirebirdDriver: DatabaseDriver {
	
	public let poolGroup: EventLoopGroupConnectionPool<FirebirdConnectionSource>
	
	public func makeDatabase(with context: DatabaseContext) -> Database {
		let pool = self.poolGroup.pool(for: context.eventLoop)
		let configuration = self.poolGroup.source.configuration
		let database = pool.database(logger: context.logger)
		
		
		return FluentFirebirdDatabase(
			database: database,
			context: context,
			configuration: configuration,
			inTransaction: false)
	}
	
	public func shutdown() {
		self.poolGroup.shutdown()
	}
	
	
}

extension EventLoopConnectionPool where Source == FirebirdConnectionSource {

	public func database(logger: Logger) -> FirebirdNIODatabase {
		return EventLoopConnectionPoolFirebirdDatabase(pool: self, logger: logger)
	}
}

private struct EventLoopConnectionPoolFirebirdDatabase {
	let pool: EventLoopConnectionPool<FirebirdConnectionSource>
	let logger: Logger
	var transaction: FirebirdTransaction? = nil
}


extension EventLoopConnectionPoolFirebirdDatabase: FirebirdNIODatabase {
	func withConnection<T>(_ closure: @escaping (FirebirdNIOConnection) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		return self.pool.withConnection(logger: self.logger, closure)
	}
	
	func simpleQuery(_ query: String, _ binds: [FirebirdData]) -> EventLoopFuture<Void> {
		self.pool.withConnection(logger: self.logger) { conn in
			conn.simpleQuery(query, binds)
		}
	}
	
	func query(_ query: String, _ binds: [FirebirdData]) -> EventLoopFuture<[FirebirdRow]> {
		self.pool.withConnection(logger: self.logger) { conn in
			conn.query(query, binds)
		}
	}
	
	func query(_ query: String, _ binds: [FirebirdData], onRow: @escaping (FirebirdRow) throws -> Void) -> EventLoopFuture<Void> {
		self.pool.withConnection(logger: self.logger) { conn in
			conn.query(query, binds, onRow: onRow)
		}
	}
	
	var eventLoop: EventLoop {
		self.pool.eventLoop
	}
}

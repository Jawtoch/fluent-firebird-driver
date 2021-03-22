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

	public func database(logger: Logger) -> FirebirdDatabase {
		return EventLoopConnectionPoolFirebirdDatabase(pool: self, logger: logger)
	}
}

private struct EventLoopConnectionPoolFirebirdDatabase {
	let pool: EventLoopConnectionPool<FirebirdConnectionSource>
	let logger: Logger
	var transaction: FirebirdTransaction? = nil
}


extension EventLoopConnectionPoolFirebirdDatabase: FirebirdDatabase {
	var eventLoop: EventLoop {
		self.pool.eventLoop
	}

	func withConnection<T>(_ closure: @escaping (FirebirdConnection) -> Future<T>) -> Future<T> {
		self.pool.withConnection(logger: self.logger, closure)
	}

	func query(_ string: String, _ binds: [FirebirdData], onMetadata: @escaping (FirebirdQueryMetadata) -> Void, onRow: @escaping (FirebirdRow) throws -> Void) -> Future<Void> {
		self.pool.withConnection(logger: self.logger) { conn in
			conn.query(string, binds, onMetadata: onMetadata, onRow: onRow)
		}
	}
}

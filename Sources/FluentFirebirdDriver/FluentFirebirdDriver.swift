//import AsyncKit
//import FirebirdNIO
//

public struct FluentFirebirdDriver: DatabaseDriver {
	public let pool: EventLoopGroupConnectionPool<FirebirdConnectionSource>

	var eventLoopGroup: EventLoopGroup {
		self.pool.eventLoopGroup
	}
	
	public func makeDatabase(with context: DatabaseContext) -> Database {
		FluentFirebirdDatabase(
			database: _ConnectionPoolFirebirdDatabase(pool: self.pool.pool(for: context.eventLoop), logger: context.logger),
			context: context,
			inTransaction: false)
	}
	
	public func shutdown() {
		self.pool.shutdown()
	}
}

struct _ConnectionPoolFirebirdDatabase {
	let pool: EventLoopConnectionPool<FirebirdConnectionSource>
	let logger: Logger
}

extension _ConnectionPoolFirebirdDatabase: FirebirdNIODatabase {
	var eventLoop: EventLoop {
		self.pool.eventLoop
	}
	
	func withConnection<T>(_ closure: @escaping (FirebirdNIOConnection) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.pool.withConnection(logger: self.logger) {
			closure($0)
		}
	}
	
	func simpleQuery(_ query: String, _ binds: [FirebirdData]) -> EventLoopFuture<Void> {
		self.withConnection {
			$0.simpleQuery(query, binds)
		}
	}
	
	func query(_ query: String, _ binds: [FirebirdData]) -> EventLoopFuture<[FirebirdRow]> {
		self.withConnection {
			$0.query(query, binds)
		}
	}
	
	func query(_ query: String, _ binds: [FirebirdData], onRow: @escaping (FirebirdRow) throws -> Void) -> EventLoopFuture<Void> {
		self.withConnection {
			$0.query(query, binds, onRow: onRow)
		}
	}
}

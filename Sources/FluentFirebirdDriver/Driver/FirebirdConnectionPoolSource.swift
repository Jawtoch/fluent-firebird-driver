import AsyncKit
import Firebird
import Logging

public struct FirebirdConnectionPoolSource {
	
	public let configuration: FirebirdConnectionConfiguration
	
}

extension FBConnection: ConnectionPoolItem {
		
}

extension FirebirdConnectionPoolSource: ConnectionPoolSource {

	public typealias Connection = FBConnection
	
	public func makeConnection(logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<FBConnection> {
		let connection = Connection(
			configuration: self.configuration,
			logger: logger,
			on: eventLoop)
		
		return connection
			.connect()
			.map { connection }
	}
	
}

extension EventLoopConnectionPool: FirebirdDatabase where Source == FirebirdConnectionPoolSource {
	
	public func query(_ query: String, binds: [FirebirdDataConvertible]) -> EventLoopFuture<[FirebirdRow]> {
		self.withConnection { (database: FirebirdDatabase) in
			database.query(query, binds: binds)
		}
	}
	
	public func withConnection<T>(_ closure: @escaping (FirebirdDatabase) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.withConnection { (connection: FBConnection) in
			closure(connection)
		}
	}
	
	public func withTransaction<T>(_ closure: @escaping (FirebirdDatabase) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
		self.withConnection { (database: FirebirdDatabase) in
			database.withTransaction(closure)
		}
	}
	
}

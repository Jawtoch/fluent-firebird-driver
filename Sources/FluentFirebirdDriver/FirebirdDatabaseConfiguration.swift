import AsyncKit
import Firebird
import FluentKit
import NIO

public struct FirebirdDatabaseConfiguration: DatabaseConfiguration {
	
	public var middleware: [AnyModelMiddleware]
	
	public let configuration: FirebirdConnectionConfiguration
	
	public let maxConnectionsPerEventLoop: Int

	public let connectionPoolTimeout: NIO.TimeAmount
		
	public let logger: Logger
		
	public func makeDriver(for databases: Databases) -> DatabaseDriver {
		let connectionSource = FirebirdConnectionPoolSource(
			configuration: self.configuration)
		let pool = EventLoopGroupConnectionPool(
			source: connectionSource,
			maxConnectionsPerEventLoop: self.maxConnectionsPerEventLoop,
			requestTimeout: self.connectionPoolTimeout,
			logger: self.logger,
			on: databases.eventLoopGroup)
		
		return FluentFirebirdDriver(
			connectionPool: pool)
	}
	
}

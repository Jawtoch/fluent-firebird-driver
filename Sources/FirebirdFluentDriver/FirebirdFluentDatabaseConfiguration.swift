//
//  FirebirdFluentDatabaseConfiguration.swift
//  
//
//  Created by ugo cottin on 24/06/2022.
//

import AsyncKit
import Firebird
import FirebirdSQL
import FluentKit
import Logging
import NIO

public struct FirebirdFluentDatabaseConfiguration: DatabaseConfiguration {
	
	public var middleware: [AnyModelMiddleware]
	
	public let configuration: FirebirdConnectionConfiguration
	
	public let maxConnectionsPerEventLoop: Int

	public let connectionPoolTimeout: NIO.TimeAmount
	
//	public let encoder: FirebirdEncoder
	
//	public let decoder: FirebirdDecoder
	
	public let logger: Logger
		
	public func makeDriver(for databases: Databases) -> DatabaseDriver {
		let connectionSource = FirebirdFluentConnectionPoolSource(
			configuration: self.configuration)
		let pool = EventLoopGroupConnectionPool(
			source: connectionSource,
			maxConnectionsPerEventLoop: self.maxConnectionsPerEventLoop,
			requestTimeout: self.connectionPoolTimeout,
			logger: self.logger,
			on: databases.eventLoopGroup)
		
		return FirebirdFluentDriver(
			connectionPool: pool)
	}
	
}

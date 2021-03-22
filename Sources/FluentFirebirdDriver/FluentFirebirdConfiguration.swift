//
//  FluentFirebirdConfiguration.swift
//
//
//  Created by Ugo Cottin on 15/03/2021.
//

public struct FluentFirebirdConfiguration: DatabaseConfiguration {
	
	public let configuration: FirebirdDatabaseConfiguration
	
	public var middleware: [AnyModelMiddleware] = []
	
	public func makeDriver(for databases: Databases) -> DatabaseDriver {
		let db = FirebirdConnectionSource(self.configuration)
		let poolGroup = EventLoopGroupConnectionPool(source: db, on: databases.eventLoopGroup)
		
		return FluentFirebirdDriver(poolGroup: poolGroup)
	}
}

extension DatabaseConfigurationFactory {
	
	public static func firebird(
		hostname: String,
		port: UInt16? = FirebirdDatabaseHost.defaultPort,
		username: String,
		password: String,
		database: String) -> DatabaseConfigurationFactory {
		return DatabaseConfigurationFactory {
			FluentFirebirdConfiguration(
				configuration: FirebirdDatabaseConfiguration(
					hostname: hostname,
					port: port,
					username: username,
					password: password,
					database: database), middleware: []
			)
		}
	}
	
}


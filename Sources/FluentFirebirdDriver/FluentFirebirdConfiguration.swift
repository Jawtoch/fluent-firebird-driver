//
//  FluentFirebirdConfiguration.swift
//
//
//  Created by Ugo Cottin on 15/03/2021.
//

public struct FluentFirebirdConfiguration: DatabaseConfiguration {
	
	public let configuration: FirebirdConnectionConfiguration
	
	public var middleware: [AnyModelMiddleware] = []
	
	public func makeDriver(for databases: Databases) -> DatabaseDriver {
		let db = FirebirdConnectionSource(configuration: self.configuration)
		let poolGroup = EventLoopGroupConnectionPool(source: db, on: databases.eventLoopGroup)
		
		return FluentFirebirdDriver(pool: poolGroup)
	}
}

extension DatabaseConfigurationFactory {
	
	public static func firebird(_ configuration: FirebirdConnectionConfiguration) -> DatabaseConfigurationFactory {
		return DatabaseConfigurationFactory {
			FluentFirebirdConfiguration(configuration: configuration)
		}
	}
	
	public static func firebird(
		hostname: String,
		port: UInt16? = FirebirdDatabaseHost.defaultPort,
		username: String,
		password: String,
		database: String) -> DatabaseConfigurationFactory {
		return DatabaseConfigurationFactory {
			FluentFirebirdConfiguration(
				configuration: FirebirdConnectionConfiguration(
					hostname: hostname,
					port: port,
					username: username,
					password: password,
					database: database), middleware: []
			)
		}
	}
	
}


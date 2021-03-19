//
//  FluentFirebirdConfiguration.swift
//
//
//  Created by Ugo Cottin on 15/03/2021.
//

public struct FluentFirebirdConfiguration: DatabaseConfiguration {
	
	public var middleware: [AnyModelMiddleware]
	
	public func makeDriver(for databases: Databases) -> DatabaseDriver {
		<#code#>
	}
}

//
//import FirebirdNIO
//import AsyncKit
//
//extension DatabaseConfigurationFactory {
//	
//	public static func firebird(
//		hostname: String,
//		port: UInt16? = FirebirdDatabaseHost.defaultPort,
//		username: String,
//		password: String,
//		database: String) -> DatabaseConfigurationFactory {
//		return DatabaseConfigurationFactory {
//			FluentFirebirdConfiguration(
//				middleware: [],
//				configuration: FirebirdDatabaseConfiguration(
//					hostname: hostname,
//					port: port,
//					username: username,
//					password: password,
//					database: database)
//			)
//		}
//	}
//	
//}
//
//struct FluentFirebirdConfiguration: DatabaseConfiguration {
//	var middleware: [AnyModelMiddleware]
//	let configuration: FirebirdDatabaseConfiguration
//	
//	func makeDriver(for databases: Databases) -> DatabaseDriver {
//		let db = FirebirdConnectionSource(self.configuration)
//		let pool = EventLoopGroupConnectionPool(source: db, on: databases.eventLoopGroup)
//		
//		return FluentFirebirdDriver(pool: pool)
//	}
//}

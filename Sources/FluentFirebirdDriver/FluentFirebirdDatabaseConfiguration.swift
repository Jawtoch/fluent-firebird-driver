import AsyncKit
import Firebird
import FirebirdSQL
import FluentKit
import Logging
import NIO

public struct FirebirdConnectionConfiguration {
    
    public let host: String
    
    public let port: UInt16
    
    public let database: String
    
    public let username: String
    
    public let password: String
    
}

public struct FluentFirebirdDatabaseConfiguration: DatabaseConfiguration {
    
    public var middleware: [AnyModelMiddleware]
    
    public let configuration: FirebirdConnectionConfiguration
    
    public let maxConnectionsPerEventLoop: Int

    public let connectionPoolTimeout: NIO.TimeAmount
        
    public let logger: Logger
        
    public func makeDriver(for databases: Databases) -> DatabaseDriver {
        let connectionSource = FluentFirebirdConnectionPoolSource(configuration: self.configuration)
        let pool = EventLoopGroupConnectionPool(source: connectionSource,
                                                maxConnectionsPerEventLoop: self.maxConnectionsPerEventLoop,
                                                requestTimeout: self.connectionPoolTimeout,
                                                logger: self.logger,
                                                on: databases.eventLoopGroup)
        
        return FluentFirebirdDriver(connectionPool: pool)
    }
    
}

public extension DatabaseConfigurationFactory {
    
    static func firebird(hostname: String,
                         port: UInt16 = 3050,
                         database: String,
                         username: String,
                         password: String,
                         logger: Logger) throws -> DatabaseConfigurationFactory {
        try .firebird(configuration: .init(host: hostname,
                                           port: port,
                                           database: database,
                                           username: username,
                                           password: password),
                      logger: logger)
    }
    
    static func firebird(configuration: FirebirdConnectionConfiguration,
                         maxConnectionsPerEventLoop: Int = 1,
                         connectionPoolTimeout: TimeAmount = .seconds(10),
                         logger: Logger) throws -> DatabaseConfigurationFactory {
        DatabaseConfigurationFactory {
            FluentFirebirdDatabaseConfiguration(middleware: [],
                                                configuration: configuration,
                                                maxConnectionsPerEventLoop: maxConnectionsPerEventLoop,
                                                connectionPoolTimeout: connectionPoolTimeout,
                                                logger: logger)
        }
    }
    
}

extension DatabaseID {
    
    public static var fbsql: DatabaseID {
        return .init(string: "fbsql")
    }
    
}

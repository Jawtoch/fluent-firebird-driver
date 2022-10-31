import AsyncKit
import Firebird
import FirebirdNIO
import SQLKit

extension FBNIOConnection: ConnectionPoolItem {
    
    public func close() -> EventLoopFuture<Void> {
        self.detach()
    }
    
}

public struct FluentFirebirdConnectionPoolSource: ConnectionPoolSource {

    public let configuration: FirebirdConnectionConfiguration
    
    public typealias Connection = FBNIOConnection
    
    public func makeConnection(logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<FBNIOConnection> {
        let connection = FBNIOConnection(logger: logger, on: eventLoop)
        
        return connection
            .attach(to: self.configuration.host,
                    port: self.configuration.port,
                    database: self.configuration.database,
                    username: self.configuration.username,
                    password: self.configuration.password)
            .map { connection }
    }
    
}

extension EventLoopConnectionPool: FirebirdNIODatabase where Source == FluentFirebirdConnectionPoolSource {
            
    public func withConnection<T>(_ closure: @escaping (FirebirdNIOConnection) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        self.withConnection { (connection: FBNIOConnection) in
            closure(connection)
        }
    }
    
    public func withTransaction<T>(_ closure: @escaping (FirebirdNIOTransaction) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        self.withConnection { connection in
            connection.withTransaction(closure)
        }
    }
    
    public func query(_ string: String, _ binds: [Encodable], onRow: @escaping (FirebirdRow) -> ()) -> EventLoopFuture<Void> {
        self.withConnection { connection in
            connection.query(string, binds, onRow: onRow)
        }
    }
    
}

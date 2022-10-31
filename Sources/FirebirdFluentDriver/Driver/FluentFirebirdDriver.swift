import AsyncKit
import FluentKit

public struct FluentFirebirdDriver: DatabaseDriver {
        
    public let connectionPool: EventLoopGroupConnectionPool<FluentFirebirdConnectionPoolSource>
        
    public func makeDatabase(with context: DatabaseContext) -> Database {
        let pool = self.connectionPool.pool(for: context.eventLoop)

        return FluentFirebirdDatabase(database: pool,
                                      context: context,
                                      inTransaction: false)
    }
    
    public func shutdown() {
        do {
            try self.connectionPool.syncShutdownGracefully()
        } catch {
            fatalError("Failed shutting down event loop pool: \(error)")
        }
    }
    
}

import Firebird
import FirebirdSQL
import FirebirdNIO
import FluentSQL

public struct FluentFirebirdDatabase {
    
    public let database: FirebirdNIODatabase
    
    public let context: DatabaseContext

    public let inTransaction: Bool
    
    public var converterDelegate: SQLConverterDelegate = FirebirdSQLConverterDelegate()
        
    internal func execute(sql query: SQLExpression, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
        let sqlDatabase = self.database.sql(dialect: FirebirdSQLDialect())
        return sqlDatabase.execute(sql: query) { row in
            guard let row = row as? FirebirdRow else {
                return
            }
            
            onOutput(row)
        }
    }
    
    internal func execute(sql query: SQLExpression) -> EventLoopFuture<Void> {
        self.execute(sql: query) { _ in }
    }
    
}

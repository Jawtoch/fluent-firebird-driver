import FluentKit
import FluentSQL

extension FluentFirebirdDatabase: Database {
        
    public func execute(query: DatabaseQuery, onOutput: @escaping (DatabaseOutput) -> ()) -> EventLoopFuture<Void> {
        let converter = SQLQueryConverter(delegate: self.converterDelegate)
        let expression = converter.convert(query)
        
        return self.execute(sql: expression, onOutput: onOutput)
    }
    
    public func execute(schema: DatabaseSchema) -> EventLoopFuture<Void> {
        let converter = SQLSchemaConverter(delegate: self.converterDelegate)
        let expression = converter.convert(schema)
        
        return self.execute(sql: expression)
    }
    
    public func execute(enum: DatabaseEnum) -> EventLoopFuture<Void> {
        self.eventLoop.makeFailedFuture(FluentFirebirdError.operationNotSupported)
    }
    
    public func withConnection<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        self.database.withConnection { connection in
            let db = FluentFirebirdDatabase(database: connection,
                                            context: self.context,
                                            inTransaction: self.inTransaction)
            
            return closure(db)
        }
    }
    
    public func transaction<T>(_ closure: @escaping (Database) -> EventLoopFuture<T>) -> EventLoopFuture<T> {
        self.database.withTransaction { _ in
            let db = FluentFirebirdDatabase(database: self.database,
                                            context: self.context,
                                            inTransaction: true)
            return closure(db)
        }
    }
    
}


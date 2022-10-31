import Firebird
import FluentKit

extension FirebirdRow: DatabaseOutput {
        
    public func schema(_ schema: String) -> DatabaseOutput {
        _SchemaDatabaseOutput(output: self, schema: schema)
    }
    
    public func contains(_ key: FluentKit.FieldKey) -> Bool {
        self.contains(column: self.columnName(key))
    }
    
    public func decodeNil(_ key: FluentKit.FieldKey) throws -> Bool {
        try self.decodeNil(column: self.columnName(key))
    }
    
    public func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T where T : Decodable {
        try self.decode(column: self.columnName(key), as: type)
    }
    
    public var description: String {
        String(describing: self)
    }
    
    private func columnName(_ key: FieldKey) -> String {
        switch key {
        case .id:
            return "id"
        case .aggregate:
            return key.description
        case .string(let name):
            return name
        case .prefix(let prefixKey , let fieldKey):
            return self.columnName(prefixKey) + self.columnName(fieldKey)
        }
    }
    
}

private struct _SchemaDatabaseOutput: DatabaseOutput {
    
    let output: DatabaseOutput
    
    let schema: String
    
    var description: String {
        self.output.description
    }
    
    func schema(_ schema: String) -> DatabaseOutput {
        self.output.schema(schema)
    }
    
    func contains(_ key: FieldKey) -> Bool {
        self.output.contains(self.key(key))
    }
    
    func decodeNil(_ key: FieldKey) throws -> Bool {
        try self.output.decodeNil(self.key(key))
    }
    
    func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T where T : Decodable {
        try self.output.decode(self.key(key), as: type)
    }
    
    private func key(_ key: FieldKey) -> FieldKey {
        .prefix(.string(self.schema + "_"), key)
    }
    
}

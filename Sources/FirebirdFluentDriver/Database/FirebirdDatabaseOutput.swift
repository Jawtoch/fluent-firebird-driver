import FluentKit
import FirebirdSQL



public struct FirebirdDatabaseOutput: DatabaseOutput {
	
	public let row: FirebirdSQLRow
	
	public func schema(_ schema: String) -> DatabaseOutput {
		fatalError("Not implemented")
	}
	
	public func contains(_ key: FieldKey) -> Bool {
		fatalError("Not implemented")
	}
	
	public func decodeNil(_ key: FieldKey) throws -> Bool {
		fatalError("Not implemented")
	}
	
	public func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T where T : Decodable {
		fatalError("Not implemented")
	}
	
	public var description: String {
		fatalError("Not implemented")
	}
	
}

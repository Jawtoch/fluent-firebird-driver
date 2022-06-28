import Firebird
import FirebirdSQL
import FluentKit

public struct FirebirdDatabaseOutput: DatabaseOutput {
	
	public let row: FirebirdRow
	
	public func schema(_ schema: String) -> DatabaseOutput {
		_FirebirdSchemaDatabaseOutput(output: self, schema: schema)
	}
	
	public func contains(_ key: FieldKey) -> Bool {
		self.row.allColumns.contains(self.columnName(ofKey: key))
	}
	
	public func decodeNil(_ key: FieldKey) throws -> Bool {
		try self.row.decodeNil(column: self.columnName(ofKey: key))
	}
	
	public func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T where T : Decodable {
		try self.row.decode(column: self.columnName(ofKey: key), as: type)
	}
	
	public var description: String {
		"FBDBOutput(\(self.row.allColumns.count) rows)"
	}
	
	private func columnName(ofKey key: FieldKey) -> String {
		switch key {
			case .id:
				return "id"
			case .string(let string):
				return string
			case .aggregate:
				return key.description
			case .prefix(let prefixKey , let fieldKey):
				return self.columnName(ofKey: prefixKey) + "_" + self.columnName(ofKey: fieldKey)
		}
	}
	
}

private struct _FirebirdSchemaDatabaseOutput: DatabaseOutput {
	
	let output: DatabaseOutput
	
	let schema: String
	
	var description: String {
		"FBDBOutput[\(self.schema)]\(self.output.description)"
	}
	
	func schema(_ schema: String) -> DatabaseOutput {
		self.output.schema(schema)
	}
	
	func contains(_ key: FieldKey) -> Bool {
		self.output.contains(self.schemaKey(key))
	}
	
	func decodeNil(_ key: FieldKey) throws -> Bool {
		try self.output.decodeNil(self.schemaKey(key))
	}
	
	func decode<T>(_ key: FieldKey, as type: T.Type) throws -> T where T : Decodable {
		try self.output.decode(self.schemaKey(key), as: type)
	}
	
	private func schemaKey(_ key: FieldKey) -> FieldKey {
		.prefix(.string(self.schema), key)
	}
	
}

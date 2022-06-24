import FluentSQL

public struct FirebirdSQLConverterDelegate: SQLConverterDelegate{
	
	public func customDataType(_ dataType: DatabaseSchema.DataType) -> SQLExpression? {
		nil
	}
	
	public func nestedFieldExpression(_ column: String, _ path: [String]) -> SQLExpression {
		fatalError("Not implemented")
	}
	
}

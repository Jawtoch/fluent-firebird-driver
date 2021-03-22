//
//  FirebirdConverterDelegate.swift
//  
//
//  Created by Ugo Cottin on 22/03/2021.
//

public struct FirebirdConverterDelegate: SQLConverterDelegate {
	public func customDataType(_ dataType: DatabaseSchema.DataType) -> SQLExpression? {
		switch dataType {
			case .date:
				return SQLRaw("DATE")
			default:
				return SQLRaw("VARYING")
		}
	}
	
	public func nestedFieldExpression(_ column: String, _ path: [String]) -> SQLExpression {
		return SQLRaw("nested \(column)->\(path.joined(separator: "."))")
	}
}

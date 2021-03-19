//
//  FirebirdSQLConverterDelegate.swift
//  
//
//  Created by Ugo Cottin on 16/03/2021.
//

struct FirebirdSQLConverterDelegate: SQLConverterDelegate {
	func customDataType(_ dataType: DatabaseSchema.DataType) -> SQLExpression? {
		switch dataType {
			case .string:
				return SQLRaw("TEXT")
			default:
				return SQLRaw("VARYING")
		}
	}
	
	func nestedFieldExpression(_ column: String, _ path: [String]) -> SQLExpression {
		return SQLRaw("raww")
	}
}

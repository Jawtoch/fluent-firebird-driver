//
//  Exports.swift
//  
//
//  Created by Ugo Cottin on 15/03/2021.
//

@_exported import FluentKit
@_exported import FirebirdKit
@_exported import FluentSQL

extension DatabaseID {
	public static var fbsql: DatabaseID {
		return .init(string: "fbsql")
	}
}

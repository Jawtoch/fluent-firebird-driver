import FluentKit
import Firebird

public struct FirebirdFluentDatabase {
	
	public let database: FirebirdDatabase
	
	public let context: DatabaseContext

	public let inTransaction: Bool
	
}

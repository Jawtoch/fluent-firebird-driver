//
//  FirebirdFluentDriver.swift
//
//
//  Created by ugo cottin on 24/06/2022.
//

import AsyncKit
import FirebirdSQL
import FluentKit

public struct FirebirdFluentDriver: DatabaseDriver {
		
	public let connectionPool: EventLoopGroupConnectionPool<FirebirdFluentConnectionPoolSource>
	
	public let decoder: FirebirdDecoder
		
	public func makeDatabase(with context: DatabaseContext) -> Database {
		let pool = self.connectionPool.pool(for: context.eventLoop)

		return FirebirdFluentDatabase(database: pool,
									  context: context,
									  inTransaction: false,
									  decoder: self.decoder)
	}
	
	public func shutdown() {
		do {
			try self.connectionPool.syncShutdownGracefully()
		} catch {
			fatalError("Failed shutting down event loop pool: \(error)")
		}
	}
	
}

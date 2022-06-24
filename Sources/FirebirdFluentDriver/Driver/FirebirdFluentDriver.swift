//
//  FirebirdFluentDriver.swift
//
//
//  Created by ugo cottin on 24/06/2022.
//

import FluentKit

public struct FirebirdFluentDriver: DatabaseDriver {
	
	public let pool: EventLoopConnectionPool<FirebirdConnectionPoolSource>
	
	public func makeDatabase(with context: DatabaseContext) -> Database {
		//FirebirdFluentDatabase(database: FirebirdDatabase, context: context, inTransaction: false)
		fatalError()
	}
	
	public func shutdown() {
		fatalError("Not implemented")
	}
	
}

import AsyncKit
import Firebird

public class FirebirdConnectionOnEventLoop {
	
	public let asyncConnection: FirebirdConnection
	
	public let eventLoop: EventLoop
	
	public var logger: Logger {
		self.asyncConnection.logger
	}
	
	public var target: DatabaseTarget {
		self.asyncConnection.target
	}
	
	public var isActive: Bool {
		self.asyncConnection.isActive
	}
	
	public init(asyncConnection: FirebirdConnection, on eventLoop: EventLoop) {
		self.asyncConnection = asyncConnection
		self.eventLoop = eventLoop
	}
	
	public static func connect(to target: DatabaseTarget, parameters: [FirebirdConnectionParameter] = [], logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<FirebirdConnectionOnEventLoop> {
		eventLoop.performWithTask {
			try await FirebirdConnection.connect(to: target,
												 parameters: parameters,
												 logger: logger)
		}.map { FirebirdConnectionOnEventLoop(asyncConnection: $0,
											  on: eventLoop) }
	}
	
	public func close() -> EventLoopFuture<Void> {
		self.eventLoop.performWithTask {
			try await self.asyncConnection.close()
		}
	}
	
}

extension FirebirdConnectionOnEventLoop: ConnectionPoolItem {
	
	public var isClosed: Bool {
		!self.isActive
	}
	
}

public struct FirebirdConnectionPoolSource: ConnectionPoolSource {
	
	public typealias Connection = FirebirdConnectionOnEventLoop
	
	public let target: DatabaseTarget
	
	public let parameters: [FirebirdConnectionParameter]
	
	public func makeConnection(logger: Logger, on eventLoop: EventLoop) -> EventLoopFuture<Connection> {
		FirebirdConnectionOnEventLoop.connect(to: self.target, parameters: self.parameters, logger: logger, on: eventLoop)
	}
	
}

extension EventLoopConnectionPool: FirebirdDatabase where Source == FirebirdConnectionPoolSource {
	public func query(_ string: String, fields: [FirebirdField]) async throws -> [FirebirdRow] {
		try await self.withConnection { conn async throws in
			try await conn.query(string, fields: fields)
		}
	}
	
	public func withConnection<T>(_ closure: (FirebirdConnection) async throws -> T) async throws -> T {
		try await self.withConnection { connectionOnEventLoop in
			connectionOnEventLoop.eventLoop.performWithTask {
				try await closure(connectionOnEventLoop.asyncConnection)
			}
		}.get()
	}
	
	public func withTransaction<T>(_ closure: (FirebirdTransaction) async throws -> T) async throws -> T {
		fatalError()
	}
	
	
}

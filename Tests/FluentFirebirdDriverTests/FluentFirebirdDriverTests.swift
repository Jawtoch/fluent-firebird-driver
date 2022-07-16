import AsyncKit
import FluentKit
import Logging
import NIO
import XCTest

@testable import FluentFirebirdDriver
import Firebird
import FirebirdSQL

class XCTAsyncTests: XCTestCase {
	
	static var eventLoopGroup: EventLoopGroup!
	
	static var threadPool: NIOThreadPool!
	
	class func setupEventLoopGroup() {
		self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
		self.threadPool = NIOThreadPool(numberOfThreads: System.coreCount)
	}
	
	class func tearDownEventLoopGroup() {
		try! self.eventLoopGroup.syncShutdownGracefully()
		try! self.threadPool.syncShutdownGracefully()
		self.eventLoopGroup = nil
	}
	
	override class func setUp() {
		self.setupEventLoopGroup()
	}
	
	override class func tearDown() {
		self.tearDownEventLoopGroup()
	}
	
	var eventLoopGroup: EventLoopGroup {
		Self.eventLoopGroup
	}
	
	var eventLoop: EventLoop {
		self.eventLoopGroup.next()
	}
	
	var threadPool: NIOThreadPool {
		Self.threadPool
	}
	
}

fileprivate final class Employee: Model, CustomStringConvertible {
	
	typealias IDValue = Int16
	
	static var schema: String = "EMPLOYEE"
	
	@ID(custom: "EMP_NO")
	var id: IDValue?
	
	@Field(key: "FIRST_NAME")
	var firstName: String
	
	@Field(key: "LAST_NAME")
	var lastName: String
	
	var description: String {
		"ID \(self.id ?? -1) - \(self.firstName) \(self.lastName)"
	}
}

final class FluentFirebirdDriverTests: XCTAsyncTests {
	
	var logger: Logger {
		var _logger = Logger(label: "firebirdfluentdriver.tests")
		_logger.logLevel = .trace
		return _logger
	}
	
	let databaseConfiguration: FirebirdConnectionConfiguration = FirebirdConnectionConfiguration(
		target: .remote(
			hostName: "localhost",
			port: 3050,
			path: "employee"),
		parameters: [
			.version1,
			.username("SYSDBA"),
			.password("SMETHING")
		])
	
	let databaseId: DatabaseID = DatabaseID(string: "firebird_db")
	
	var fluentDatabaseConfiguration: DatabaseConfiguration {
		FirebirdDatabaseConfiguration(
			middleware: [],
			configuration: self.databaseConfiguration,
			maxConnectionsPerEventLoop: 1,
			connectionPoolTimeout: .seconds(4),
			logger: self.logger)
	}
	
	var databases: Databases!
	
	override func setUp() {
		super.setUp()
		
		let databases = Databases(threadPool: self.threadPool, on: self.eventLoopGroup)
		databases.use(self.fluentDatabaseConfiguration, as: self.databaseId, isDefault: true)
		
		self.databases = databases
	}
	
	override func tearDown() {
		self.databases.shutdown()
		self.databases = nil
	}
	
	var database: Database {
		self.databases.database(logger: self.logger, on: self.eventLoop)!
	}
	
	func testQuery() throws {
		let employee = try Employee
			.query(on: database)
			.filter(\.$id, .equal, Int16(9))
			.all()
			.map { $0.first }
			.wait()
		
		XCTAssertNotNil(employee)
		
		XCTAssertEqual(employee!.id, 9)
		XCTAssertEqual(employee!.firstName, "Phil")
	}
	
}

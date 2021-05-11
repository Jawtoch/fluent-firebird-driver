import XCTest
@testable import FluentFirebirdDriver

final class FluentFirebirdDriverTests: XCTestCase {
	
	private static let logger: Logger = .init(label: "testing.firebird")
	
	// MARK: - Connection parameters
	private static var hostname: String {
		guard let hostname = ProcessInfo.processInfo.environment["FB_TEST_HOSTNAME"] else {
			fatalError("FB_TEST_HOSTNAME is not defined")
		}
		
		return hostname
	}
	
	private static var port: UInt16? {
		guard let port = ProcessInfo.processInfo.environment["FB_TEST_PORT"] else { return nil }
		
		return UInt16(port)
	}
	
	private static var username: String {
		guard let username = ProcessInfo.processInfo.environment["FB_TEST_USERNAME"] else {
			fatalError("FB_TEST_USERNAME is not defined")
		}
		
		return username
	}
	
	private static var password: String {
		guard let password = ProcessInfo.processInfo.environment["FB_TEST_PASSWORD"] else {
			fatalError("FB_TEST_PASSWORD is not defined")
		}
		
		return password
	}
	
	private static var database_name: String {
		guard let database = ProcessInfo.processInfo.environment["FB_TEST_DATABASE"] else {
			fatalError("FB_TEST_DATABASE is not defined")
		}
		
		return database
	}
	
	private static var configuration: FirebirdConnectionConfiguration {
		.init(
			hostname: self.hostname,
			port: self.port,
			username: self.username,
			password: self.password,
			database: self.database_name)
	}
	
	
	// MARK: - Threads
	private static let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
	
	private static let threadGroup = NIOThreadPool(numberOfThreads: 1)
	
	override class func tearDown() {
		self.databases.shutdown()
		try! self.eventLoopGroup.syncShutdownGracefully()
		try! self.threadGroup.syncShutdownGracefully()
	}
	
	// MARK: - Databases
	private static var databases: Databases!
	
	override class func setUp() {
		self.databases = Databases(threadPool: self.threadGroup, on: self.eventLoopGroup)
		self.databases.use(.firebird(self.configuration), as: .fbsql)
	}
	
	private var database: Database {
		Self.databases.database(.fbsql, logger: Self.logger, on: Self.eventLoopGroup.next())!
	}
	
	func testConnect() throws {
		let _ = try database.withConnection { $0.eventLoop.makeSucceededFuture($0) }.wait()
	}
	
	func testQuery() throws {
		let employees = try self.database.query(Employee.self).all().wait()
		XCTAssertEqual(employees.count, 42)
	}
	
	func testQueryWithParameters() throws {
		let employee = try self.database.query(Employee.self)
			.filter(\.$id, .equal, 121)
			.all()
			.map { $0.first }
			.unwrap(orError: FirebirdCustomError("not found"))
			.wait()
		XCTAssertEqual(employee.firstName, "Roberto")
	}
	
	static var allTests = [
		("testConnect", testConnect),
		("testQuery", testQuery),
		("testQueryWithParameters", testQueryWithParameters)
	]
}

class Employee: Model {
	typealias IDValue = Int16
	
	static var schema: String = "employee"

	@ID(custom: "emp_no")
	var id: IDValue?
	
	@Field(key: "first_name")
	var firstName: String
	
	@Field(key: "last_name")
	var lastName: String
	
	required init() { }
	
}

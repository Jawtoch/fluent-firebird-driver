import XCTest
@testable import FluentFirebirdDriver

final class FluentFirebirdDriverTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(FluentFirebirdDriver().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

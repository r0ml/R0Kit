import XCTest
@testable import R0Kit

final class R0KitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(R0Kit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

import XCTest
@testable import SwaggerFaker

class SchemaPathTests: XCTestCase {
    func test_append_operator() {
        XCTAssertEqual(SchemaPath(path: []) + .key("root"), SchemaPath(path: [.key("root")]))
        XCTAssertEqual(SchemaPath(path: [.key("root")]) + .key("lvl 1"), SchemaPath(path: [.key("root"), .key("lvl 1")]))
        XCTAssertEqual(SchemaPath(path: [.key("root")]) + .index(0), SchemaPath(path: [.key("root"), .index(0)]))
    }
}

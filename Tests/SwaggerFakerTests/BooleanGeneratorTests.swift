@testable import SwaggerFaker
import XCTest
import Swagger

class BooleanGeneratorTests: XCTestCase {
    func test_generate_returns_different_values_for_successive_calls() {
        let sut = BooleanGenerator(config: .default)

        let generations = (0..<10).reduce(into: Set<Bool>()) { (generations, _) in
            generations.insert(sut.generate())
        }

        XCTAssertEqual(generations.count, 2)
    }

    func test_generate_static() {
        XCTAssertTrue(BooleanGenerator(config: .static(true)).generate())
        XCTAssertFalse(BooleanGenerator(config: .static(false)).generate())
    }
}

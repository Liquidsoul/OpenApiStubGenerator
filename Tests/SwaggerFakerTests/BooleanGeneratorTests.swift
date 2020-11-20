@testable import SwaggerFaker
import XCTest
import Swagger

class BooleanGeneratorTests: XCTestCase {
    func test_generate_returns_different_values_for_successive_calls() {
        let sut = BooleanGenerator(mode: .default)

        let generations = (0..<10).reduce(into: Set<Bool>()) { (generations, _) in
            generations.insert(sut.generate())
        }

        XCTAssertEqual(generations.count, 2)
    }

    func test_generate_static() {
        XCTAssertTrue(BooleanGenerator(mode: .static(true)).generate())
        XCTAssertFalse(BooleanGenerator(mode: .static(false)).generate())
    }
}

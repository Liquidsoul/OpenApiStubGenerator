@testable import SwaggerFaker
import XCTest
import Swagger

class IntegerGeneratorTests: XCTestCase {
    func test_generate_returns_different_values_for_successive_calls() {
        let integerSchema = IntegerSchema()

        let sut = IntegerGenerator(config: .default)

        let generations = (0..<4).reduce(into: Set<Int>()) { (generations, _) in
            generations.insert(sut.generate(from: integerSchema))
        }

        XCTAssertGreaterThan(generations.count, 1)
    }

    func test_generate_with_schema_boundaries() {
        let sut = IntegerGenerator(config: .default)

        XCTAssertLessThanOrEqual(20, sut.generate(from: .init(minimum: 20)))
        XCTAssertGreaterThanOrEqual(-42, sut.generate(from: .init(maximum: -42)))

        let result = sut.generate(from: .init(minimum: -39, maximum: 42))
        XCTAssertLessThanOrEqual(-39, result)
        XCTAssertGreaterThanOrEqual(42, result)

        XCTAssertEqual(42, sut.generate(from: .init(minimum: 42, maximum: 42)))
    }

    func test_generate_with_config_boundaries_and_no_schema_boundaries() {
        let sut = IntegerGenerator(config: .random(minimum: 5, maximum: 20))

        XCTAssertLessThanOrEqual(5, sut.generate(from: .init()))
        XCTAssertGreaterThanOrEqual(20, sut.generate(from: .init()))
    }

    func test_generate_respect_schema_boundaries_over_config() {
        let sut = IntegerGenerator(config: .random(minimum: 5, maximum: 20))

        XCTAssertLessThanOrEqual(10, sut.generate(from: .init(minimum: 10)))
        XCTAssertGreaterThanOrEqual(18, sut.generate(from: .init(maximum: 18)))
    }
}

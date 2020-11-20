@testable import SwaggerFaker
import XCTest
import Swagger

class NumberGeneratorTests: XCTestCase {
    func test_generate_returns_different_values_for_successive_calls() {
        let numberSchema = NumberSchema()

        let sut = NumberGenerator(mode: .default)

        let generations = (0..<4).reduce(into: Set<Double>()) { (generations, _) in
            generations.insert(sut.generate(from: numberSchema))
        }

        XCTAssertGreaterThan(generations.count, 1)
    }

    func test_generate_with_schema_boundaries() {
        let sut = NumberGenerator(mode: .default)

        XCTAssertLessThanOrEqual(20.2, sut.generate(from: .init(minimum: 20.2)))
        XCTAssertGreaterThanOrEqual(-42.4, sut.generate(from: .init(maximum: -42.4)))

        let result = sut.generate(from: .init(minimum: -39.1, maximum: 42.5))
        XCTAssertLessThanOrEqual(-39.1, result)
        XCTAssertGreaterThanOrEqual(42.5, result)

        XCTAssertEqual(42.4, sut.generate(from: .init(minimum: 42.4, maximum: 42.4)))
    }

    func test_generate_with_mode_boundaries_and_no_schema_boundaries() {
        let sut = NumberGenerator(mode: .random(minimum: 4.5, maximum: 20.2))

        XCTAssertLessThanOrEqual(4.5, sut.generate(from: .init()))
        XCTAssertGreaterThanOrEqual(20.2, sut.generate(from: .init()))
    }

    func test_generate_respect_schema_boundaries_over_mode() {
        let sut = NumberGenerator(mode: .random(minimum: -13.1, maximum: 12.3))

        XCTAssertLessThanOrEqual(-3.1, sut.generate(from: .init(minimum: -3.1)))
        XCTAssertGreaterThanOrEqual(2.3, sut.generate(from: .init(maximum: 2.3)))
    }

}

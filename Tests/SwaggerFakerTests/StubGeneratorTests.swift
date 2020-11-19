@testable import SwaggerFaker
import XCTest
import Swagger

class StubGeneratorTests: XCTestCase {
    func test_generate_string_noFormat_generateDifferentOutputs() {
        let sut = StubGenerator()

        let stringSchema = StringSchema()

        let generations = (0..<4).reduce(into: Set<String>()) { (generations, _) in
            generations.insert(sut.generate(stringSchema))
        }

        XCTAssertGreaterThan(generations.count, 1)
    }

    func test_generate_string_date() {
        let sut = StubGenerator()

        let stringSchema = StringSchema(format: StringFormat.format(.date))

        let value = sut.generate(stringSchema)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        XCTAssertNotNil(formatter.date(from: value))
    }
}

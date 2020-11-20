@testable import SwaggerFaker
import XCTest
import Swagger

class ArrayGeneratorTests: XCTestCase {

    func test_generateEmptyArrayIfRangeContainsNoElement() {
        let spy = GeneratorSpy()

        let sut = ArrayGenerator(mode: .randomLength(range: 0..<0))

        let schema = ArraySchema(items: .single(Schema(metadata: .init(), type: .integer(IntegerSchema()))))
        let result = sut.generate(arraySchema: schema, generator: spy.generate(_:index:))
        XCTAssertEqual(0, result.count)
        XCTAssertEqual(0, spy.callCount)
    }

    func test_generateArrayWithExpectedLength() {
        let length = 4
        let spy = GeneratorSpy()

        let sut = ArrayGenerator(mode: .randomLength(range: length..<(length + 1)))

        let schema = ArraySchema(items: .single(Schema(metadata: .init(), type: .integer(IntegerSchema()))))
        let result = sut.generate(arraySchema: schema, generator: spy.generate(_:index:))
        XCTAssertEqual(length, result.count)
        XCTAssertEqual(length, spy.callCount)

    }

    class GeneratorSpy {
        var callCount: Int = 0

        var generatedValue: Any = 42

        func generate(_ schemaType: SchemaType, index: Int) -> Any {
            callCount += 1
            return generatedValue
        }
    }
}

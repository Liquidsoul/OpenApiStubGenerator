@testable import SwaggerFaker
import XCTest
import Swagger

class StringGeneratorTests: XCTestCase {
    func test_generate_static() {
        let staticString = "Some static string: \(UUID().uuidString)"

        let sut = StringGenerator(config: .static(staticString), dateGenerator: StringDateGeneratorStub(staticDate: Date()))


        XCTAssertEqual(staticString, sut.generate(from: StringSchema()))
        XCTAssertEqual(staticString, sut.generate(from: StringSchema(format: .format(.email))))
        XCTAssertEqual(staticString, sut.generate(from: StringSchema(format: .format(.date))))
        XCTAssertEqual(staticString, sut.generate(from: StringSchema(format: .format(.dateTime))))
    }

    func test_generate_randomFromList_empty() {
        let sut = StringGenerator(config: .randomFromList([]), dateGenerator: StringDateGeneratorStub(staticDate: Date()))

        XCTAssertEqual("", sut.generate(from: StringSchema()))
        XCTAssertEqual("", sut.generate(from: StringSchema(format: .format(.email))))
        XCTAssertEqual("", sut.generate(from: StringSchema(format: .format(.date))))
        XCTAssertEqual("", sut.generate(from: StringSchema(format: .format(.dateTime))))
    }

    func test_generate_randomFromList() {
        let list = ["1.", "2..", "3.."]

        let sut = StringGenerator(config: .randomFromList(list), dateGenerator: StringDateGeneratorStub(staticDate: Date()))

        XCTAssertTrue(list.contains(sut.generate(from: StringSchema())))
        XCTAssertTrue(list.contains(sut.generate(from: StringSchema(format: .format(.email)))))
        XCTAssertTrue(list.contains(sut.generate(from: StringSchema(format: .format(.date)))))
        XCTAssertTrue(list.contains(sut.generate(from: StringSchema(format: .format(.dateTime)))))
    }

    func test_generate_faker() {
        let sut = StringGenerator(config: .faker, dateGenerator: StringDateGeneratorStub(staticDate: Date()))

        XCTAssertNotEqual("", sut.generate(from: StringSchema()))
        XCTAssertTrue(sut.generate(from: StringSchema(format: .format(.email))).isEmail)
        XCTAssertNotNil(dateFormatter.date(from: sut.generate(from: StringSchema(format: .format(.date)))))
        XCTAssertNotNil(dateFormatter.date(from: sut.generate(from: StringSchema(format: .format(.dateTime)))))
    }

    let dateFormatter = ISO8601DateFormatter().withFormatOptions([.withInternetDateTime, .withFractionalSeconds])
}

struct StringDateGeneratorStub: StringDateGenerator {
    let staticDate: Date

    let dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter().withFormatOptions([.withInternetDateTime, .withFractionalSeconds])

    func generateDate() -> Date {
        return staticDate
    }
}

extension String {
    var isEmail: Bool {
        let templateString = self as NSString
        let range = NSRange(location: 0, length: templateString.length)
        let matches = type(of: self).emailExpression.matches(in: self, options: [], range: range)
        return !matches.isEmpty
    }

    private static let emailExpression: NSRegularExpression = {
        let expression: NSRegularExpression
        do {
            expression = try NSRegularExpression(pattern: "[^@]+@[a-zA-Z]+[.][a-zA-Z]+", options: [])
        } catch let error as NSError {
            fatalError("Invalid Regex \(error)")
        }
        return expression
    }()
}

@testable import SwaggerFaker
import XCTest
import Swagger

class StringGeneratorTests: XCTestCase {
    func test_generate_static() {
        let staticString = "Some static string: \(UUID().uuidString)"

        let sut = StringGenerator(mode: .static(staticString), dateGenerator: StringDateGeneratorStub(staticDate: Date()))


        XCTAssertEqual(staticString, sut.generate(from: StringSchema()))
        XCTAssertEqual(staticString, sut.generate(from: StringSchema(format: .format(.email))))
        XCTAssertNotEqual(staticString, sut.generate(from: StringSchema(format: .format(.date))))
        XCTAssertNotEqual(staticString, sut.generate(from: StringSchema(format: .format(.dateTime))))
        XCTAssertNotNil(dateFormatter.date(from: sut.generate(from: StringSchema(format: .format(.date)))))
        XCTAssertNotNil(dateFormatter.date(from: sut.generate(from: StringSchema(format: .format(.dateTime)))))
    }

    func test_generate_randomFromList_empty() {
        let sut = StringGenerator(mode: .randomFromList([]), dateGenerator: StringDateGeneratorStub(staticDate: Date()))

        XCTAssertEqual("", sut.generate(from: StringSchema()))
        XCTAssertEqual("", sut.generate(from: StringSchema(format: .format(.email))))
        XCTAssertNotEqual("", sut.generate(from: StringSchema(format: .format(.date))))
        XCTAssertNotEqual("", sut.generate(from: StringSchema(format: .format(.dateTime))))
        XCTAssertNotNil(dateFormatter.date(from: sut.generate(from: StringSchema(format: .format(.date)))))
        XCTAssertNotNil(dateFormatter.date(from: sut.generate(from: StringSchema(format: .format(.dateTime)))))
    }

    func test_generate_randomFromList() {
        let list = ["1.", "2..", "3.."]

        let sut = StringGenerator(mode: .randomFromList(list), dateGenerator: StringDateGeneratorStub(staticDate: Date()))

        XCTAssertTrue(list.contains(sut.generate(from: StringSchema())))
        XCTAssertTrue(list.contains(sut.generate(from: StringSchema(format: .format(.email)))))
        XCTAssertFalse(list.contains(sut.generate(from: StringSchema(format: .format(.date)))))
        XCTAssertFalse(list.contains(sut.generate(from: StringSchema(format: .format(.dateTime)))))
        XCTAssertNotNil(dateFormatter.date(from: sut.generate(from: StringSchema(format: .format(.date)))))
        XCTAssertNotNil(dateFormatter.date(from: sut.generate(from: StringSchema(format: .format(.dateTime)))))
    }

    func test_generate_faker() {
        let sut = StringGenerator(mode: .faker, dateGenerator: StringDateGeneratorStub(staticDate: Date()))

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

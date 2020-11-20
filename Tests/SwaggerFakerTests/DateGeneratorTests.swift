@testable import SwaggerFaker
import XCTest
import Swagger

class DateGeneratorTests: XCTestCase {
    func test_generate_static() {
        let staticDate = Date()

        let sut = DateGenerator(mode: .static(staticDate))

        XCTAssertEqual(staticDate, sut.generateDate())
        XCTAssertEqual(staticDate, sut.generateDate())
    }

    func test_generate_random() {
        let fromDate = Date().addingTimeInterval(-3600)
        let toDate = Date().addingTimeInterval(3600)

        let sut = DateGenerator(mode: .random(after: fromDate, before: toDate))

        let result1 = sut.generateDate()
        let result2 = sut.generateDate()
        XCTAssertNotEqual(result1, result2)
        XCTAssertTrue(fromDate <= result1)
        XCTAssertTrue(fromDate <= result2)
        XCTAssertTrue(result1 <= toDate)
        XCTAssertTrue(result2 <= toDate)
    }

    func test_generate_increments() {
        let referenceDate = Date().addingTimeInterval(-3600)
        let increment: TimeInterval = 60

        let sut = DateGenerator(mode: .increments(from: referenceDate, by: increment))

        let result1 = sut.generateDate()
        XCTAssertEqual(result1, referenceDate)
        let result2 = sut.generateDate()
        XCTAssertEqual(increment, result1.distance(to: result2))
        let result3 = sut.generateDate()
        XCTAssertEqual(increment, result2.distance(to: result3))
        XCTAssertEqual(2 * increment, result1.distance(to: result3))
    }
}

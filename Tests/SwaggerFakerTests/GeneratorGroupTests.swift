@testable import SwaggerFaker
import XCTest

class GeneratorGroupTests: XCTestCase {
    func test_that_a_new_date_configuration_is_applied_even_when_the_string_configuration_is_unchanged() {
        let overrideDateMode = DateGenerator.Mode.increments(from: Date(), by: 42)
        let result = GeneratorGroup(configuration: .init(boolean: .fallback,
                                                         integer: .fallback,
                                                         number: .fallback,
                                                         array: .fallback,
                                                         date: .override(overrideDateMode),
                                                         string: .fallback),
                                    defaults: initialGroup)

        XCTAssertEqual(result.stringGenerator.dateGenerator.mode, overrideDateMode)
    }

    var initialGroup: GeneratorGroup = .init(configuration: .init(boolean: .override(.static(false)),
                                                                  integer: .override(.random(minimum: 4, maximum: 4)),
                                                                  number: .override(.random(minimum: 5, maximum: 5)),
                                                                  array: .override(.randomLength(range: 0..<5)),
                                                                  date: .override(.now),
                                                                  string: .override(.static("staticString"))))
}

@testable import SwaggerFaker
import XCTest

class GeneratorProviderTests: XCTestCase {
    func test_generators_returnsDefaultsConfigurationForEmptyOrUnknownPath() {
        let defaultsConfiguration = customDefaultsConfiguration

        let sut = GeneratorProvider(configuration: Configuration(defaults: defaultsConfiguration, paths: [:]))

        XCTAssertEqual(sut.generators(for: SchemaPath()).configuration, defaultsConfiguration)
        XCTAssertEqual(sut.generators(for: SchemaPath(path: [.key("items"), .index(0), .key("name")])).configuration, defaultsConfiguration)
    }

    func test_generators_match_leaf_keys() {
        let defaultsConfiguration = customDefaultsConfiguration
        let pathConfiguration = customPathConfiguration

        let sut = GeneratorProvider(configuration: Configuration(defaults: defaultsConfiguration,
                                                                 paths: ["name": pathConfiguration]))

        XCTAssertEqual(sut.generators(for: SchemaPath()).configuration, defaultsConfiguration)
        XCTAssertEqual(sut.generators(for: SchemaPath(path: [.key("name")])).configuration, pathConfiguration)
        XCTAssertEqual(sut.generators(for: SchemaPath(path: [.key("name"), .index(0)])).configuration, defaultsConfiguration)
        XCTAssertEqual(sut.generators(for: SchemaPath(path: [.key("items"), .index(0), .key("name")])).configuration, pathConfiguration)
    }

    let customDefaultsConfiguration: GeneratorGroup.Configuration = .init(boolean: .override(.static(true)),
                                                                          integer: .override(.random(minimum: 4, maximum: 10)),
                                                                          number: .override(.random(minimum: -32, maximum: 42)),
                                                                          array: .override(.randomLength(range: 0..<4)),
                                                                          date: .override(.now),
                                                                          string: .override(.static("defaults")))
    let customPathConfiguration: GeneratorGroup.Configuration = .init(boolean: .override(.static(false)),
                                                                      integer: .override(.random(minimum: -2, maximum: 3)),
                                                                      number: .override(.random(minimum: -3, maximum: 4)),
                                                                      array: .override(.randomLength(range: 1..<32)),
                                                                      date: .override(.increments(from: Date(), by: 30)),
                                                                      string: .override(.static("path")))
}

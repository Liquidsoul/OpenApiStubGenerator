@testable import SwaggerFaker
import XCTest

class ConfigurationTests: XCTestCase {
    func test_loadJSONObject_empty() throws {
        let configurationData = [String: Any]()

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    // MARK: - Array

    func test_loadJSONObject_defaults_arrayConfiguration() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "array": [
                    "type": "randomLength",
                    "minimum": 4,
                    "maximum": 6
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .randomLength(range: 4..<7))
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_arrayConfiguration_uniqueLength() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "array": [
                    "type": "randomLength",
                    "minimum": 4,
                    "maximum": 4
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .randomLength(range: 4..<5))
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_arrayConfiguration_invalid() {
        let configurationData: [String: Any] = [
            "defaults": [
                "array": [
                    "minimum": 6,
                    "maximum": 5
                ]
            ]
        ]

        XCTAssertThrowsError(try Configuration(jsonObject: configurationData))
    }

    // MARK: - Date

    func test_loadJSONObject_defaults_dateConfiguration_now() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "date": [
                    "type": "now"
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .now)
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_dateConfiguration_static() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "date": [
                    "type": "static",
                    "value": "2020-11-12T12:54:38.000Z"
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .static(Date(timeIntervalSince1970: 1_605_185_678)))
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_dateConfiguration_random() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "date": [
                    "type": "random",
                    "from": "2020-11-14T21:58:52.000Z",
                    "to": "2020-11-18T21:58:52.000Z"
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .random(after: Date(timeIntervalSince1970: 1605391132), before: Date(timeIntervalSince1970: 1605736732)))
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_dateConfiguration_random_invalid() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "date": [
                    "type": "random",
                    "from": "2020-11-18T21:58:52.000Z",
                    "to": "2020-11-14T21:58:52.000Z"
                ]
            ]
        ]

        XCTAssertThrowsError(try Configuration(jsonObject: configurationData))
    }

    func test_loadJSONObject_defaults_dateConfiguration_increments() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "date": [
                    "type": "increments",
                    "from": "2020-11-18T21:58:52.000Z",
                    "incrementInSeconds": 25
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .increments(from: Date(timeIntervalSince1970: 1605736732), by: 25))
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_dateConfiguration_increments_from_now() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "date": [
                    "type": "increments",
                    "from": "now",
                    "incrementInSeconds": 25
                ]
            ]
        ]

        let previousDate = Date()
        let configuration = try Configuration(jsonObject: configurationData)
        let nextDate = Date()

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.string, .default)
        guard case let .increments(from, increment) = configuration.date else {
            return XCTFail()
        }
        XCTAssertEqual(increment, 25)
        XCTAssertTrue(previousDate <= from)
        XCTAssertTrue(from <= nextDate)
    }

    // MARK: - String

    func test_loadJSONObject_defaults_stringConfiguration_static() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "string": [
                    "type": "static",
                    "value": "staticValue"
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .static("staticValue"))
    }

    func test_loadJSONObject_defaults_stringConfiguration_faker() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "string": [
                    "type": "faker"
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .faker)
    }

    func test_loadJSONObject_defaults_stringConfiguration_randomFromList() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "string": [
                    "type": "randomFromList",
                    "list": ["List", "of", "strings"]
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)

        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .randomFromList(["List", "of", "strings"]))
    }

    // MARK: - Integer

    func test_loadJSONObject_defaults_integerConfiguration_faker() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "integer": [
                    "type": "faker"
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)
        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .faker)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_integerConfiguration_random() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "integer": [
                    "type": "random",
                    "minimum": 5,
                    "maximum": 10,
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)
        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .random(minimum: 5, maximum: 10))
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    // MARK: - Number

    func test_loadJSONObject_defaults_numberConfiguration_faker() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "number": [
                    "type": "faker"
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)
        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .faker)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_numberConfiguration_random() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "number": [
                    "type": "random",
                    "minimum": 5.2,
                    "maximum": 10.4,
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)
        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .random(minimum: 5.2, maximum: 10.4))
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_numberConfiguration_random_withJSONIntegerValues() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "number": [
                    "type": "random",
                    "minimum": 5,
                    "maximum": 10,
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)
        XCTAssertEqual(configuration.boolean, .default)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .random(minimum: 5, maximum: 10))
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    // MARK: - Boolean

    func test_loadJSONObject_defaults_booleanConfiguration_faker() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "boolean": [
                    "type": "faker"
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)
        XCTAssertEqual(configuration.boolean, .faker)
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_booleanConfiguration_static_true() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "boolean": [
                    "type": "static",
                    "value": true
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)
        XCTAssertEqual(configuration.boolean, .static(true))
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }

    func test_loadJSONObject_defaults_booleanConfiguration_static_false() throws {
        let configurationData: [String: Any] = [
            "defaults": [
                "boolean": [
                    "type": "static",
                    "value": false
                ]
            ]
        ]

        let configuration = try Configuration(jsonObject: configurationData)
        XCTAssertEqual(configuration.boolean, .static(false))
        XCTAssertEqual(configuration.integer, .default)
        XCTAssertEqual(configuration.number, .default)
        XCTAssertEqual(configuration.array, .default)
        XCTAssertEqual(configuration.date, .default)
        XCTAssertEqual(configuration.string, .default)
    }
}
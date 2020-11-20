import Fakery
import Foundation
import Swagger

struct BooleanGenerator {
    private let faker = Faker()
    let config: Config

    func generate() -> Bool {
        switch config {
        case .faker:
            return faker.number.randomBool()
        case .static(let value):
            return value
        }
    }

    enum Config: Equatable {
        case faker
        case `static`(Bool)

        static let `default`: Config = .faker
    }
}

extension BooleanGenerator.Config {
    init?(jsonObject: [String: Any]) throws {
        let booleanKey = "boolean"
        guard let booleanValue = jsonObject[booleanKey] else { return nil }
        guard let booleanJson = booleanValue as? [String: Any] else { throw ConfigurationLoadingError.invalidType(key: booleanKey) }

        let typeKey = "type"
        guard let typeValue = booleanJson[typeKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [booleanKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "faker":
            self = .faker
        case "static":
            let valueKey = "value"

            guard let staticValue = booleanJson[valueKey] as? Bool else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [booleanKey, valueKey].joined(separator: ".")) }

            self = .static(staticValue)
        default:
            throw ConfigurationLoadingError.invalidConfiguration(config: booleanJson)
        }
    }
}

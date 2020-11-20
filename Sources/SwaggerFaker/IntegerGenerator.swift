import Fakery
import Foundation
import Swagger

struct IntegerGenerator {
    private let faker = Faker()
    let mode: Mode

    func generate(from schema: IntegerSchema) -> Int {
        if let minimum = self.minimum(from: schema), let maximum = self.maximum(from: schema), minimum == maximum {
            return minimum
        } else if let minimum = self.minimum(from: schema), let maximum = self.maximum(from: schema), minimum < maximum {
            return faker.number.randomInt(min: minimum, max: maximum)
        } else if let minimum = self.minimum(from: schema) {
            return faker.number.randomInt(min: minimum, max: .max)
        } else if let maximum = self.maximum(from: schema) {
            return faker.number.randomInt(min: .min, max: maximum)
        } else {
            return faker.number.randomInt()
        }
    }

    private func minimum(from schema: IntegerSchema) -> Int? {
        guard case let .random(modeMinimum, _) = mode else {
            return schema.minimum
        }
        guard let schemaMinimum = schema.minimum else {
            return modeMinimum
        }
        if modeMinimum < schemaMinimum {
            return schemaMinimum
        }
        return modeMinimum
    }

    private func maximum(from schema: IntegerSchema) -> Int? {
        guard case let .random(_, modeMaximum) = mode else {
            return schema.maximum
        }
        guard let schemaMaximum = schema.maximum else {
            return modeMaximum
        }
        if schemaMaximum < modeMaximum {
            return schemaMaximum
        }
        return modeMaximum
    }

    enum Mode: Equatable {
        case faker
        case random(minimum: Int, maximum: Int)

        static let `default`: Mode = .faker
    }
}

extension IntegerGenerator.Mode {
    init?(jsonObject: [String: Any]) throws {
        let integerKey = "integer"
        guard let integerValue = jsonObject[integerKey] else { return nil }
        guard let integerJson = integerValue as? [String: Any] else { throw ConfigurationLoadingError.invalidType(key: integerKey) }

        let typeKey = "type"
        guard let typeValue = integerJson[typeKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [integerKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "faker":
            self = .faker
        case "random":
            let minimumKey = "minimum"
            guard let minimumValue = integerJson[minimumKey] as? Int else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [integerKey, minimumKey].joined(separator: ".")) }
            let maximumKey = "maximum"
            guard let maximumValue = integerJson[maximumKey] as? Int else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [integerKey, maximumKey].joined(separator: ".")) }

            guard minimumValue <= maximumValue else { throw ConfigurationLoadingError.invalidConfiguration(config: integerJson) }

            self = .random(minimum: minimumValue, maximum: maximumValue)
        default:
            throw ConfigurationLoadingError.invalidConfiguration(config: integerJson)
        }
    }
}

import Fakery
import Swagger

struct NumberGenerator {
    private let faker = Faker()
    let config: Config

    func generate(from schema: NumberSchema) -> Double {
        if let minimum = self.minimum(from: schema), let maximum = self.maximum(from: schema), minimum == maximum {
            return minimum
        } else if let minimum = self.minimum(from: schema), let maximum = self.maximum(from: schema), minimum < maximum {
            return faker.number.randomDouble(min: minimum, max: maximum)
        } else if let minimum = self.minimum(from: schema) {
            return faker.number.randomDouble(min: minimum, max: .greatestFiniteMagnitude)
        } else if let maximum = self.maximum(from: schema) {
            return faker.number.randomDouble(min: -.greatestFiniteMagnitude, max: maximum)
        } else {
            return faker.number.randomDouble()
        }
    }

    private func minimum(from schema: NumberSchema) -> Double? {
        guard case let .random(configMinimum, _) = config else {
            return schema.minimum
        }
        guard let schemaMinimum = schema.minimum else {
            return configMinimum
        }
        if configMinimum < schemaMinimum {
            return schemaMinimum
        }
        return configMinimum
    }

    private func maximum(from schema: NumberSchema) -> Double? {
        guard case let .random(_, configMaximum) = config else {
            return schema.maximum
        }
        guard let schemaMaximum = schema.maximum else {
            return configMaximum
        }
        if schemaMaximum < configMaximum {
            return schemaMaximum
        }
        return configMaximum
    }

    enum Config: Equatable {
        case faker
        case random(minimum: Double, maximum: Double)

        static let `default`: Config = .faker
    }
}

extension NumberGenerator.Config {
    init?(jsonObject: [String: Any]) throws {
        let numberKey = "number"
        guard let numberValue = jsonObject[numberKey] else { return nil }
        guard let numberJson = numberValue as? [String: Any] else { throw ConfigurationLoadingError.invalidType(key: numberKey) }

        let typeKey = "type"
        guard let typeValue = numberJson[typeKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [numberKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "faker":
            self = .faker
        case "random":
            let minimumKey = "minimum"
            guard let minimum = numberJson[minimumKey],
                  let minimumValue = minimum as? Double ?? (minimum as? Int).map(Double.init) else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [numberKey, minimumKey].joined(separator: ".")) }
            let maximumKey = "maximum"
            guard let maximum = numberJson[maximumKey],
                  let maximumValue = maximum as? Double ?? (maximum as? Int).map(Double.init) else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [numberKey, maximumKey].joined(separator: ".")) }

            guard minimumValue <= maximumValue else { throw ConfigurationLoadingError.invalidConfiguration(config: numberJson) }

            self = .random(minimum: minimumValue, maximum: maximumValue)
        default:
            throw ConfigurationLoadingError.invalidConfiguration(config: numberJson)
        }
    }
}

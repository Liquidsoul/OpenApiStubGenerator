import Fakery
import Foundation
import Swagger

struct IntegerGenerator {
    private let faker = Faker()
    let config: Config

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

    private func maximum(from schema: IntegerSchema) -> Int? {
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
        case random(minimum: Int, maximum: Int)

        static let `default`: Config = .faker
    }
}

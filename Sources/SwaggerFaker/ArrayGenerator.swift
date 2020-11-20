import Swagger

class ArrayGenerator {
    let config: Config

    init(config: Config) {
        self.config = config
    }

    func generate(arraySchema: ArraySchema, generator: (SchemaType, _ index: Int) -> Any) -> [Any] {
        switch arraySchema.items {
        case .single(let schema):
            return (0..<config.length).map { index -> Any in
                generator(schema.type, index)
            }
        case .multiple(let schemas):
            guard let first = schemas.first else {
                return []
            }
            return (0..<config.length).map { index -> Any in
                let schema = schemas.randomElement() ?? first
                return generator(schema.type, index)
            }
        }
    }

    enum Config: Equatable {
        case randomLength(range: Range<Int>)

        static let `default`: Config = .randomLength(range: 1..<5)

        var length: Int {
            switch self {
            case .randomLength(let range):
                return range.randomElement() as Int? ?? 0
            }
        }
    }
}

extension ArrayGenerator.Config {
    init?(jsonObject: [String: Any]) throws {
        let arrayKey = "array"
        guard let arrayValue = jsonObject[arrayKey] else { return nil }
        guard let arrayJson = arrayValue as? [String: Any] else { throw ConfigurationLoadingError.invalidType(key: arrayKey) }

        let typeKey = "type"
        guard let typeValue = arrayJson[typeKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [arrayKey, typeKey].joined(separator: ".")) }
        guard typeValue == "randomLength" else { throw ConfigurationLoadingError.invalidConfiguration(config: arrayJson) }

        let minimumKey = "minimum"
        guard let minimumValue = arrayJson[minimumKey] as? Int else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [arrayKey, minimumKey].joined(separator: ".")) }
        let maximumKey = "maximum"
        guard let maximumValue = arrayJson[maximumKey] as? Int else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [arrayKey, maximumKey].joined(separator: ".")) }

        guard minimumValue <= maximumValue else { throw ConfigurationLoadingError.invalidConfiguration(config: arrayJson) }

        self = .randomLength(range: minimumValue..<(maximumValue + 1))
    }
}

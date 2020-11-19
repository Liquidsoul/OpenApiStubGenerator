import Foundation

public struct Configuration {
    let boolean: BooleanGenerator.Config
    let integer: IntegerGenerator.Config
    let number: NumberGenerator.Config
    let array: ArrayGenerator.Config
    let date: DateGenerator.Config
    let string: StringGenerator.Config

    public static let `default`: Configuration = .init(boolean: .default,
                                                       integer: .default,
                                                       number: .default,
                                                       array: .default,
                                                       date: .default,
                                                       string: .default)

    init(boolean: BooleanGenerator.Config,
         integer: IntegerGenerator.Config,
         number: NumberGenerator.Config,
         array: ArrayGenerator.Config,
         date: DateGenerator.Config,
         string: StringGenerator.Config) {
        self.boolean = boolean
        self.integer = integer
        self.number = number
        self.array = array
        self.date = date
        self.string = string
    }
}

public extension Configuration {
    init(json: Any) throws {
        guard let jsonObject = json as? [String: Any] else {
            throw Error.noRootJSONObject
        }
        try self.init(jsonObject: jsonObject)
    }

    init(jsonObject: [String: Any]) throws {
        let (boolean, integer, number, array, date, string) = try type(of: self).loadDefaults(jsonObject: jsonObject)
        self.init(boolean: boolean ?? .default,
                  integer: integer ?? .default,
                  number: number ?? .default,
                  array: array ?? .default,
                  date: date ?? .default,
                  string: string ?? .default)
    }

    private static func loadDefaults(jsonObject: [String: Any]) throws -> (BooleanGenerator.Config?, IntegerGenerator.Config?, NumberGenerator.Config?, ArrayGenerator.Config?, DateGenerator.Config?, StringGenerator.Config?) {
        let defaultsKey = "defaults"
        guard let defaultsValue = jsonObject[defaultsKey] else {
            return (nil, nil, nil, nil, nil, nil)
        }
        guard let defaults = defaultsValue as? [String: Any] else {
            throw Error.invalidType(key: defaultsKey)
        }
        return (try loadBooleanConfig(jsonObject: defaults),
                try loadIntegerConfig(jsonObject: defaults),
                try loadNumberConfig(jsonObject: defaults),
                try loadArrayConfig(jsonObject: defaults),
                try loadDateConfig(jsonObject: defaults),
                try loadStringConfig(jsonObject: defaults))
    }

    private static func loadBooleanConfig(jsonObject: [String: Any]) throws -> BooleanGenerator.Config? {
        let booleanKey = "boolean"
        guard let booleanValue = jsonObject[booleanKey] else { return nil }
        guard let booleanJson = booleanValue as? [String: Any] else { throw Error.invalidType(key: booleanKey) }

        let typeKey = "type"
        guard let typeValue = booleanJson[typeKey] as? String else { throw Error.missingKeyOrInvalidType(key: [booleanKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "faker":
            return .faker
        case "static":
            let valueKey = "value"

            guard let staticValue = booleanJson[valueKey] as? Bool else { throw Error.missingKeyOrInvalidType(key: [booleanKey, valueKey].joined(separator: ".")) }

            return .static(staticValue)
        default:
            throw Error.invalidConfiguration(config: booleanJson)
        }
    }

    private static func loadIntegerConfig(jsonObject: [String: Any]) throws -> IntegerGenerator.Config? {
        let integerKey = "integer"
        guard let integerValue = jsonObject[integerKey] else { return nil }
        guard let integerJson = integerValue as? [String: Any] else { throw Error.invalidType(key: integerKey) }

        let typeKey = "type"
        guard let typeValue = integerJson[typeKey] as? String else { throw Error.missingKeyOrInvalidType(key: [integerKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "faker":
            return .faker
        case "random":
            let minimumKey = "minimum"
            guard let minimumValue = integerJson[minimumKey] as? Int else { throw Error.missingKeyOrInvalidType(key: [integerKey, minimumKey].joined(separator: ".")) }
            let maximumKey = "maximum"
            guard let maximumValue = integerJson[maximumKey] as? Int else { throw Error.missingKeyOrInvalidType(key: [integerKey, maximumKey].joined(separator: ".")) }

            guard minimumValue <= maximumValue else { throw Error.invalidConfiguration(config: integerJson) }

            return .random(minimum: minimumValue, maximum: maximumValue)
        default:
            throw Error.invalidConfiguration(config: integerJson)
        }
    }

    private static func loadNumberConfig(jsonObject: [String: Any]) throws -> NumberGenerator.Config? {
        let numberKey = "number"
        guard let numberValue = jsonObject[numberKey] else { return nil }
        guard let numberJson = numberValue as? [String: Any] else { throw Error.invalidType(key: numberKey) }

        let typeKey = "type"
        guard let typeValue = numberJson[typeKey] as? String else { throw Error.missingKeyOrInvalidType(key: [numberKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "faker":
            return .faker
        case "random":
            let minimumKey = "minimum"
            guard let minimum = numberJson[minimumKey],
                  let minimumValue = minimum as? Double ?? (minimum as? Int).map(Double.init) else { throw Error.missingKeyOrInvalidType(key: [numberKey, minimumKey].joined(separator: ".")) }
            let maximumKey = "maximum"
            guard let maximum = numberJson[maximumKey],
                  let maximumValue = maximum as? Double ?? (maximum as? Int).map(Double.init) else { throw Error.missingKeyOrInvalidType(key: [numberKey, maximumKey].joined(separator: ".")) }

            guard minimumValue <= maximumValue else { throw Error.invalidConfiguration(config: numberJson) }

            return .random(minimum: minimumValue, maximum: maximumValue)
        default:
            throw Error.invalidConfiguration(config: numberJson)
        }
    }

    private static func loadArrayConfig(jsonObject: [String: Any]) throws -> ArrayGenerator.Config? {
        let arrayKey = "array"
        guard let arrayValue = jsonObject[arrayKey] else { return nil }
        guard let arrayJson = arrayValue as? [String: Any] else { throw Error.invalidType(key: arrayKey) }

        let typeKey = "type"
        guard let typeValue = arrayJson[typeKey] as? String else { throw Error.missingKeyOrInvalidType(key: [arrayKey, typeKey].joined(separator: ".")) }
        guard typeValue == "randomLength" else { throw Error.invalidConfiguration(config: arrayJson) }

        let minimumKey = "minimum"
        guard let minimumValue = arrayJson[minimumKey] as? Int else { throw Error.missingKeyOrInvalidType(key: [arrayKey, minimumKey].joined(separator: ".")) }
        let maximumKey = "maximum"
        guard let maximumValue = arrayJson[maximumKey] as? Int else { throw Error.missingKeyOrInvalidType(key: [arrayKey, maximumKey].joined(separator: ".")) }

        guard minimumValue <= maximumValue else { throw Error.invalidConfiguration(config: arrayJson) }

        return .randomLength(range: minimumValue..<(maximumValue + 1))
    }

    private static func loadDateConfig(jsonObject: [String: Any]) throws -> DateGenerator.Config? {
        let dateKey = "date"
        guard let dateValue = jsonObject[dateKey] else { return nil }
        guard let dateJson = dateValue as? [String: Any] else { throw Error.invalidType(key: dateKey) }

        let typeKey = "type"
        guard let typeValue = dateJson[typeKey] as? String else { throw Error.missingKeyOrInvalidType(key: [dateKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "now":
            return .now
        case "static":
            let valueKey = "value"
            guard let value = dateJson[valueKey] as? String else { throw Error.missingKeyOrInvalidType(key: [dateKey, valueKey].joined(separator: "."))}
            guard let dateValue = dateFormatter.date(from: value) else {
                throw Error.invalidConfiguration(config: dateJson)
            }
            return .static(dateValue)
        case "random":
            let fromKey = "from"
            guard let fromValue = dateJson[fromKey] as? String else { throw Error.missingKeyOrInvalidType(key: [dateKey, fromKey].joined(separator: "."))}
            guard let fromDateValue = dateFormatter.date(from: fromValue) else { throw Error.invalidConfiguration(config: dateJson) }
            let toKey = "to"
            guard let toValue = dateJson[toKey] as? String else { throw Error.missingKeyOrInvalidType(key: [dateKey, toKey].joined(separator: "."))}
            guard let toDateValue = dateFormatter.date(from: toValue) else { throw Error.invalidConfiguration(config: dateJson) }
            guard fromDateValue <= toDateValue else { throw Error.invalidConfiguration(config: dateJson) }
            return .random(after: fromDateValue, before: toDateValue)
        case "increments":
            let fromKey = "from"
            guard let fromValue = dateJson[fromKey] as? String else { throw Error.missingKeyOrInvalidType(key: [dateKey, fromKey].joined(separator: "."))}
            let referenceDateValue: Date
            if let fromDateValue = dateFormatter.date(from: fromValue) {
                referenceDateValue = fromDateValue
            } else if fromValue == "now" {
                referenceDateValue = Date()
            } else {
                throw Error.invalidConfiguration(config: dateJson)
            }
            let incrementKey = "incrementInSeconds"
            guard let incrementValue = dateJson[incrementKey] as? Int else { throw Error.missingKeyOrInvalidType(key: [dateKey, incrementKey].joined(separator: "."))}
            return .increments(from: referenceDateValue, by: TimeInterval(incrementValue))
        default:
            throw Error.invalidConfiguration(config: dateJson)
        }
    }

    private static func loadStringConfig(jsonObject: [String: Any]) throws -> StringGenerator.Config? {
        let stringKey = "string"
        guard let stringValue = jsonObject[stringKey] else { return nil }
        guard let stringJson = stringValue as? [String: Any] else { throw Error.invalidType(key: stringKey) }

        let typeKey = "type"
        guard let typeValue = stringJson[typeKey] as? String else { throw Error.missingKeyOrInvalidType(key: [stringKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "faker":
            return .faker
        case "static":
            let valueKey = "value"
            guard let value = stringJson[valueKey] as? String else { throw Error.missingKeyOrInvalidType(key: [stringKey, valueKey].joined(separator: "."))}
            return .static(value)
        case "randomFromList":
            let listKey = "list"
            guard let listValue = stringJson[listKey] as? [String] else { throw Error.missingKeyOrInvalidType(key: [stringKey, listKey].joined(separator: "."))}
            return .randomFromList(listValue)
        default:
            throw Error.invalidConfiguration(config: stringJson)
        }
    }

    static let dateFormatter = ISO8601DateFormatter().withFormatOptions([.withInternetDateTime, .withFractionalSeconds])

    enum Error: Swift.Error {
        case noRootJSONObject
        case invalidType(key: String)
        case missingKeyOrInvalidType(key: String)
        case invalidConfiguration(config: [String: Any])
    }
}

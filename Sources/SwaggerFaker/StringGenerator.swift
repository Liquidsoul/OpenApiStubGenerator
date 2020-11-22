import Fakery
import Foundation
import Swagger

struct StringGenerator {
    private let faker = Faker()
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    let mode: Mode
    let dateGenerator: StringDateGenerator

    func generate(from schema: StringSchema) -> String {
        if case let .format(formatType) = schema.format, formatType == .date || formatType == .dateTime {
            return dateGenerator.generate()
        }
        switch mode {
        case .faker:
            return fakerGenerate(schema: schema)
        case .static(let staticString):
            return staticString
        case .randomFromList(let list):
            guard let first = list.first else { return "" }
            return list.randomElement() ?? first
        }
    }

    private func fakerGenerate(schema: StringSchema) -> String {
        guard let format = schema.format else {
            return faker.lorem.word()
        }
        switch format {
        case .format(let stringFormatType):
            return fakerGenerate(stringFormatType: stringFormatType)
        case .other(let otherFormat):
            return "_otherFormat(\(otherFormat))"
        }
    }

    private func fakerGenerate(stringFormatType: StringFormat.StringFormatType) -> String {
        switch stringFormatType {
        case .date, .dateTime:
            return dateGenerator.generate()
        case .email:
            return faker.internet.email()
        case .password:
            return faker.internet.password()
        case .uuid:
            return UUID().uuidString
        case .uri:
            return faker.internet.url()
        case .binary, .byte, .base64:
            let string = faker.lorem.sentence()
            guard let data = string.data(using: .utf8) else {
                fatalError("Failed to encode '\(string)' in ut8")
            }
            return data.base64EncodedString()
        case .hostname:
            return faker.internet.domainName()
        case .ipv4:
            return faker.internet.ipV4Address()
        case .ipv6:
            return faker.internet.ipV6Address()
        }
    }

    enum Mode: Equatable {
        case faker
        case `static`(String)
        case randomFromList([String])
    }
}

protocol StringDateGenerator {
    var dateFormatter: ISO8601DateFormatter { get }

    func generate() -> String
    func generateDate() -> Date
}

extension StringDateGenerator {
    func generate() -> String {
        return dateFormatter.string(from: generateDate())
    }
}

extension StringGenerator.Mode: JSONObjectLoadable {
    init?(jsonObject: [String: Any]) throws {
        let stringKey = "string"
        guard let stringValue = jsonObject[stringKey] else { return nil }
        guard let stringJson = stringValue as? [String: Any] else { throw ConfigurationLoadingError.invalidType(key: stringKey) }

        let typeKey = "type"
        guard let typeValue = stringJson[typeKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [stringKey, typeKey].joined(separator: ".")) }

        switch typeValue {
        case "faker":
            self = .faker
        case "static":
            let valueKey = "value"
            guard let value = stringJson[valueKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [stringKey, valueKey].joined(separator: "."))}
            self = .static(value)
        case "randomFromList":
            let listKey = "list"
            guard let listValue = stringJson[listKey] as? [String] else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [stringKey, listKey].joined(separator: "."))}
            self = .randomFromList(listValue)
        default:
            throw ConfigurationLoadingError.invalidConfiguration(config: stringJson)
        }
    }
}

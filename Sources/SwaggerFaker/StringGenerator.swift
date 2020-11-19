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
    let config: Config
    let dateGenerator: StringDateGenerator

    func generate(from schema: StringSchema) -> String {
        switch config {
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

    enum Config: Equatable {
        case faker
        case `static`(String)
        case randomFromList([String])

        static let `default`: Config = .faker
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

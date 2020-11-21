import Fakery
import Foundation

class DateGenerator: StringDateGenerator {
    private let mode: Mode
    private let faker = Faker()

    private var incrementCounter = 0

    init(mode: Mode) {
        self.mode = mode
    }

    func generateDate() -> Date {
        switch mode {
        case .now:
            return Date()
        case .static(let date):
            return date
        case let .random(from, to):
            return faker.date.between(from, to)
        case let .increments(from, increment):
            let date = from.addingTimeInterval(increment * TimeInterval(incrementCounter))
            incrementCounter += 1
            return date
        }
    }

    enum Mode: Equatable {
        case `static`(Date)
        case now
        case increments(from: Date, by: TimeInterval)
        case random(after: Date, before: Date)
    }

    lazy var dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter().withFormatOptions([.withInternetDateTime, .withFractionalSeconds])
}

extension ISO8601DateFormatter {
    func withFormatOptions(_ options: Options) -> ISO8601DateFormatter {
        self.formatOptions = options
        return self
    }
}

extension DateGenerator.Mode: JSONObjectLoadable {
    init?(jsonObject: [String: Any]) throws {
        let dateKey = "date"
        guard let dateValue = jsonObject[dateKey] else { return nil }
        guard let dateJson = dateValue as? [String: Any] else { throw ConfigurationLoadingError.invalidType(key: dateKey) }

        let typeKey = "type"
        guard let typeValue = dateJson[typeKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [dateKey, typeKey].joined(separator: ".")) }

        let dateFormatter = type(of: self).dateFormatter

        switch typeValue {
        case "now":
            self = .now
        case "static":
            let valueKey = "value"
            guard let value = dateJson[valueKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [dateKey, valueKey].joined(separator: "."))}
            guard let dateValue = dateFormatter.date(from: value) else {
                throw ConfigurationLoadingError.invalidConfiguration(config: dateJson)
            }
            self = .static(dateValue)
        case "random":
            let fromKey = "from"
            guard let fromValue = dateJson[fromKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [dateKey, fromKey].joined(separator: "."))}
            guard let fromDateValue = dateFormatter.date(from: fromValue) else { throw ConfigurationLoadingError.invalidConfiguration(config: dateJson) }
            let toKey = "to"
            guard let toValue = dateJson[toKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [dateKey, toKey].joined(separator: "."))}
            guard let toDateValue = dateFormatter.date(from: toValue) else { throw ConfigurationLoadingError.invalidConfiguration(config: dateJson) }
            guard fromDateValue <= toDateValue else { throw ConfigurationLoadingError.invalidConfiguration(config: dateJson) }
            self = .random(after: fromDateValue, before: toDateValue)
        case "increments":
            let fromKey = "from"
            guard let fromValue = dateJson[fromKey] as? String else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [dateKey, fromKey].joined(separator: "."))}
            let referenceDateValue: Date
            if let fromDateValue = dateFormatter.date(from: fromValue) {
                referenceDateValue = fromDateValue
            } else if fromValue == "now" {
                referenceDateValue = Date()
            } else {
                throw ConfigurationLoadingError.invalidConfiguration(config: dateJson)
            }
            let incrementKey = "incrementInSeconds"
            guard let incrementValue = dateJson[incrementKey] as? Int else { throw ConfigurationLoadingError.missingKeyOrInvalidType(key: [dateKey, incrementKey].joined(separator: "."))}
            self = .increments(from: referenceDateValue, by: TimeInterval(incrementValue))
        default:
            throw ConfigurationLoadingError.invalidConfiguration(config: dateJson)
        }
    }

    static let dateFormatter = ISO8601DateFormatter().withFormatOptions([.withInternetDateTime, .withFractionalSeconds])
}

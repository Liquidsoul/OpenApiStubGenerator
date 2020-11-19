import Fakery
import Foundation

class DateGenerator: StringDateGenerator {
    let config: Config
    let faker = Faker()

    private var incrementCounter = 0

    init(config: Config) {
        self.config = config
    }

    func generateDate() -> Date {
        switch config {
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

    enum Config: Equatable {
        case `static`(Date)
        case now
        case increments(from: Date, by: TimeInterval)
        case random(after: Date, before: Date)

        static let `default`: Config = .random(after: Date().addingTimeInterval(-48 * 3600), before: Date().addingTimeInterval(48 * 3600))
    }

    lazy var dateFormatter: ISO8601DateFormatter = ISO8601DateFormatter().withFormatOptions([.withInternetDateTime, .withFractionalSeconds])
}

extension ISO8601DateFormatter {
    func withFormatOptions(_ options: Options) -> ISO8601DateFormatter {
        self.formatOptions = options
        return self
    }
}

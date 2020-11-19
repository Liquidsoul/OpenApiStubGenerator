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

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

struct GeneratorConfigurations: Equatable {
    let boolean: BooleanGenerator.Config
    let integer: IntegerGenerator.Config
    let number: NumberGenerator.Config
    let array: ArrayGenerator.Config
    let date: DateGenerator.Config
    let string: StringGenerator.Config

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

    static let `default`: GeneratorConfigurations = .init(boolean: .default,
                                                          integer: .default,
                                                          number: .default,
                                                          array: .default,
                                                          date: .default,
                                                          string: .default)
}

extension GeneratorConfigurations {
    init(jsonObject: [String: Any]) throws {
        self.init(boolean: try BooleanGenerator.Config(jsonObject: jsonObject) ?? .default,
                  integer: try IntegerGenerator.Config(jsonObject: jsonObject) ?? .default,
                  number: try NumberGenerator.Config(jsonObject: jsonObject) ?? .default,
                  array: try ArrayGenerator.Config(jsonObject: jsonObject) ?? .default,
                  date: try DateGenerator.Config(jsonObject: jsonObject) ?? .default,
                  string: try StringGenerator.Config(jsonObject: jsonObject) ?? .default)
    }
}

extension GeneratorGroup {
    struct Configuration: Equatable {
        let boolean: BooleanGenerator.Mode
        let integer: IntegerGenerator.Mode
        let number: NumberGenerator.Mode
        let array: ArrayGenerator.Mode
        let date: DateGenerator.Mode
        let string: StringGenerator.Mode

        init(boolean: BooleanGenerator.Mode,
             integer: IntegerGenerator.Mode,
             number: NumberGenerator.Mode,
             array: ArrayGenerator.Mode,
             date: DateGenerator.Mode,
             string: StringGenerator.Mode) {
            self.boolean = boolean
            self.integer = integer
            self.number = number
            self.array = array
            self.date = date
            self.string = string
        }

        static let `default`: Configuration = .init(boolean: .default,
                                                    integer: .default,
                                                    number: .default,
                                                    array: .default,
                                                    date: .default,
                                                    string: .default)
    }
}

extension GeneratorGroup.Configuration {
    init(jsonObject: [String: Any]) throws {
        self.init(boolean: try BooleanGenerator.Mode(jsonObject: jsonObject) ?? .default,
                  integer: try IntegerGenerator.Mode(jsonObject: jsonObject) ?? .default,
                  number: try NumberGenerator.Mode(jsonObject: jsonObject) ?? .default,
                  array: try ArrayGenerator.Mode(jsonObject: jsonObject) ?? .default,
                  date: try DateGenerator.Mode(jsonObject: jsonObject) ?? .default,
                  string: try StringGenerator.Mode(jsonObject: jsonObject) ?? .default)
    }
}

extension GeneratorGroup {
    struct Configuration: Equatable {
        var boolean: GeneratorConfig<BooleanGenerator.Mode>
        var integer: GeneratorConfig<IntegerGenerator.Mode>
        var number: GeneratorConfig<NumberGenerator.Mode>
        var array: GeneratorConfig<ArrayGenerator.Mode>
        var date: GeneratorConfig<DateGenerator.Mode>
        var string: GeneratorConfig<StringGenerator.Mode>

        init(boolean: GeneratorConfig<BooleanGenerator.Mode>,
             integer: GeneratorConfig<IntegerGenerator.Mode>,
             number: GeneratorConfig<NumberGenerator.Mode>,
             array: GeneratorConfig<ArrayGenerator.Mode>,
             date: GeneratorConfig<DateGenerator.Mode>,
             string: GeneratorConfig<StringGenerator.Mode>) {
            self.boolean = boolean
            self.integer = integer
            self.number = number
            self.array = array
            self.date = date
            self.string = string
        }
    }
}

extension GeneratorGroup.Configuration {
    init(jsonObject: [String: Any]) throws {
        try self.init(boolean: .init(jsonObject: jsonObject),
                      integer: .init(jsonObject: jsonObject),
                      number: .init(jsonObject: jsonObject),
                      array: .init(jsonObject: jsonObject),
                      date: .init(jsonObject: jsonObject),
                      string: .init(jsonObject: jsonObject))
    }

    func overridden(with configuration: GeneratorGroup.Configuration) -> GeneratorGroup.Configuration {
        return .init(boolean: boolean.override != nil ? boolean : configuration.boolean,
                     integer: integer.override != nil ? integer : configuration.integer,
                     number: number.override != nil ? number : configuration.number,
                     array: array.override != nil ? array : configuration.array,
                     date: date.override != nil ? date : configuration.date,
                     string: string.override != nil ? string : configuration.string)
    }
}

struct GeneratorGroup {
    let booleanGenerator: BooleanGenerator
    let integerGenerator: IntegerGenerator
    let numberGenerator: NumberGenerator
    let stringGenerator: StringGenerator
    let arrayGenerator: ArrayGenerator
}

extension GeneratorGroup {
    init(configuration: GeneratorGroup.Configuration) {
        guard let booleanMode = configuration.boolean.override,
              let integerMode = configuration.integer.override,
              let numberMode = configuration.number.override,
              let dateMode = configuration.date.override,
              let stringMode = configuration.string.override,
              let arrayMode = configuration.array.override else {
            fatalError("Initializing a \(GeneratorGroup.self) without a defaults parameter requires all the value to be specified")
        }
        let dateGenerator = DateGenerator(mode: dateMode)
        self.init(booleanGenerator: .init(mode: booleanMode),
                  integerGenerator: .init(mode: integerMode),
                  numberGenerator: .init(mode: numberMode),
                  stringGenerator: .init(mode: stringMode, dateGenerator: dateGenerator),
                  arrayGenerator: .init(mode: arrayMode))
    }

    init(configuration: GeneratorGroup.Configuration, defaults: GeneratorGroup) {
        let dateGenerator: StringDateGenerator = configuration.date.override.map(DateGenerator.init(mode:)) ?? defaults.stringGenerator.dateGenerator
        self.init(booleanGenerator: configuration.boolean.override.map(BooleanGenerator.init(mode:)) ?? defaults.booleanGenerator,
                  integerGenerator: configuration.integer.override.map(IntegerGenerator.init(mode:)) ?? defaults.integerGenerator,
                  numberGenerator: configuration.number.override.map(NumberGenerator.init(mode:)) ?? defaults.numberGenerator,
                  stringGenerator: configuration.string.override.map { StringGenerator(mode: $0, dateGenerator: dateGenerator) } ?? defaults.stringGenerator.withDateGenerator(dateGenerator),
                  arrayGenerator: configuration.array.override.map(ArrayGenerator.init(mode:)) ?? defaults.arrayGenerator)
    }
}

extension GeneratorGroup {
    var configuration: GeneratorGroup.Configuration {
        return GeneratorGroup.Configuration(boolean: .override(booleanGenerator.mode),
                                            integer: .override(integerGenerator.mode),
                                            number: .override(numberGenerator.mode),
                                            array: .override(arrayGenerator.mode),
                                            date: .override(stringGenerator.dateGenerator.mode),
                                            string: .override(stringGenerator.mode))
    }
}

struct GeneratorGroup {
    let booleanGenerator: BooleanGenerator
    let integerGenerator: IntegerGenerator
    let numberGenerator: NumberGenerator
    let stringGenerator: StringGenerator
    let arrayGenerator: ArrayGenerator
}

extension GeneratorGroup {
    init(configuration: GeneratorConfigurations = .default) {
        let dateGenerator = DateGenerator(config: configuration.date)
        self.init(booleanGenerator: .init(config: configuration.boolean),
                  integerGenerator: .init(config: configuration.integer),
                  numberGenerator: .init(config: configuration.number),
                  stringGenerator: .init(config: configuration.string, dateGenerator: dateGenerator),
                  arrayGenerator: .init(config: configuration.array))
    }
}

struct GeneratorGroup {
    let booleanGenerator: BooleanGenerator
    let integerGenerator: IntegerGenerator
    let numberGenerator: NumberGenerator
    let stringGenerator: StringGenerator
    let arrayGenerator: ArrayGenerator
}

extension GeneratorGroup {
    init(configuration: GeneratorGroup.Configuration = .default) {
        let dateGenerator = DateGenerator(mode: configuration.date)
        self.init(booleanGenerator: .init(mode: configuration.boolean),
                  integerGenerator: .init(mode: configuration.integer),
                  numberGenerator: .init(mode: configuration.number),
                  stringGenerator: .init(mode: configuration.string, dateGenerator: dateGenerator),
                  arrayGenerator: .init(mode: configuration.array))
    }
}

import Foundation
import Swagger

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

public struct StubGenerator {
    private let generators: GeneratorGroup

    public init(configuration: Configuration = .default) {
        self.generators = GeneratorGroup(configuration: configuration.defaults)
    }

    enum Item {
        case key(String)
        case index(Int)
    }

    public func generate(schemaType: SchemaType) -> Any {
        return generate(schemaType, path: [])
    }

    func generate(_ schemaType: SchemaType, path: [Item]) -> Any {
        switch schemaType {
        case .integer(let integerSchema):
            return generate(integerSchema)
        case .string(let stringSchema):
            return generate(stringSchema)
        case .number(let numberSchema):
            return generators.numberGenerator.generate(from: numberSchema)
        case .boolean:
            return generators.booleanGenerator.generate()
        case .array(let arraySchema):
            return generate(arraySchema, path: path)
        case .object(let objectSchema):
            return generate(objectSchema, path: path)
        case .reference(let reference):
            return generate(reference.value.type, path: path)
        case .any:
            return "_any"
        case .group(let groupSchema):
            return "_groupSchema(\(groupSchema))"
        }
    }

    func generate(_ integerSchema: IntegerSchema) -> Int {
        return generators.integerGenerator.generate(from: integerSchema)
    }

    func generate(_ stringSchema: StringSchema) -> String {
        return generators.stringGenerator.generate(from: stringSchema)
    }

    func generate(_ arraySchema: ArraySchema, path: [Item]) -> [Any] {
        return generators.arrayGenerator.generate(arraySchema: arraySchema) { (schemaType, index) -> Any in
            return generate(schemaType, path: path + [.index(index)])
        }
    }

    func generate(_ objectSchema: ObjectSchema, path: [Item]) -> [String: Any] {
        return objectSchema.properties.reduce(into: [String: Any]()) { (result, property) in
            result[property.name] = generate(property.schema.type, path: path + [Item.key(property.name)])
        }
    }
}

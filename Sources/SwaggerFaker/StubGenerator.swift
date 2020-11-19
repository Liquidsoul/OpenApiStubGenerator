import Foundation
import Swagger

public struct StubGenerator {
    private let booleanGenerator: BooleanGenerator
    private let integerGenerator: IntegerGenerator
    private let numberGenerator: NumberGenerator
    private let dateGenerator: DateGenerator
    private let stringGenerator: StringGenerator
    private let arrayGenerator: ArrayGenerator

    public init(configuration: Configuration = .default) {
        self.booleanGenerator = BooleanGenerator(config: configuration.boolean)
        self.integerGenerator = IntegerGenerator(config: configuration.integer)
        self.numberGenerator = NumberGenerator(config: configuration.number)
        self.dateGenerator = DateGenerator(config: configuration.date)
        self.stringGenerator = StringGenerator(config: configuration.string, dateGenerator: dateGenerator)
        self.arrayGenerator = ArrayGenerator(config: configuration.array)
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
            return numberGenerator.generate(from: numberSchema)
        case .boolean:
            return booleanGenerator.generate()
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
        return integerGenerator.generate(from: integerSchema)
    }

    func generate(_ stringSchema: StringSchema) -> String {
        return stringGenerator.generate(from: stringSchema)
    }

    func generate(_ arraySchema: ArraySchema, path: [Item]) -> [Any] {
        return arrayGenerator.generate(arraySchema: arraySchema) { (schemaType, index) -> Any in
            return generate(schemaType, path: path + [.index(index)])
        }
    }

    func generate(_ objectSchema: ObjectSchema, path: [Item]) -> [String: Any] {
        return objectSchema.properties.reduce(into: [String: Any]()) { (result, property) in
            result[property.name] = generate(property.schema.type, path: path + [Item.key(property.name)])
        }
    }
}

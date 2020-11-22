import Foundation
import Swagger

public struct StubGenerator {

    private let generatorProvider: StubGeneratorProvider

    init(generatorProvider: StubGeneratorProvider) {
        self.generatorProvider = generatorProvider
    }

    public init(configuration: Configuration = .init()) {
        self.init(generatorProvider: GeneratorProvider(configuration: configuration))
    }

    public func generate(schemaType: SchemaType) -> Any {
        return generate(schemaType, path: .init())
    }

    func generate(_ schemaType: SchemaType, path: SchemaPath) -> Any {
        func generators() -> GeneratorGroup {
            return generatorProvider.generators(for: path)
        }
        switch schemaType {
        case .integer(let integerSchema):
            return generators().integerGenerator.generate(from: integerSchema)
        case .string(let stringSchema):
            return generators().stringGenerator.generate(from: stringSchema)
        case .number(let numberSchema):
            return generators().numberGenerator.generate(from: numberSchema)
        case .boolean:
            return generators().booleanGenerator.generate()
        case .array(let arraySchema):
            return generate(arraySchema, path: path, generators: generators())
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

    private func generate(_ arraySchema: ArraySchema, path: SchemaPath, generators: GeneratorGroup) -> [Any] {
        return generators.arrayGenerator.generate(arraySchema: arraySchema) { (schemaType, index) -> Any in
            return generate(schemaType, path: path + .index(index))
        }
    }

    func generate(_ objectSchema: ObjectSchema, path: SchemaPath) -> [String: Any] {
        return objectSchema.properties.reduce(into: [String: Any]()) { (result, property) in
            result[property.name] = generate(property.schema.type, path: path + .key(property.name))
        }
    }
}

protocol StubGeneratorProvider {
    func generators(for path: SchemaPath) -> GeneratorGroup
}

extension GeneratorProvider: StubGeneratorProvider {}

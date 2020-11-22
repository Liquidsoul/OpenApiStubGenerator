@testable import SwaggerFaker
import XCTest
import Swagger

class StubGeneratorTests: XCTestCase {
    func test_generate_invoke_provider_once_and_only_once_per_schema_path() {
        let spy = GeneratorProviderSpy(generatorGroup: GeneratorGroup(configuration: configuration))

        let sut = StubGenerator(generatorProvider: spy)

        _ = sut.generate(schemaType: testSchemaType)

        spy.pathVisitCounts.forEach { (keyValue) in
            let (path, count) = keyValue
            XCTAssertEqual(1, count, "Provider was called more than once for path: \(path)")
        }

        XCTAssertEqual(Set(spy.pathVisitCounts.keys), testSchemaPaths)
    }

    var configuration: GeneratorGroup.Configuration = .init(boolean: .override(.static(true)),
                                                            integer: .override(.random(minimum: 2, maximum: 2)),
                                                            number: .override(.random(minimum: 4, maximum: 4)),
                                                            array: .override(.randomLength(range: 2..<3)),
                                                            date: .override(.now),
                                                            string: .override(.static("staticString")))

    var testSchemaType: SchemaType {
        let currentTimeProperty = Property(name: "currentTime", required: true, schema: Schema(metadata: .init(), type: .string(StringSchema(format: .format(.dateTime)))))
        let identifierProperty = Property(name: "identifier", required: true, schema: Schema(metadata: .init(), type: .string(.init(format: .format(.uuid)))))
        let nextStopsProperty = Property(name: "nextStops", required: true, schema: Schema(metadata: .init(), type: .array(ArraySchema.init(items: .single(.init(metadata: .init(), type: .string(.init())))))))
        let requiredProperties = [currentTimeProperty, identifierProperty, nextStopsProperty]
        let nameProperty = Property(name: "name", required: false, schema: Schema(metadata: .init(), type: .string(.init())))
        let optionalProperties = [nameProperty]
        return SchemaType.object(ObjectSchema(requiredProperties: requiredProperties,
                                              optionalProperties: optionalProperties,
                                              properties: requiredProperties + optionalProperties))
    }

    var testSchemaPaths: Set<SchemaPath> {
        return .init([
            .init(path: [.key("currentTime")]),
            .init(path: [.key("identifier")]),
            .init(path: [.key("nextStops")]),
            .init(path: [.key("nextStops"), .index(0)]),
            .init(path: [.key("nextStops"), .index(1)]),
            .init(path: [.key("name")])
        ])
    }

    class GeneratorProviderSpy: StubGeneratorProvider {
        let generatorGroup: GeneratorGroup
        var pathVisitCounts = [SchemaPath: Int]()

        init(generatorGroup: GeneratorGroup) {
            self.generatorGroup = generatorGroup
        }

        func generators(for path: SchemaPath) -> GeneratorGroup {
            if let count = pathVisitCounts[path] {
                pathVisitCounts[path] = count + 1
            } else {
                pathVisitCounts[path] = 1
            }
            return generatorGroup
        }
    }
}

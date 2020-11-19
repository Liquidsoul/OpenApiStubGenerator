import ArgumentParser
import Foundation
import Swagger
import SwaggerFaker

struct Generator: ParsableCommand {
    @Option var specFile: String
    @Option var definition: String
    @Option var configFile: String?

    func run() throws {
        print("Parsing '\(specFile)'...")

        let spec = try SwaggerSpec(url: URL(fileURLWithPath: specFile))
//        print("\(spec)")

//        print("-> \(definition)")

        guard let schema = spec.components.schemas.first(where: { $0.name == definition } ) else { return }

//        print("= \(schema)")

        print(" \(schema.value.metadata.type)")

        let configuration: Configuration
        if let configurationData = try configFile
            .flatMap({ FileManager().contents(atPath: $0) })
            .flatMap({ try JSONSerialization.jsonObject(with: $0, options: []) }) {
            configuration = try Configuration(json: configurationData)
        } else {
            configuration = .default
        }

        let generator = StubGenerator(configuration: configuration)
        let stub = generator.generate(schemaType: schema.value.type)
//        print("mock: \(mock)")
        if let data = try? JSONSerialization.data(withJSONObject: stub, options: .prettyPrinted), let formattedMock = String(data: data, encoding: .utf8) {
            print("formatted mock: \(formattedMock)")
        }
    }
}

Generator.main()

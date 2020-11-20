import ArgumentParser
import Foundation
import Swagger
import SwaggerFaker

struct Generator: ParsableCommand {
    @Option var specFile: String
    @Option var definition: String
    @Option var configFile: String?
    @Flag var verbose: Bool = false

    func run() throws {
        if verbose {
            print("Parsing '\(specFile)'...")
        }

        let spec = try SwaggerSpec(url: URL(fileURLWithPath: specFile))

        guard let schema = spec.components.schemas.first(where: { $0.name == definition } ) else { return }

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
        if let data = try? JSONSerialization.data(withJSONObject: stub, options: .prettyPrinted), let formattedMock = String(data: data, encoding: .utf8) {
            if verbose { print("formatted mock:") }
            print(formattedMock)
        }
    }
}

Generator.main()

class GeneratorProvider {
    private let defaultGeneratorGroup: GeneratorGroup
    private let configuration: Configuration

    private var pathGeneratorGroups = [String: GeneratorGroup]()

    init(configuration: Configuration) {
        self.configuration = configuration
        self.defaultGeneratorGroup = GeneratorGroup(configuration: configuration.defaults)
    }

    func generators(for path: SchemaPath) -> GeneratorGroup {
        guard case let .key(name) = path.path.last else {
            return defaultGeneratorGroup
        }
        if let generatorGroup = pathGeneratorGroups[name] {
            return generatorGroup
        }
        guard let configuration = configuration.paths[name] else {
            return defaultGeneratorGroup
        }
        let generatorGroup = GeneratorGroup(configuration: configuration, defaults: defaultGeneratorGroup)
        pathGeneratorGroups[name] = generatorGroup
        return generatorGroup
    }
}

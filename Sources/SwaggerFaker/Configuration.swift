import Foundation

public struct Configuration {
    let defaults: GeneratorGroup.Configuration

    typealias Path = String

    let paths: [Path: GeneratorGroup.Configuration]

    static let defaultDefaults: GeneratorGroup.Configuration = .init(boolean: .override(.faker),
                                                                     integer: .override(.faker),
                                                                     number: .override(.faker),
                                                                     array: .override(.randomLength(range: 1..<5)),
                                                                     date: .override(.random(after: Date().addingTimeInterval(-48 * 3600), before: Date().addingTimeInterval(48 * 3600))),
                                                                     string: .override(.faker))
}

public extension Configuration {
    init() {
        self.init(defaults: type(of: self).defaultDefaults, paths: [:])
    }

    init(json: Any) throws {
        guard let jsonObject = json as? [String: Any] else {
            throw ConfigurationLoadingError.invalidConfiguration(config: json)
        }
        try self.init(jsonObject: jsonObject)
    }

    init(jsonObject: [String: Any]) throws {
        try self.init(defaults: type(of: self).loadDefaults(jsonObject: jsonObject),
                      paths: type(of: self).loadPaths(jsonObject: jsonObject))
    }

    private static func loadDefaults(jsonObject: [String: Any]) throws -> GeneratorGroup.Configuration {
        let defaultsKey = "defaults"
        guard let defaultsValue = jsonObject[defaultsKey] else {
            return self.defaultDefaults
        }
        guard let defaults = defaultsValue as? [String: Any] else {
            throw ConfigurationLoadingError.invalidType(key: defaultsKey)
        }
        return try GeneratorGroup.Configuration(jsonObject: defaults).overridden(with: self.defaultDefaults)
    }

    private static func loadPaths(jsonObject: [String: Any]) throws -> [Path: GeneratorGroup.Configuration] {
        let pathsKey = "paths"
        guard let pathsValue = jsonObject[pathsKey] else {
            return [:]
        }
        guard let paths = pathsValue as? [String: [String: Any]] else {
            throw ConfigurationLoadingError.invalidType(key: pathsKey)
        }
        return try paths.reduce(into: [Path: GeneratorGroup.Configuration]()) { (pathsConfigurations, keyValue) in
            let (path, configurationData) = keyValue
            pathsConfigurations[path] = try GeneratorGroup.Configuration(jsonObject: configurationData)
        }
    }
}

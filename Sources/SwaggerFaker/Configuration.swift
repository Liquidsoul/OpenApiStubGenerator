import Foundation

public struct Configuration {
    let defaults: GeneratorConfigurations

    typealias Path = String

    let paths: [Path: GeneratorConfigurations]

    public static let `default`: Configuration = .init(defaults: .default, paths: [:])
}

public extension Configuration {
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

    private static func loadDefaults(jsonObject: [String: Any]) throws -> GeneratorConfigurations {
        let defaultsKey = "defaults"
        guard let defaultsValue = jsonObject[defaultsKey] else {
            return .default
        }
        guard let defaults = defaultsValue as? [String: Any] else {
            throw ConfigurationLoadingError.invalidType(key: defaultsKey)
        }
        return try GeneratorConfigurations(jsonObject: defaults)
    }

    private static func loadPaths(jsonObject: [String: Any]) throws -> [Path: GeneratorConfigurations] {
        let pathsKey = "paths"
        guard let pathsValue = jsonObject[pathsKey] else {
            return [:]
        }
        guard let paths = pathsValue as? [String: [String: Any]] else {
            throw ConfigurationLoadingError.invalidType(key: pathsKey)
        }
        return try paths.reduce(into: [Path: GeneratorConfigurations]()) { (pathsConfigurations, keyValue) in
            let (path, configurationData) = keyValue
            pathsConfigurations[path] = try GeneratorConfigurations(jsonObject: configurationData)
        }
    }
}

import Foundation

public struct Configuration {
    let defaults: GeneratorConfigurations

    public static let `default`: Configuration = .init(defaults: .default)
}

public extension Configuration {
    init(json: Any) throws {
        guard let jsonObject = json as? [String: Any] else {
            throw ConfigurationLoadingError.invalidConfiguration(config: json)
        }
        try self.init(jsonObject: jsonObject)
    }

    init(jsonObject: [String: Any]) throws {
        self.init(defaults: try type(of: self).loadDefaults(jsonObject: jsonObject))
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
}

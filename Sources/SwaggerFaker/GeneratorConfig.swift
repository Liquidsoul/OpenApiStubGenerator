enum GeneratorConfig<T: Equatable & JSONObjectLoadable>: Equatable {
    case fallback
    case `override`(T)

    var override: T? {
        switch self {
        case .fallback:
            return nil
        case .override(let override):
            return override
        }
    }
}

protocol JSONObjectLoadable {
    init?(jsonObject: [String: Any]) throws
}

extension GeneratorConfig {
    init(jsonObject: [String : Any]) throws {
        if let override = try T(jsonObject: jsonObject) {
            self = .override(override)
        } else {
            self = .fallback
        }
    }
}

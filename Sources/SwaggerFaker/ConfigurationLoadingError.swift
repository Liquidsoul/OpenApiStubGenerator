enum ConfigurationLoadingError: Error {
    case invalidType(key: String)
    case missingKeyOrInvalidType(key: String)
    case invalidConfiguration(config: Any)
}

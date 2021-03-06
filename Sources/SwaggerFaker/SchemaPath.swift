struct SchemaPath: Equatable, Hashable {
    var path: [Item]

    enum Item: Equatable, Hashable {
        case key(String)
        case index(Int)
    }

    init(path: [Item] = []) {
        self.path = path
    }
}

extension SchemaPath {
    static func + (left: SchemaPath, right: SchemaPath.Item) -> SchemaPath {
        var result = left
        result.path += [right]
        return result
    }
}

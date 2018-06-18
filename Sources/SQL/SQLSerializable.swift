public protocol SQLSerializable {
    func serialize(_ binds: inout [Encodable]) -> String
}

extension Array where Element: SQLSerializable {
    public func serialize(_ binds: inout [Encodable], joinedBy separator: String = ", ") -> String {
        return map { $0.serialize(&binds) }.joined(separator: separator)
    }
}

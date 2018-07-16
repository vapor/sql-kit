/// Types conforming to this protocol are capable of serializing to SQL.
/// They can optionally output zero or more binds. This is useful when types like
/// expressions must serialize value placeholders into a SQL string.
public protocol SQLSerializable {
    /// Serializes self into a SQL string. If the string contains value placeholders,
    /// each encodable value is appended to the binds array in the order it appears in the string.
    func serialize(_ binds: inout [Encodable]) -> String
}

extension Array where Element: SQLSerializable {
    /// Convenience for serializing an array of `SQLSerializable` types into a string.
    public func serialize(_ binds: inout [Encodable], joinedBy separator: String = ", ") -> String {
        return map { $0.serialize(&binds) }.joined(separator: separator)
    }
}

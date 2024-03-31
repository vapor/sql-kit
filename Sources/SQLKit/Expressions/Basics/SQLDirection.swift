public enum SQLDirection: SQLExpression {
    case ascending
    case descending
    /// Order in which NULL values come first.
    case null
    /// Order in which NOT NULL values come first.
    case notNull
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .ascending:  serializer.write("ASC")
        case .descending: serializer.write("DESC")
        case .null:       serializer.write("NULL")
        case .notNull:    serializer.write("NOT NULL")
        }
    }
}

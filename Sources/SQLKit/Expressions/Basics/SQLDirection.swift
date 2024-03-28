/// Describes an ordering direction for a given sorting key.
public enum SQLDirection: SQLExpression {
    /// Ascending order (minimum to maximum), as defined by the sorting key's data type.
    case ascending

    /// Descending order (maximum to minimum), as defined by the sorting key's data type.
    case descending
    
    /// `NULL` order (`NULL` values followed by non-`NULL` valeus).
    case null
    
    /// `NOT NULL` order (non-`NULL` values followed by `NULL` values).
    case notNull
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .ascending:
            serializer.write("ASC")
        case .descending:
            serializer.write("DESC")
        case .null:
            serializer.write("NULL")
        case .notNull:
            serializer.write("NOT NULL")
        }
    }
}

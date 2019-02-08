public enum SQLDirection: SQLExpression {
    case ascending
    case descending
    
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .ascending:
            serializer.write("ASC")
        case .descending:
            serializer.write("DESC")
        }
    }
}

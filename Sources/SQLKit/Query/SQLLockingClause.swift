public enum SQLLockingClause: SQLExpression {
    case update
    case share
    
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .share:
            serializer.write("FOR SHARE")
        case .update:
            serializer.write("FOR UPDATE")
        }
    }
}

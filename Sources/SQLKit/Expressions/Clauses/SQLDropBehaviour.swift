/// RESTRICT | CASCADE
public enum SQLDropBehavior: SQLExpression {
    /// The drop behavior clause specifies if objects that depend on a table
    /// should also be dropped or not when the table is dropped.
    
    /// Refuse to drop the table if any objects depend on it.
    case restrict
    
    /// Automatically drop objects that depend on the table (such as views).
    case cascade
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .restrict: serializer.write("RESTRICT")
        case .cascade:  serializer.write("CASCADE")
        }
    }
}

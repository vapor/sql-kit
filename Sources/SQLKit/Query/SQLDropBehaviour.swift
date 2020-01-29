/// RESTRICT | CASCADE
public enum SQLDropBehaviour: SQLExpression {
    /// The drop behaviour clause specifies if objects that depend on a table
    /// should also be dropped or not when the table is dropped.
    
    /// Refuse to drop the table if any objects depend on it.
    case restrict
    
    /// Automatically drop objects that depend on the table (such as views).
    case cascade
    
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .restrict: serializer.write("RESTRICT")
        case .cascade: serializer.write("CASCADE")
        }
    }
}

/// An expression appearing on the right side of a column assignment which, when the assignment list
/// is part of an upsert's update acion, refers to the value which was originally to be inserted for
/// the given column.
///
/// - Note: If the serializer's dialect does not support upserts, this expression silently evaluates
///   to nothing at all.
public struct SQLExcludedColumn: SQLExpression {
    public var name: SQLExpression
    
    public init(_ name: String) {
        self.init(SQLIdentifier(name))
    }
    
    public init(_ name: SQLExpression) {
        self.name = name
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        switch serializer.dialect.upsertSyntax {
            case .standard:
                /// The `excluded` table name is a context-specific keyword, _not_ an identifier.
                serializer.write("EXCLUDED.")
                self.name.serialize(to: &serializer)
            case .mysqlLike:
                SQLFunction("VALUES", args: self.name).serialize(to: &serializer)
            case .unsupported:
                break // Should we crash (or maybe assert) here?
        }
    }
}


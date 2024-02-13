/// Underyling conformance requirement for all SQL "AST nodes".
public protocol SQLExpression {
    /// serialization
    func serialize(to serializer: inout SQLSerializer)
}

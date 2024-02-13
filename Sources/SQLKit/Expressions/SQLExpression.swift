/// Underyling conformance requirement for all SQL "AST nodes".
public protocol SQLExpression: Sendable {
    /// serialization
    func serialize(to serializer: inout SQLSerializer)
}

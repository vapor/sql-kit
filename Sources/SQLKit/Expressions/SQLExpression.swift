public protocol SQLExpression {
    func serialize(to serializer: inout SQLSerializer)
}

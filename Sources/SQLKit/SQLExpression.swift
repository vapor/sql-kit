public protocol SQLExpression {
    func serialize(to serializer: inout SQLSerializer)
}

public protocol SQLExpressible {
    var sql: SQLExpression { get }
}

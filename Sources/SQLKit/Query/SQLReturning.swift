/// `RETURNING ...` statement.
///
public enum SQLReturning: SQLExpression {
    case all
    case fields([SQLIdentifier])

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(" RETURNING ")
        switch self {
        case .all:
            SQLLiteral.all.serialize(to: &serializer)
        case let .fields(fields):
            SQLList(fields).serialize(to: &serializer)
        }
    }
}

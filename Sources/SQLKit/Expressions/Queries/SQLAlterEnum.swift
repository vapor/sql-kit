/// `ALTER TYPE enum_type ADD VALUE 'new_value';`
///
/// See ``SQLAlterEnumBuilder``.
public struct SQLAlterEnum: SQLExpression {
    public var name: any SQLExpression
    public var value: (any SQLExpression)?

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            $0.append("ALTER TYPE")
            $0.append(self.name)
            if let value = self.value {
                $0.append("ADD VALUE")
                $0.append(value)
            }
        }
    }
}

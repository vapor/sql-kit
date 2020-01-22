// ALTER TYPE enum_type ADD VALUE 'new_value';
public struct SQLAlterEnum: SQLExpression {
    public var name: SQLExpression
    public var value: SQLExpression?

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

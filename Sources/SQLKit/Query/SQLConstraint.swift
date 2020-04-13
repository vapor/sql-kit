/// Constraints for `SQLCreateTable` (column and table constraints).
public struct SQLConstraint: SQLExpression {
    /// Name of constraint
    ///
    ///     `CONSTRAINT <name>`
    public var name: SQLExpression?

    /// Algorithm. See `SQLTableConstraintAlgorithm`
    /// and `SQLColumnConstraintAlgorithm`
    public var algorithm: SQLExpression

    public init(algorithm: SQLExpression, name: SQLExpression? = nil) {
        self.name = name
        self.algorithm = algorithm
    }

    public func serialize(to serializer: inout SQLSerializer) {
        if let name = self.name {
            serializer.write("CONSTRAINT ")
            if let identifier = (name as? SQLIdentifier)?.string {
                let normalizedName = serializer.dialect.normalizeSQLConstraintIdentifier(identifier: identifier)
                SQLIdentifier(normalizedName).serialize(to: &serializer)
            } else {
                name.serialize(to: &serializer)
            }
            serializer.write(" ")
        }
        self.algorithm.serialize(to: &serializer)
    }
}

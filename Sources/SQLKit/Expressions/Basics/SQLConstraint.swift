/// Constraints for ``SQLCreateTable`` (column and table constraints).
public struct SQLConstraint: SQLExpression {
    /// Name of constraint
    ///
    ///     `CONSTRAINT <name>`
    public var name: (any SQLExpression)?

    /// Algorithm. See `SQLTableConstraintAlgorithm`
    /// and `SQLColumnConstraintAlgorithm`
    /// TODO: Make optional.
    public var algorithm: any SQLExpression

    @inlinable
    public init(algorithm: any SQLExpression, name: (any SQLExpression)? = nil) {
        self.name = name
        self.algorithm = algorithm
    }

    public func serialize(to serializer: inout SQLSerializer) {
        if let name = self.name {
            serializer.write("CONSTRAINT ")
            let normalizedName = serializer.dialect.normalizeSQLConstraint(identifier: name)
            normalizedName.serialize(to: &serializer)
            serializer.write(" ")
        }
        self.algorithm.serialize(to: &serializer)
    }
}

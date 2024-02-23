/// Constraints for ``SQLCreateTable`` (column and table constraints).
public struct SQLConstraint: SQLExpression {
    /// The constraint's name, if any.
    public var name: (any SQLExpression)?

    /// The constraint's algorithm.
    ///
    /// See ``SQLTableConstraintAlgorithm`` and ``SQLColumnConstraintAlgorithm``.
    public var algorithm: any SQLExpression

    /// Create an ``SQLConstraint``.
    ///
    /// - Parameters:
    ///   - algorithm: The constraint algorithm.
    ///   - name: The optional constraint name.
    @inlinable
    public init(algorithm: any SQLExpression, name: (any SQLExpression)? = nil) {
        self.name = name
        self.algorithm = algorithm
    }

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            if let name = self.name {
                let normalized = $0.dialect.normalizeSQLConstraint(identifier: name)
                $0.append("CONSTRAINT", normalized)
            }
            $0.append(self.algorithm)
        }
    }
}

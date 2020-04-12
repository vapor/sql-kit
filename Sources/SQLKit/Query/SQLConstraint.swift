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
            if let identifier = (name as? SQLIdentifier)?.string {
                let normalizedName = serializer.dialect.normalizeSQLConstraintIdentifier(identifier)
                SQLIdentifier(normalizedName).serialize(to: &serializer)
            } else {
                name.serialize(to: &serializer)
            }
            serializer.write(" ")
        }
        self.algorithm.serialize(to: &serializer)
    }
}

extension SQLDialect {
    public func normalizeSQLConstraintIdentifier(_ identifier: String) -> String {
        guard identifier.utf8.count > self.maximumConstraintIdentifierLength else { return identifier }
        let midPoint = (identifier.count >> 1) - ((identifier.utf8.count - self.maximumConstraintIdentifierLength) >> 1)
        let maxPrefixVal = Swift.max(identifier.startIndex, identifier.index(identifier.startIndex, offsetBy: midPoint))
        return String(identifier.prefix(upTo: maxPrefixVal) + identifier.suffix(midPoint))
    }
}

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
        guard identifier.utf8.count >= self.maximumConstraintIdentifierLength else { return identifier }
        
        var normalizedIdentifier = identifier
        let midPoint = identifier.count >> 1 // midpoint as extended grapheme cluster count, rounding down
        let utf8Midpoint = identifier.index(identifier.startIndex, offsetBy: midPoint).samePosition(in: identifier.utf8)!
        let excessInBytes = identifier.utf8.count - self.maximumConstraintIdentifierLength // number of *bytes* by which the string is too long
        let excessCutdown = excessInBytes >> 1 // number of bytes on either side of the midpoint to remove
        var utf8PreCutdownIndex = identifier.utf8.index(utf8Midpoint, offsetBy: -excessCutdown)
        var realPreCutdownIndex = utf8PreCutdownIndex.samePosition(in: identifier)
        while realPreCutdownIndex == nil && utf8PreCutdownIndex > identifier.utf8.startIndex {
            identifier.utf8.formIndex(before: &utf8PreCutdownIndex)
            realPreCutdownIndex = utf8PreCutdownIndex.samePosition(in: identifier)
        }
        
        var utf8PostCutdownIndex = identifier.utf8.index(utf8Midpoint, offsetBy: excessCutdown)
        var realPostCutdownIndex = utf8PostCutdownIndex.samePosition(in: identifier)
        while realPostCutdownIndex == nil && utf8PostCutdownIndex < identifier.utf8.endIndex {
            identifier.utf8.formIndex(after: &utf8PostCutdownIndex)
            realPostCutdownIndex = utf8PostCutdownIndex.samePosition(in: identifier)
        }
        
        let cutdownRange = (realPreCutdownIndex!)...(realPostCutdownIndex!)

        // make sure we didn't accidentally generate something that'll result in an empty string or out-of-bounds crash; this should only be possible if a dialect declares a maximum length of less than 4
        assert(cutdownRange.lowerBound > identifier.startIndex && cutdownRange.upperBound < identifier.endIndex)
        normalizedIdentifier.removeSubrange((realPreCutdownIndex!)...(realPostCutdownIndex!))
        
        return normalizedIdentifier
    }
}

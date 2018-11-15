/// Constraint algorithms used by `SQLColumnConstraint`.
public protocol SQLConstraintAlgorithm: SQLSerializable {
    /// See `SQLExpression.
    associatedtype Expression: SQLExpression
    
    /// See `SQLCollation.
    associatedtype Collation: SQLCollation
    
    /// See `SQLForeignKey.
    associatedtype ForeignKey: SQLForeignKey
    
    /// `PRIMARY KEY` constraint.
    static var primaryKey: Self { get }
    
    /// `NOT NULL` constraint.
    static var notNull: Self { get }
    
    /// `UNIQUE` constraint.
    static var unique: Self { get }
    
    /// `CHECK` constraint.
    static func check(_ expression: Expression) -> Self
    
    /// `COLLATE` constraint.
    static func collate(_ collation: Collation) -> Self
    
    /// `DEFAULT` constraint.
    static func `default`(_ expression: Expression) -> Self
    
    /// `FOREIGN KEY` constraint.
    static func foreignKey(_ foreignKey: ForeignKey) -> Self
}

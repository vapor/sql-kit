public protocol SQLTableConstraintAlgorithm: SQLSerializable {
    associatedtype Identifier: SQLIdentifier
    associatedtype Expression: SQLExpression
    associatedtype Collation: SQLCollation
    associatedtype ForeignKey: SQLForeignKey
    static func primaryKey(_ columns: [Identifier]) -> Self
    static var notNull: Self { get }
    static func unique(_ columns: [Identifier]) -> Self
    static func check(_ expression: Expression) -> Self
    static func foreignKey(_ columns: [Identifier], _ foreignKey: ForeignKey) -> Self
}

// MARK: Generic

public enum GenericSQLTableConstraintAlgorithm<Identifier, Expression, Collation, ForeignKey>: SQLTableConstraintAlgorithm
    where Identifier: SQLIdentifier, Expression: SQLExpression, Collation: SQLCollation, ForeignKey: SQLForeignKey
{
    public typealias `Self` = GenericSQLTableConstraintAlgorithm<Identifier, Expression, Collation, ForeignKey>
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func primaryKey(_ columns: [Identifier]) -> Self {
        return ._primaryKey(columns)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static var notNull: Self {
        return ._notNull
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func unique(_ columns: [Identifier]) -> Self {
        return ._unique(columns)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func check(_ expression: Expression) -> Self {
        return ._check(expression)
    }
    
    /// See `SQLColumnConstraintAlgorithm`.
    public static func foreignKey(_ columns: [Identifier], _ foreignKey: ForeignKey) -> Self {
        return ._foreignKey(columns, foreignKey)
    }
    
    case _primaryKey([Identifier])
    case _notNull
    case _unique([Identifier])
    case _check(Expression)
    case _foreignKey([Identifier], ForeignKey)
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case ._primaryKey(let columns):
            var sql: [String] = []
            sql.append("PRIMARY KEY")
            sql.append("(" + columns.serialize(&binds) + ")")
            return sql.joined(separator: " ")
        case ._notNull: return "NOT NULL"
        case ._unique(let columns):
            var sql: [String] = []
            sql.append("UNIQUE")
            sql.append("(" + columns.serialize(&binds) + ")")
            return sql.joined(separator: " ")
        case ._check(let expression):
            return "CHECK (" + expression.serialize(&binds) + ")"
        case ._foreignKey(let columns, let foreignKey):
            var sql: [String] = []
            sql.append("FOREIGN KEY")
            sql.append("(" + columns.serialize(&binds) + ")")
            sql.append("REFERENCES")
            sql.append(foreignKey.serialize(&binds))
            return sql.joined(separator: " ")
        }
    }
}

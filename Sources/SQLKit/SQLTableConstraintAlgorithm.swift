///// Constraint algorithms used by `SQLTableConstraintAlgorithm`.
//public protocol SQLTableConstraintAlgorithm: SQLSerializable {
//    /// See `SQLIdentifier`.
//    associatedtype Identifier: SQLIdentifier
//    
//    /// See `SQLExpression`.
//    associatedtype Expression: SQLExpression
//    
//    /// See `SQLCollation`.
//    associatedtype Collation: SQLCollation
//    
//    /// See `SQLForeignKey`.
//    associatedtype ForeignKey: SQLForeignKey
//    
//    /// `PRIMARY KEY` constriant.
//    static func primaryKey(_ columns: [Identifier]) -> Self
//    
//    /// `NOT NULL` constraint.
//    static var notNull: Self { get }
//    
//    /// `UNIQUE` constraint.
//    static func unique(_ columns: [Identifier]) -> Self
//    
//    /// `CHECK` constraint.
//    static func check(_ expression: Expression) -> Self
//    
//    /// `FOREIGN KEY` constraint.
//    static func foreignKey(_ columns: [Identifier], _ foreignKey: ForeignKey) -> Self
//}

//// MARK: Generic
//
///// Generic implementation of `SQLTableConstraintAlgorithm`.
//public enum GenericSQLTableConstraintAlgorithm<Identifier, Expression, Collation, ForeignKey>: SQLTableConstraintAlgorithm
//    where Identifier: SQLIdentifier, Expression: SQLExpression, Collation: SQLCollation, ForeignKey: SQLForeignKey
//{
//    /// Convenience typealias for self.
//    public typealias `Self` = GenericSQLTableConstraintAlgorithm<Identifier, Expression, Collation, ForeignKey>
//
//    /// See `SQLColumnConstraintAlgorithm`.
//    public static func primaryKey(_ columns: [Identifier]) -> Self {
//        return ._primaryKey(columns)
//    }
//
//    /// See `SQLColumnConstraintAlgorithm`.
//    public static var notNull: Self {
//        return ._notNull
//    }
//
//    /// See `SQLColumnConstraintAlgorithm`.
//    public static func unique(_ columns: [Identifier]) -> Self {
//        return ._unique(columns)
//    }
//
//    /// See `SQLColumnConstraintAlgorithm`.
//    public static func check(_ expression: Expression) -> Self {
//        return ._check(expression)
//    }
//
//    /// See `SQLColumnConstraintAlgorithm`.
//    public static func foreignKey(_ columns: [Identifier], _ foreignKey: ForeignKey) -> Self {
//        return ._foreignKey(columns, foreignKey)
//    }
//
//    /// See `SQLTableConstraintAlgorithm`.
//    case _primaryKey([Identifier])
//
//    /// See `SQLTableConstraintAlgorithm`.
//    case _notNull
//
//    /// See `SQLTableConstraintAlgorithm`.
//    case _unique([Identifier])
//
//    /// See `SQLTableConstraintAlgorithm`.
//    case _check(Expression)
//
//    /// See `SQLTableConstraintAlgorithm`.
//    case _foreignKey([Identifier], ForeignKey)
//
//    /// See `SQLSerializable`.
//    public func serialize(_ binds: inout [Encodable]) -> String {
//        switch self {
//        case ._primaryKey(let columns):
//            var sql: [String] = []
//            sql.append("PRIMARY KEY")
//            sql.append("(" + columns.serialize(&binds) + ")")
//            return sql.joined(separator: " ")
//        case ._notNull: return "NOT NULL"
//        case ._unique(let columns):
//            var sql: [String] = []
//            sql.append("UNIQUE")
//            sql.append("(" + columns.serialize(&binds) + ")")
//            return sql.joined(separator: " ")
//        case ._check(let expression):
//            return "CHECK (" + expression.serialize(&binds) + ")"
//        case ._foreignKey(let columns, let foreignKey):
//            var sql: [String] = []
//            sql.append("FOREIGN KEY")
//            sql.append("(" + columns.serialize(&binds) + ")")
//            sql.append("REFERENCES")
//            sql.append(foreignKey.serialize(&binds))
//            return sql.joined(separator: " ")
//        }
//    }
//}

//public protocol SQLQuery: SQLSerializable { }

///// Top-level SQL query. Used by `SQLConnection`. Supports `DDL` and `DML`.
/////
///// Use builders like `SQLSelectBuilder`, `SQLCreateTableBuilder`, etc to execute queries.
//public protocol SQLQuery: SQLSerializable {
//    /// See `SQLAlterTable`.
//    associatedtype AlterTable: SQLAlterTable where
//        AlterTable.Identifier == Self.Identifier,
//        AlterTable.ColumnDefinition == Self.ColumnDefinition
//    
//    /// See `SQLBinaryOperator`.
//    associatedtype BinaryOperator
//    
//    /// See `SQLBind`.
//    associatedtype Bind
//    
//    /// See `SQLCreateIndex`.
//    associatedtype CreateIndex: SQLCreateIndex where
//        CreateIndex.Modifier == Self.IndexModifier,
//        CreateIndex.Identifier == Self.Identifier,
//        CreateIndex.ColumnIdentifier == Self.ColumnIdentifier
//    
//    /// See `SQLCreateTable`.
//    associatedtype CreateTable: SQLCreateTable where
//        CreateTable.Identifier == Self.Identifier,
//        CreateTable.ColumnDefinition == Self.ColumnDefinition,
//        CreateTable.TableConstraint == Self.TableConstraint
//    
//    /// See `SQLCollation.
//    associatedtype Collation
//    
//    associatedtype ColumnConstraint where
//        ColumnConstraint.Identifier == Self.Identifier,
//        ColumnConstraint.ConstraintAlgorithm == Self.ConstraintAlgorithm
//    
//    associatedtype ColumnDefinition where
//        ColumnDefinition.ColumnIdentifier == Self.ColumnIdentifier,
//        ColumnDefinition.DataType == Self.DataType,
//        ColumnDefinition.ColumnConstraint == Self.ColumnConstraint
//    
//    associatedtype ColumnIdentifier where
//        ColumnIdentifier.Identifier == Identifier
//    
//    associatedtype ConstraintAlgorithm where
//        ConstraintAlgorithm.Expression == Self.Expression,
//        ConstraintAlgorithm.Collation == Self.Collation,
//        ConstraintAlgorithm.ForeignKey == Self.ForeignKey
//    
//    associatedtype DataType
//    
//    /// See `SQLDelete`.
//    associatedtype Delete: SQLDelete where
//        Delete.Identifier == Self.Identifier,
//        Delete.Expression == Self.Expression
//    
//    /// See `SQLDistinct`.
//    associatedtype Distinct
//    
//    /// See `SQLDropIndex`.
//    associatedtype DropIndex: SQLDropIndex
//    
//    /// See `SQLDropTable`.
//    associatedtype DropTable: SQLDropTable where
//        DropTable.Identifier == Self.Identifier
//    
//    associatedtype Expression where
//        Expression.Literal == Self.Literal,
//        Expression.Bind == Self.Bind,
//        Expression.ColumnIdentifier == Self.ColumnIdentifier,
//        Expression.BinaryOperator == Self.BinaryOperator,
//        Expression.Identifier == Self.Identifier,
//        Expression.Subquery == Self.Select
//    
//    /// See `SQLForeignKey.
//    associatedtype ForeignKey where
//        ForeignKey.Identifier == Self.Identifier,
//        ForeignKey.ForeignKeyAction == Self.ForeignKeyAction
//    
//    /// See `SQLForeignKeyAction`.
//    associatedtype ForeignKeyAction
//    
//    /// See `SQLGroupBy`.
//    associatedtype GroupBy where
//        GroupBy.Expression == Self.Expression
//    
//    associatedtype Identifier
//    
//    /// See `SQLInsert`.
//    associatedtype Insert: SQLInsert where
//        Insert.Identifier == Self.Identifier,
//        Insert.ColumnIdentifier == Self.ColumnIdentifier,
//        Insert.Expression == Self.Expression
//    
//    associatedtype IndexModifier
//    
//    /// See `SQLJoin`.
//    associatedtype Join
//    
//    associatedtype Literal
//    
//    /// See `SQLOrderBy`.
//    associatedtype OrderBy
//    
//    /// See `SQLSelect`.
//    associatedtype Select: SQLSelect where
//        Select.Distinct == Self.Distinct,
//        Select.Identifier == Self.Identifier,
//        Select.Join == Self.Join,
//        Select.Expression == Self.Expression,
//        Select.GroupBy == Self.GroupBy,
//        Select.OrderBy == Self.OrderBy
//    
//    /// See `SQLTableConstraint`.
//    associatedtype TableConstraint where
//        TableConstraint.Identifier == Self.Identifier,
//        TableConstraint.ConstraintAlgorithm == Self.ConstraintAlgorithm
//    
//    /// See `SQLUpdate`.
//    associatedtype Update: SQLUpdate where
//        Update.Identifier == Self.Identifier,
//        Update.Expression == Self.Expression
//
//    /// Creates a new `SQLQuery`.
//    static func alterTable(_ alterTable: AlterTable) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func createIndex(_ createIndex: CreateIndex) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func createTable(_ createTable: CreateTable) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func delete(_ delete: Delete) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func dropIndex(_ dropIndex: DropIndex) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func dropTable(_ dropTable: DropTable) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func insert(_ insert: Insert) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func select(_ select: Select) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func update(_ update: Update) -> Self
//    
//    /// Creates a new `SQLQuery`.
//    static func raw(_ String, binds: [Encodable]) -> Self
//}

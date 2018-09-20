/// Top-level SQL query. Used by `SQLConnection`. Supports `DDL` and `DML`.
///
/// Use builders like `SQLSelectBuilder`, `SQLCreateTableBuilder`, etc to execute queries.
public protocol SQLQuery: SQLSerializable {
    /// See `SQLAlterTable`.
    associatedtype AlterTable: SQLAlterTable
    
    /// See `SQLCreateIndex`.
    associatedtype CreateIndex: SQLCreateIndex
    
    /// See `SQLCreateTable`.
    associatedtype CreateTable: SQLCreateTable
    
    /// See `SQLDelete`.
    associatedtype Delete: SQLDelete
    
    /// See `SQLDropIndex`.
    associatedtype DropIndex: SQLDropIndex
    
    /// See `SQLDropTable`.
    associatedtype DropTable: SQLDropTable
    
    /// See `SQLInsert`.
    associatedtype Insert: SQLInsert
    
    /// See `SQLSelect`.
    associatedtype Select: SQLSelect
    
    /// See `SQLUpdate`.
    associatedtype Update: SQLUpdate

    /// Creates a new `SQLQuery`.
    static func alterTable(_ alterTable: AlterTable) -> Self
    
    /// Creates a new `SQLQuery`.
    static func createIndex(_ createIndex: CreateIndex) -> Self
    
    /// Creates a new `SQLQuery`.
    static func createTable(_ createTable: CreateTable) -> Self
    
    /// Creates a new `SQLQuery`.
    static func delete(_ delete: Delete) -> Self
    
    /// Creates a new `SQLQuery`.
    static func dropIndex(_ dropIndex: DropIndex) -> Self
    
    /// Creates a new `SQLQuery`.
    static func dropTable(_ dropTable: DropTable) -> Self
    
    /// Creates a new `SQLQuery`.
    static func insert(_ insert: Insert) -> Self
    
    /// Creates a new `SQLQuery`.
    static func select(_ select: Select) -> Self
    
    /// Creates a new `SQLQuery`.
    static func update(_ update: Update) -> Self
    
    /// Creates a new `SQLQuery`.
    static func raw(_ sql: String, binds: [Encodable]) -> Self
}

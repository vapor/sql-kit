public protocol SQLQuery: SQLSerializable {
    associatedtype AlterTable: SQLAlterTable
    associatedtype CreateIndex: SQLCreateIndex
    associatedtype CreateTable: SQLCreateTable
    associatedtype Delete: SQLDelete
    associatedtype DropIndex: SQLDropIndex
    associatedtype DropTable: SQLDropTable
    associatedtype Insert: SQLInsert
    associatedtype Select: SQLSelect
    associatedtype Update: SQLUpdate

    static func alterTable(_ alterTable: AlterTable) -> Self
    static func createIndex(_ createIndex: CreateIndex) -> Self
    static func createTable(_ createTable: CreateTable) -> Self
    static func delete(_ delete: Delete) -> Self
    static func dropIndex(_ dropIndex: DropIndex) -> Self
    static func dropTable(_ dropTable: DropTable) -> Self
    static func insert(_ insert: Insert) -> Self
    static func select(_ select: Select) -> Self
    static func update(_ update: Update) -> Self
    static func raw(_ sql: String, binds: [Encodable]) -> Self
}

public protocol SQLDatabase {
    func execute(
        sql query: SQLExpression,
        _ onRow: @escaping (SQLRow) throws -> ()
    ) -> EventLoopFuture<Void>
}

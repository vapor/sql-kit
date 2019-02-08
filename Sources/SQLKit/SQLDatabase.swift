public protocol SQLDatabase {
    func sqlQuery(
        _ query: SQLExpression,
        _ onRow: @escaping (SQLRow) throws -> ()
    ) -> EventLoopFuture<Void>
}

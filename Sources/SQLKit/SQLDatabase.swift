public protocol SQLDatabase {
    var logger: Logger { get }
    var eventLoop: EventLoop { get }
    func execute(
        sql query: SQLExpression,
        _ onRow: @escaping (SQLRow) -> ()
    ) -> EventLoopFuture<Void>
}


extension SQLDatabase {
    public func with(_ logger: Logger) -> SQLDatabase {
        CustomLoggerSQLDatabase(database: self, logger: logger)
    }
}

private struct CustomLoggerSQLDatabase: SQLDatabase {
    let database: SQLDatabase
    let logger: Logger
    var eventLoop: EventLoop {
        return self.database.eventLoop
    }
    
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> {
        self.database.execute(sql: query, onRow)
    }
}

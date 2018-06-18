extension DatabaseQueryable where Query: SQLQuery {
    public func query(_ sql: String, _ binds: [Encodable] = [], _ handler: @escaping (Output) throws -> ()) -> Future<Void> {
        return query(.raw(sql, binds: binds), handler)
    }

    public func query(_ sql: String, _ binds: [Encodable] = []) -> Future<[Output]> {
        return query(.raw(sql, binds: binds))
    }
}

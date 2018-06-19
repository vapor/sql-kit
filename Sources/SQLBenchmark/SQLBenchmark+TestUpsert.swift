extension SQLBenchmarker {
    internal func testUpsert() throws {
        defer {
            _ = try? conn.drop(table: Galaxy.self)
                .ifExists()
                .run().wait()
        }
        
        try conn.create(table: Galaxy.self)
            .column(for: \Galaxy.id, .primaryKey)
            .column(for: \Galaxy.name)
            .run().wait()
        
        
        try conn.insert(into: Galaxy.self)
            .value(Galaxy(name: "Milky Way"))
            .run().wait()
        
        try conn.insert(into: Galaxy.self)
            .value(Galaxy(id: 1, name: "Andromeda"))
            .onConflict(set: Galaxy(id: 1, name: "Andromeda"))
            .run().wait()
    }
}

import SQLKit

extension SQLBenchmarker {
    public func testCodable() throws {
        try self.runTest {
            try $0.drop(table: "planets")
                .ifExists()
                .run().wait()
            try $0.drop(table: "galaxies")
                .ifExists()
                .run().wait()
            try $0.create(table: "galaxies")
                .column("id", type: .bigint, .primaryKey)
                .column("name", type: .text)
                .run().wait()
            try $0.create(table: "planets")
                .column("id", type: .bigint, .primaryKey)
                .column("name", type: .text, [.default(SQLLiteral.string("Unamed Planet")), .notNull])
                .column("is_inhabited", type: .custom(SQLRaw("boolean")), .notNull)
                .column("galaxyID", type: .bigint, .references("galaxies", "id"))
                .run().wait()

            // insert
            let galaxy = Galaxy(name: "milky way")
            try $0.insert(into: "galaxies").model(galaxy).run().wait()

            // insert with keyEncodingStrategy
            let earth = Planet(name: "Earth", isInhabited: true)
            let mars = Planet(name: "Mars", isInhabited: false)
            try $0.insert(into: "planets")
                .models([earth, mars], keyEncodingStrategy: .convertToSnakeCase)
                .run().wait()
        }
    }
}

fileprivate struct Planet: Encodable {
    let id: Int? = nil
    let name: String
    let isInhabited: Bool
}

fileprivate struct Galaxy: Encodable {
    let id: Int? = nil
    let name: String
}

import SQLKit

extension SQLBenchmarker {
    public func testCodable() async throws {
        try await self.runTest {
            try await $0.drop(table: "planets")
                .ifExists()
                .run()
            try await $0.drop(table: "galaxies")
                .ifExists()
                .run()
            try await $0.create(table: "galaxies")
                .column("id", type: .bigint, .primaryKey)
                .column("name", type: .text)
                .run()
            try await $0.create(table: "planets")
                .column("id", type: .bigint, .primaryKey)
                .column("name", type: .text, [.default(SQLLiteral.string("Unamed Planet")), .notNull])
                .column("is_inhabited", type: .custom(SQLUnsafeRaw("boolean")), .notNull)
                .column("galaxyID", type: .bigint, .references("galaxies", "id"))
                .run()

            // insert
            let galaxy = Galaxy(name: "milky way")
            try await $0.insert(into: "galaxies").model(galaxy).run()

            // insert with keyEncodingStrategy
            let earth = Planet(name: "Earth", isInhabited: true)
            let mars = Planet(name: "Mars", isInhabited: false)
            try await $0.insert(into: "planets")
                .models([earth, mars], keyEncodingStrategy: .convertToSnakeCase)
                .run()
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

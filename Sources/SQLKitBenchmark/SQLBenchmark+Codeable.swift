import Foundation

import SQLKit

extension SQLBenchmarker {
    public func testCodable() throws {
        try self.db.drop(table: "planets")
            .ifExists()
            .run().wait()
        try self.db.drop(table: "galaxies")
            .ifExists()
            .run().wait()
        try self.db.create(table: "galaxies")
            .column("id", type: .bigint, .primaryKey)
            .column("name", type: .text)
            .run().wait()
        try self.db.create(table: "planets")
            .ifNotExists()
            .column("id", type: .bigint, .primaryKey)
            .column("name", type: .bigint, .primaryKey)
            .column("is_inhabited", type: .smallint, .notNull)
            .column("galaxyID", type: .bigint, .references("galaxies", "id"))
            .run().wait()

        // insert
        let galaxy = Galaxy(name: "milky way")
        try self.db.insert(into: "galaxies").model(galaxy).run().wait()

        // insert with keyEncodingStrategy
        let earth = Planet(name: "Earth", isInhabited: true)
        let mars = Planet(name: "Mars", isInhabited: false)
        try self.db.insert(into: "planets")
            .models([earth, mars], keyEncodingStrategy: .convertToSnakeCase)
            .run().wait()
    }
}

fileprivate struct Planet: Codable {
    let id: Int? = nil
    let name: String
    let isInhabited: Bool
}

fileprivate struct Galaxy: Codable {
    let id: Int? = nil
    let name: String
}

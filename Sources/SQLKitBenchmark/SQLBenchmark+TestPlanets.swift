import XCTest

extension SQLBenchmarker {
    internal func testPlanets() throws {
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
            .column("galaxyID", type: .bigint, .references("galaxies", "id"))
            .run().wait()
        
        try self.db.alter(table: "planets")
            .column("name", type: .text, .default(.literal("Unamed Planet")))
            .run().wait()
        
        try self.db.create(index: "test_index")
            .on(.column(name: "id", table: "planets"))
            .unique()
            .run().wait()
        
        // INSERT INTO "galaxies" ("id", "name") VALUES (DEFAULT, $1)
        try self.db.insert(into: "galaxies")
            .value(Galaxy(name: "Milky Way"))
            .run().wait()
        
        // SELECT * FROM galaxies WHERE name != NULL AND (name == ? OR name == ?)
        let c = try self.db.select()
            .column(.all)
            .from("galaxies")
            .where("name", .notEqual, .literal(.null))
            .where {
                $0.where("name", .equal, .bind("Milky Way"))
                    .orWhere("name", .equal, .bind("Andromeda"))
            }
            .all().wait()
        XCTAssertEqual(c.count, 1)
        
        let a = try self.db.select()
            .column(.all)
            .from("galaxies")
            .where(.column("name"), .equal, .bind("Milky Way"))
            .groupBy("id")
            .orderBy("name", .descending)
            .all().wait().map { try $0.decode(Galaxy.self, table: "galaxies") }
        print(a)
        XCTAssertEqual(a.count, 1)
        
        let galaxyID = 1
        try self.db.insert(into: "planets")
            .value(Planet(name: "Earth", galaxyID: galaxyID))
            .run().wait()
        
        try self.db.insert(into: "planets")
            .values([
                Planet(name: "Mercury", galaxyID: galaxyID),
                Planet(name: "Venus", galaxyID: galaxyID),
                Planet(name: "Mars", galaxyID: galaxyID),
                Planet(name: "Jpuiter", galaxyID: galaxyID),
                Planet(name: "Pluto", galaxyID: galaxyID)
            ])
            .run().wait()
        
        try self.db.select()
            .column(.count("name"))
            .from("planets")
            .where(.column("galaxyID"), .equal, .bind(5))
            .run().wait()

        try self.db.select()
            .column(.count(.all))
            .from("planets")
            .where(.column("galaxyID"), .equal, .bind(5))
            .run().wait()

        try self.db.select()
            .column(.sum("id"), as: "id_sum")
            .from("planets")
            .where("galaxyID", .equal, 5)
            .run().wait()
        
        try self.db.select()
            .column(.coalesce(.sum("id"), 0), as: "id_sum")
            .from("planets")
            .where("galaxyID", .equal, 5_000_000)
            .run().wait()
        
        try self.db.update("planets")
            .where("name", .equal, .bind("Jpuiter"))
            .set(["name": "Jupiter"])
            .run().wait()
        
        let selectC = try self.db.select()
            .column(.all)
            .from("planets")
            .join("galaxyID", to: .column(name: "id", table: "galaxies"))
            .all().wait().map {
                try (
                    $0.decode(Galaxy.self, table: "galaxies"),
                    $0.decode(Planet.self, table: "planets")
                )
            }
        XCTAssertEqual(selectC.count, 6)
        
        try self.db.update("galaxies")
            .set("name", to: .bind("Milky Way 2"))
            .where("name", .equal, .bind("Milky Way"))
            .run().wait()
        
        try self.db.delete(from: "galaxies")
            .where("name", .equal, .bind("Milky Way"))
            .run().wait()
        
        let b = try self.db.select()
            .column(.count(.all), as: "c")
            .from("galaxies")
            .all().wait()
        XCTAssertEqual(b.count, 1)
    }
}

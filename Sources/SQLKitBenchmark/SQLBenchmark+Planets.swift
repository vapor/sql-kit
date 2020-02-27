import XCTest
import SQLKit

extension SQLBenchmarker {
    func testPlanets() throws {
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
            .column("name", type: .text, .default(SQLLiteral.string("Unamed Planet")))
            .run().wait()
        try self.db.create(index: "test_index")
            .on("planets")
            .column("id")
            .unique()
            .run().wait()
        // INSERT INTO "galaxies" ("id", "name") VALUES (DEFAULT, $1)
        try self.db.insert(into: "galaxies")
            .columns("id", "name")
            .values(SQLLiteral.default, SQLBind("Milky Way"))
            .values(SQLLiteral.default, SQLBind("Andromeda"))
            // .value(Galaxy(name: "Milky Way"))
            .run().wait()
        // SELECT * FROM galaxies WHERE name != NULL AND (name == ? OR name == ?)
        _ = try self.db.select()
            .column("*")
            .from("galaxies")
            .where("name", .notEqual, SQLLiteral.null)
            .where {
                $0.where("name", .equal, SQLBind("Milky Way"))
                    .orWhere("name", .equal, SQLBind("Andromeda"))
            }
            .all().wait()

        _ = try self.db.select()
            .column("*")
            .from("galaxies")
            .where(SQLColumn("name"), .equal, SQLBind("Milky Way"))
            .groupBy("id")
            .orderBy("name", .descending)
            .all().wait()
        
        try self.db.insert(into: "planets")
            .columns("id", "name")
            .values(SQLLiteral.default, SQLBind("Earth"))
            .run().wait()
        
        try self.db.insert(into: "planets")
            .columns("id", "name")
            .values(SQLLiteral.default, SQLBind("Mercury"))
            .values(SQLLiteral.default, SQLBind("Venus"))
            .values(SQLLiteral.default, SQLBind("Mars"))
            .values(SQLLiteral.default, SQLBind("Jpuiter"))
            .values(SQLLiteral.default, SQLBind("Pluto"))
            .run().wait()

        try self.db.select()
            .column(SQLFunction("count", args: "name"))
            .from("planets")
            .where("galaxyID", .equal, SQLBind(5))
            .run().wait()
        
        try self.db.select()
            .column(SQLFunction("count", args: SQLLiteral.all))
            .from("planets")
            .where("galaxyID", .equal, SQLBind(5))
            .run().wait()

        // add columns for the sake of testing adding columns
        try self.db.alter(table: "planets")
            .column("extra", type: .int)
            .run().wait()

        if self.db.dialect.alterTableSyntax.allowsBatch {
            try self.db.alter(table: "planets")
                .column("very_extra", type: .bigint)
                .column("extra_extra", type: .text)
                .run().wait()

            // drop, add, and modify columns
            try self.db.alter(table: "planets")
                .dropColumn("extra_extra")
                .modifyColumn("extra", type: .text)
                .column("hi", type: .text)
                .run().wait()
        }
    }
}

//import XCTest
//
//extension SQLBenchmarker {
//    internal func testPlanets() throws {
//
//
//
//
//
//
//
//
//
//
//
//        try self.db.select()
//            .column(.coalesce(.sum("id"), 0), as: "id_sum")
//            .from("planets")
//            .where("galaxyID", .equal, 5_000_000)
//            .run().wait()
//
//        try self.db.update("planets")
//            .where("name", .equal, .bind("Jpuiter"))
//            .set(["name": "Jupiter"])
//            .run().wait()
//
//        let selectC = try self.db.select()
//            .column(.all)
//            .from("planets")
//            .join("galaxyID", to: .column(name: "id", table: "galaxies"))
//            .all().wait().map {
//                try (
//                    $0.decode(Galaxy.self, table: "galaxies"),
//                    $0.decode(Planet.self, table: "planets")
//                )
//            }
//        XCTAssertEqual(selectC.count, 6)
//
//        try self.db.update("galaxies")
//            .set("name", to: .bind("Milky Way 2"))
//            .where("name", .equal, .bind("Milky Way"))
//            .run().wait()
//
//        try self.db.delete(from: "galaxies")
//            .where("name", .equal, .bind("Milky Way"))
//            .run().wait()
//
//        let b = try self.db.select()
//            .column(.count(.all), as: "c")
//            .from("galaxies")
//            .all().wait()
//        XCTAssertEqual(b.count, 1)
//    }
//}

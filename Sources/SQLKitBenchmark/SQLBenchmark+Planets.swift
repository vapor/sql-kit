import XCTest
import SQLKit

extension SQLBenchmarker {
    public func testPlanets() throws {
        try self.testPlanets_createSchema()
        try self.testPlanets_seedTables()
        try self.testPlanets_alterSchema()
    }
    
    private func testPlanets_createSchema() throws {
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
                .ifNotExists()
                .column("id", type: .bigint, .primaryKey)
                .column("galaxyID", type: .bigint, .references("galaxies", "id"))
                .run().wait()
            try $0.alter(table: "planets")
                .column("name", type: .text, .default(SQLLiteral.string("Unamed Planet")))
                .run().wait()
            try $0.create(index: "test_index")
                .on("planets")
                .column("id")
                .unique()
                .run().wait()
        }
    }

    private func testPlanets_seedTables() throws {
        try self.runTest {
            // INSERT INTO "galaxies" ("id", "name") VALUES (DEFAULT, $1)
            try $0.insert(into: "galaxies")
                .columns("id", "name")
                .values(SQLLiteral.default, SQLBind("Milky Way"))
                .values(SQLLiteral.default, SQLBind("Andromeda"))
                // .value(Galaxy(name: "Milky Way"))
                .run().wait()
            // SELECT * FROM galaxies WHERE name != NULL AND (name == ? OR name == ?)
            _ = try $0.select()
                .column("*")
                .from("galaxies")
                .where("name", .notEqual, SQLLiteral.null)
                .where {
                    $0.where("name", .equal, SQLBind("Milky Way"))
                        .orWhere("name", .equal, SQLBind("Andromeda"))
                }
                .all().wait()

            _ = try $0.select()
                .column("*")
                .from("galaxies")
                .where(SQLColumn("name"), .equal, SQLBind("Milky Way"))
                .groupBy("id")
                .orderBy("name", .descending)
                .all().wait()
            
            try $0.insert(into: "planets")
                .columns("id", "name")
                .values(SQLLiteral.default, SQLBind("Earth"))
                .run().wait()
            
            try $0.insert(into: "planets")
                .columns("id", "name")
                .values(SQLLiteral.default, SQLBind("Mercury"))
                .values(SQLLiteral.default, SQLBind("Venus"))
                .values(SQLLiteral.default, SQLBind("Mars"))
                .values(SQLLiteral.default, SQLBind("Jpuiter"))
                .values(SQLLiteral.default, SQLBind("Pluto"))
                .run().wait()

            try $0.select()
                .column(SQLFunction("count", args: "name"))
                .from("planets")
                .where("galaxyID", .equal, SQLBind(5))
                .run().wait()
            
            try $0.select()
                .column(SQLFunction("count", args: SQLLiteral.all))
                .from("planets")
                .where("galaxyID", .equal, SQLBind(5))
                .run().wait()
        }
    }
    
    private func testPlanets_alterSchema() throws {
        try self.runTest {
            // add columns for the sake of testing adding columns
            try $0.alter(table: "planets")
                .column("extra", type: .int)
                .run().wait()

            if $0.dialect.alterTableSyntax.allowsBatch {
                try $0.alter(table: "planets")
                    .column("very_extra", type: .bigint)
                    .column("extra_extra", type: .text)
                    .run().wait()

                // drop, add, and modify columns
                try $0.alter(table: "planets")
                    .dropColumn("extra_extra")
                    .update(column: "extra", type: .text)
                    .column("hi", type: .text)
                    .run().wait()
            }
        }
    }
}

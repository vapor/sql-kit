import XCTest
import SQLKit

extension SQLBenchmarker {
    public func testPlanets() async throws {
        try await self.testPlanets_createSchema()
        try await self.testPlanets_seedTables()
        try await self.testPlanets_alterSchema()
    }
    
    private func testPlanets_createSchema() async throws {
        try await self.runTest {
            try await $0.drop(table: "planets").ifExists()
                .run()
            try await $0.drop(table: "galaxies").ifExists()
                .run()
            try await $0.create(table: "galaxies")
                .column("id",       type: .bigint, .primaryKey)
                .column("name",     type: .text)
                .run()
            try await $0.create(table: "planets").ifNotExists()
                .column("id",       type: .bigint, .primaryKey)
                .column("galaxyID", type: .bigint, .references("galaxies", "id"))
                .run()
            try await $0.alter(table: "planets")
                .column("name",     type: .text,   .default(SQLLiteral.string("Unnamed Planet")))
                .run()
            try await $0.create(index: "test_index")
                .on("planets")
                .column("id")
                .unique()
                .run()
        }
    }

    private func testPlanets_seedTables() async throws {
        try await self.runTest {
            // INSERT INTO "galaxies" ("id", "name") VALUES (DEFAULT, $1)
            try await $0.insert(into: "galaxies")
                .columns("id", "name")
                .values(SQLLiteral.default, SQLBind("Milky Way"))
                .values(SQLLiteral.default, SQLBind("Andromeda"))
                // .value(Galaxy(name: "Milky Way"))
                .run()
            // SELECT * FROM galaxies WHERE name != NULL AND (name == ? OR name == ?)
            _ = try await $0.select()
                .column("*")
                .from("galaxies")
                .where("name", .notEqual, SQLLiteral.null)
                .where { $0
                    .where("name", .equal, SQLBind("Milky Way"))
                    .orWhere("name", .equal, SQLBind("Andromeda"))
                }
                .all()

            _ = try await $0.select()
                .column("*")
                .from("galaxies")
                .where(SQLColumn("name"), .equal, SQLBind("Milky Way"))
                .groupBy("id")
                .orderBy("name", .descending)
                .all()
            
            try await $0.insert(into: "planets")
                .columns("id", "name")
                .values(SQLLiteral.default, SQLBind("Earth"))
                .run()
            
            try await $0.insert(into: "planets")
                .columns("id", "name")
                .values(SQLLiteral.default, SQLBind("Mercury"))
                .values(SQLLiteral.default, SQLBind("Venus"))
                .values(SQLLiteral.default, SQLBind("Mars"))
                .values(SQLLiteral.default, SQLBind("Jpuiter"))
                .values(SQLLiteral.default, SQLBind("Pluto"))
                .run()

            try await $0.select()
                .column(SQLFunction("count", args: "name"))
                .from("planets")
                .where("galaxyID", .equal, SQLBind(5))
                .run()
            
            try await $0.select()
                .column(SQLFunction("count", args: SQLLiteral.all))
                .from("planets")
                .where("galaxyID", .equal, SQLBind(5))
                .run()
        }
    }
    
    private func testPlanets_alterSchema() async throws {
        try await self.runTest {
            // add columns for the sake of testing adding columns
            try await $0.alter(table: "planets")
                .column("extra", type: .int)
                .run()

            if $0.dialect.alterTableSyntax.allowsBatch {
                try await $0.alter(table: "planets")
                    .column("very_extra",  type: .bigint)
                    .column("extra_extra", type: .text)
                    .run()

                // drop, add, and modify columns
                try await $0.alter(table: "planets")
                    .dropColumn("extra_extra")
                    .update(column: "extra", type: .text)
                    .column("hi", type: .text)
                    .run()
            }
        }
    }
}

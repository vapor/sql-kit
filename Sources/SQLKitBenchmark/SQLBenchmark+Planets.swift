import XCTest
import SQLKit

extension SQLBenchmarker {
    func testPlanets() throws {
	let textType:SQLDataType = ( db.dialect.name == "mysql" ) ? .custom( SQLRaw("VARCHAR(255)") ) : .text
        try self.db.drop(table: "planets")
            .ifExists()
            .run().wait()
        try self.db.drop(table: "galaxies")
            .ifExists()
            .run().wait()
        try self.db.create(table: "galaxies")
            .column("id", type: .bigint, .primaryKey)
            .column("name", type: textType)
            .run().wait()
        try self.db.create(table: "planets")
            .ifNotExists()
            .column("id", type: .bigint, .primaryKey)
            .column("galaxyID", type: .bigint, .references("galaxies", "id"))
            .run().wait()
        try self.db.alter(table: "planets")
            .column("name", type: textType, .default(SQLLiteral.string("Unamed Planet")))
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
                .update(column: "extra", type: .text)
                .column("hi", type: .text)
                .run().wait()
        }
    }
}

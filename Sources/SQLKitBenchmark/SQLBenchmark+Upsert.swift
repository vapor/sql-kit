import XCTest
import SQLKit

extension SQLBenchmarker {
    public func testUpserts() async throws {
        guard self.database.dialect.upsertSyntax != .unsupported else { return }
        
        try await self.testUpserts_createSchema()
        try await self.testUpserts_ignoreAction()
        try await self.testUpserts_simpleUpdate()
        try await self.testUpserts_predicateUpdate()
        try await self.testUpserts_cleanupSchema()
    }
    
    // the test table name
    private static var testSchema: String { "stargate_construction_entries" }
    
    // column definitions for the test table
    private static var testColDefs: [SQLColumnDefinition] { [
        .init("id",                                             dataType: .bigint, constraints: [.primaryKey(autoIncrement: true), .notNull]),
        .init("planet_id",                                      dataType: .bigint, constraints: [/*.references("planets", "id"),*/ .notNull]),
        .init("point_of_origin"/*e.g. 𑀙,𑀵,ᛡ,𐋈,𑁍,𑁞,etc.*/,      dataType: .text,   constraints: [.notNull]),
        .init("naquadah_stabilizer_setting",                    dataType: .real,   constraints: [.default(SQLLiteral.null)]),
        .init("production_start",                               dataType: .real,   constraints: [.notNull]),
        .init("projected_completion",                           dataType: .real,   constraints: [.default(SQLLiteral.null)]),
        .init("last_status_update",                             dataType: .real,   constraints: [.default(SQLLiteral.null)]),
        .init("number_of_silly_pointless_fields_in_this_table", dataType: .bigint, constraints: [.default(Int64.max), .notNull]),
    ] }
    
    // list of column identifiers for the test table
    private static var testCols: [any SQLExpression] {
        self.testColDefs.map(\.column)
    }
    
    // generate a row of values for the test table suitable for passing to SQLInsertBuilder
    private static func testVals(
        id: Int? = nil,
        planet: Int,
        poi: String,
        setting: Double? = nil,
        start: Date = Date(),
        finish: Date? = nil,
        update: Date? = nil
    ) -> [any SQLExpression] { [
        id.map { SQLBind($0) } ?? SQLLiteral.default,
        SQLBind(planet),
        SQLBind(poi),
        SQLBind(setting),
        SQLBind(start.timeIntervalSince1970),
        SQLBind(finish?.timeIntervalSince1970),
        SQLBind(update?.timeIntervalSince1970),
        SQLBind(Int64.random(in: .min ... .max)) // SQLite makes specifying "use the default" hard for no reason
    ] }
    
    // do an insert of the given rows allowing extra config of the insert, if ok is false then assert that the insert
    // errors out otherwise assert that it does not
    private func testInsert(
        ok: Bool,
        _ vals: [any SQLExpression],
        on database: any SQLDatabase,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ moreConfig: (SQLInsertBuilder) -> SQLInsertBuilder = { $0 }
    ) async {
        if !ok {
            await XCTAssertThrowsErrorAsync(
                try await moreConfig(database.insert(into: Self.testSchema).columns(Self.testCols).values(vals)).run(),
                file: file, line: line
            ) { error in
                // TODO: Add a common error info protocol so we can validate that the error is a constraint violation
            }
        } else {
            await XCTAssertNoThrowAsync(
                try await moreConfig(database.insert(into: Self.testSchema).columns(Self.testCols).values(vals)).run(),
                file: file, line: line
            )
        }
    }

    // retrieve a count of all rows matching the criteria by the predicate, with the caller configuring the predicate
    private func testCount(on database: any SQLDatabase, _ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) async throws -> Int {
        let rows = try await predicate(database
            .select()
            .column(SQLFunction("COUNT", args: SQLLiteral.all))
            .from(Self.testSchema)
        )
        .all()
        return try rows[0].decode(column: rows[0].allColumns[0], as: Int.self)
    }
    
    /// Sets up tables and indexes used for testing.
    public func testUpserts_createSchema() async throws {
        try await self.runTest {
            let testValues: [Double?] = [
                /// 𝑐 - speed of light in a vacuum (cleaner)
                299_792_458.0,
                /// nothing
                nil,
                /// π - ratio of a circle's circumference to its diameter
                3.141592653589793238,
                /// 𝑒 - Euler's number
                2.7182818284,
                /// √2 - Pythagoras's constant
                1.4142135623,
                /// 𝒉×10³⁴ - 100 decillion times the Planck constant
                6.62607015,
            ]

            try await $0.drop(table: Self.testSchema)
                .ifExists()
                .run()
            try await $0.create(table: Self.testSchema)
                .column(definitions: Self.testColDefs)
                .unique(["planet_id", "point_of_origin"])
                .run()
            try await $0.insert(into: Self.testSchema)
                .columns(Self.testCols)
                .values(Self.testVals(planet: 1, poi: "A", setting: testValues[0], start: Date() - (31_557_600 * 1.8)))
                .values(Self.testVals(planet: 1, poi: "B", setting: testValues[1], start: Date() - 8_640_000.0, finish: Date.distantFuture))
                .values(Self.testVals(planet: 2, poi: "C", setting: testValues[2], start: Date() - 31_557_600_000.0))
                .values(Self.testVals(planet: 3, poi: "D", setting: testValues[3], start: Date.distantPast))
                .values(Self.testVals(planet: 4, poi: "E", setting: testValues[4], start: Date())) // Date.bigBang sadly isn't a thing
                .values(Self.testVals(planet: 4, poi: "F", setting: testValues[5], start: Date(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate.nextUp)))
                .run()
        }
    }
    
    /// Tests the "ignore conflicts" functionality. (Technically part of upserts.)
    public func testUpserts_ignoreAction() async throws {
        await self.runTest {
            await self.testInsert(ok: true,  Self.testVals(id: 1, planet: 5, poi: "0"), on: $0) { $0.ignoringConflicts(with: ["id"]) }
            guard $0.dialect.upsertSyntax != .mysqlLike else { return }
            await self.testInsert(ok: false, Self.testVals(id: 1, planet: 5, poi: "0"), on: $0) { $0.ignoringConflicts(with: ["planet_id"]) }
        }
    }
    
    /// Tests upserts with simple updates.
    public func testUpserts_simpleUpdate() async throws {
        try await self.runTest {
            await self.testInsert(ok: true, Self.testVals(id: 1, planet: 1, poi: "0"), on: $0) {
                $0.onConflict(with: ["id"]) {
                    $0.set("last_status_update", to: Date().timeIntervalSince1970)
                }
            }
            await XCTAssertEqualAsync(try await self.testCount(on: $0) { $0.where("last_status_update", .isNot, SQLLiteral.null) }, 1)
                
            await self.testInsert(ok: true, Self.testVals(planet: 2, poi: "C", update: Date()), on: $0) {
                $0.onConflict(with: ["planet_id", "point_of_origin"]) {
                    $0.set(excludedValueOf: "last_status_update")
                }
            }
            await XCTAssertEqualAsync(try await self.testCount(on: $0) { $0.where("planet_id", .equal, 2).where("point_of_origin", .equal, "C").where("last_status_update", .isNot, SQLLiteral.null) }, 1)
                
            /// Lots of other cases need verification - collisions with multiple uniques in the same row and different
            /// rows, updates of multiple rows, etc.
        }
    }
    
    /// Tests upserts with updates using predicates (when supported).
    public func testUpserts_predicateUpdate() async throws {
        try await self.runTest {
            guard $0.dialect.upsertSyntax != .mysqlLike else { return } // not supported by MySQL syntax
            
            await self.testInsert(ok: true, Self.testVals(planet: 4, poi: "F", update: Date()), on: $0) {
                $0.onConflict(with: ["planet_id", "point_of_origin"]) { $0
                    .set(excludedValueOf: "last_status_update")
                    .where(SQLExcludedColumn("last_status_update"), .is, SQLLiteral.null)
                }
            }
            await XCTAssertEqualAsync(try await self.testCount(on: $0) { $0.where("planet_id", .equal, 4).where("point_of_origin", .equal, "F").where("last_status_update", .isNot, SQLLiteral.null) }, 0)
        }
    }
    
    /// Remove tables used by these tests.
    public func testUpserts_cleanupSchema() async throws {
        try await self.runTest {
            try await $0.drop(table: Self.testSchema).run()
        }
    }
}

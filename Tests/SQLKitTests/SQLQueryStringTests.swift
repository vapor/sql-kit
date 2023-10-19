import SQLKit
import XCTest

final class SQLQueryStringTests: XCTestCase {
    var db: TestDatabase!

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    override func setUp() {
        super.setUp()
        self.db = TestDatabase()
    }

    func testRawCustomStringConvertible() {
        let field = "name"
        XCTAssertEqual(try self.db.raw("SELECT \(unsafeRaw: field) FROM users").simpleSerialize(), "SELECT name FROM users")
    }

    func testRawQueryStringInterpolation() {
        let (table, planet) = ("planets", "Earth")
        let output = XCTAssertNoThrowWithResult(try self.db.raw("SELECT * FROM \(ident: table) WHERE name = \(bind: planet)").advancedSerialize())
        
        XCTAssertEqual(output?.sql, "SELECT * FROM `planets` WHERE name = ?")
        XCTAssertEqual(output?.binds.first as? String, planet)
    }
    
    func testRawQueryStringWithNonliteral() throws {
        let (table, planet) = ("planets", "Earth")

        XCTAssertEqual(
            try self.db.raw(.init("SELECT * FROM \(table) WHERE name = \(planet)")).simpleSerialize(),
            "SELECT * FROM planets WHERE name = Earth"
        )

        XCTAssertEqual(
            try self.db.raw(.init("|||SELECT * FROM staticTable WHERE name = uselessUnboundValue|||".dropFirst(3).dropLast(3))).simpleSerialize(),
            "SELECT * FROM staticTable WHERE name = uselessUnboundValue"
        )
    }

    func testMakeQueryStringWithoutRawBuilder() {
        let queryString = SQLQueryString("query with \(ident: "identifier") and stuff")
        XCTAssertEqual(try self.db.raw(queryString).simpleSerialize(), "query with `identifier` and stuff")
    }
    
    func testAllQueryStringInterpolationTypes() {
        XCTAssertEqual(try self.db
            .raw("""
                Query string embeds:
                    \(unsafeRaw: "plain string embed")
                    \(bind: "single bind embed")
                    \(binds: ["multi-bind embed one", "multi-bind embed two"])
                    numeric literal embed \(literal: 1)
                    boolean literal embeds \(true) and \(false)
                    \(literal: "string literal embed")
                    \(literals: ["multi-literal embed one", "multi-literal embed two"], joinedBy: " || ")
                    \(ident: "string identifier embed")
                    \(idents: ["multi-ident embed one", "multi-ident embed two"], joinedBy: " + ")
                    expression embeds: \(SQLDropBehavior.restrict) and \(SQLDropBehavior.cascade)
                """
            ).simpleSerialize(),
            """
            Query string embeds:
                plain string embed
                ?
                ?, ?
                numeric literal embed 1
                boolean literal embeds true and false
                'string literal embed'
                'multi-literal embed one' || 'multi-literal embed two'
                `string identifier embed`
                `multi-ident embed one` + `multi-ident embed two`
                expression embeds: RESTRICT and CASCADE
            """
        )
    }
    
    func testAppendingQueryStringByOperatorPlus() {
        XCTAssertEqual(try self.db
            .raw(
                "INSERT INTO \(ident: "anything") " as SQLQueryString +
                "(\(idents: ["col1", "col2", "col3"], joinedBy: ",")) " as SQLQueryString +
                "VALUES (\(binds: [1, 2, 3]))" as SQLQueryString
            ).simpleSerialize(),
            "INSERT INTO `anything` (`col1`,`col2`,`col3`) VALUES (?, ?, ?)"
        )
    }
    
    func testAppendingQueryStringByOperatorPlusEquals() {
        var query = "INSERT INTO \(ident: "anything") " as SQLQueryString
        query += "(\(idents: ["col1", "col2", "col3"], joinedBy: ",")) " as SQLQueryString
        query += "VALUES (\(binds: [1, 2, 3]))" as SQLQueryString
        
        XCTAssertEqual(try self.db
            .raw(query)
            .simpleSerialize(),
            "INSERT INTO `anything` (`col1`,`col2`,`col3`) VALUES (?, ?, ?)"
        )
    }
    
    func testQueryStringArrayJoin() {
        XCTAssertEqual(try self.db
            .raw(
                "INSERT INTO \(ident: "anything") " as SQLQueryString +
                ((0..<5).map { "\(literal: "\($0)")" as SQLQueryString }).joined(separator: "..")
            )
            .simpleSerialize(),
            "INSERT INTO `anything` '0'..'1'..'2'..'3'..'4'"
        )
    }
}

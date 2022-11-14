import SQLKit
import SQLKitBenchmark
import XCTest

final class SQLQueryStringTests: XCTestCase {
    var db: TestDatabase!

    override func setUp() {
        super.setUp()
        self.db = TestDatabase()
    }

    func testRawQueryStringInterpolation() throws {
        let (table, planet) = ("planets", "Earth")
        let builder = db.raw("SELECT * FROM \(raw: table) WHERE name = \(bind: planet)")
        var serializer = SQLSerializer(database: db)
        builder.query.serialize(to: &serializer)

        XCTAssertEqual(serializer.sql, "SELECT * FROM planets WHERE name = ?")
        XCTAssertEqual(serializer.binds.first! as! String, planet)
    }
    
    func testRawQueryStringWithNonliteral() throws {
        let (table, planet) = ("planets", "Earth")

        var serializer1 = SQLSerializer(database: db)
        let query1 = "SELECT * FROM \(table) WHERE name = \(planet)"
        let builder1 = db.raw(.init(query1))
        builder1.query.serialize(to: &serializer1)
        XCTAssertEqual(serializer1.sql, "SELECT * FROM planets WHERE name = Earth")

        var serializer2 = SQLSerializer(database: db)
        let query2: Substring = "|||SELECT * FROM staticTable WHERE name = uselessUnboundValue|||".dropFirst(3).dropLast(3)
        let builder2 = db.raw(.init(query2))
        builder2.query.serialize(to: &serializer2)
        XCTAssertEqual(serializer2.sql, "SELECT * FROM staticTable WHERE name = uselessUnboundValue")
    }

    func testMakeQueryStringWithoutRawBuilder() throws {
        let queryString = SQLQueryString("query with \(ident: "identifier") and stuff")
        var serializer = SQLSerializer(database: db)
        let builder = db.raw(queryString)
        builder.query.serialize(to: &serializer)
        XCTAssertEqual(serializer.sql, "query with `identifier` and stuff")
    }
    
    func testAllQueryStringInterpolationTypes() throws {
        var serializer = SQLSerializer(database: db)
        let builder = db.raw("""
            Query string embeds:
                \(raw: "plain string embed")
                \(bind: "single bind embed")
                \(binds: ["multi-bind embed one", "multi-bind embed two"])
                numeric literal embed \(literal: 1)
                boolean literal embeds \(true) and \(false)
                \(literal: "string literal embed")
                \(literals: ["multi-literal embed one", "multi-literal embed two"], joinedBy: " || ")
                \(ident: "string identifier embed")
                \(idents: ["multi-ident embed one", "multi-ident embed two"], joinedBy: " + ")
                expression embeds: \(SQLDropBehavior.restrict) and \(SQLDropBehavior.cascade)
            """)
        builder.query.serialize(to: &serializer)
        XCTAssertEqual(serializer.sql, """
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
            """)
    }
    
    func testAppendingQueryStringByOperatorPlus() throws {
        var serializer = SQLSerializer(database: db)
        let builder = db.raw(
            "INSERT INTO \(ident: "anything") " as SQLQueryString +
            "(\(idents: ["col1", "col2", "col3"], joinedBy: ",")) " as SQLQueryString +
            "VALUES (\(binds: [1, 2, 3]))" as SQLQueryString
        )
        builder.query.serialize(to: &serializer)
        XCTAssertEqual(serializer.sql, "INSERT INTO `anything` (`col1`,`col2`,`col3`) VALUES (?, ?, ?)")
    }
    
    func testAppendingQueryStringByOperatorPlusEquals() throws {
        var serializer = SQLSerializer(database: db)
        
        var query = "INSERT INTO \(ident: "anything") " as SQLQueryString
        query += "(\(idents: ["col1", "col2", "col3"], joinedBy: ",")) " as SQLQueryString
        query += "VALUES (\(binds: [1, 2, 3]))" as SQLQueryString
        
        let builder = db.raw(query)
        builder.query.serialize(to: &serializer)
        XCTAssertEqual(serializer.sql, "INSERT INTO `anything` (`col1`,`col2`,`col3`) VALUES (?, ?, ?)")
    }
    
    func testQueryStringArrayJoin() throws {
        var serializer = SQLSerializer(database: db)
        let builder = db.raw(
            "INSERT INTO \(ident: "anything") " as SQLQueryString +
            ((0..<5).map { "\(literal: "\($0)")" as SQLQueryString }).joined(separator: "..")
        )
        builder.query.serialize(to: &serializer)
        XCTAssertEqual(serializer.sql, "INSERT INTO `anything` '0'..'1'..'2'..'3'..'4'")
    }
}

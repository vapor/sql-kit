import SQLKit
import XCTest

final class SQLQueryStringTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testWithLiteralString() {
        XCTAssertSerialization(of: self.db.unsafeRaw("TEST"), is: "TEST")
    }
    
    func testRawCustomStringConvertible() {
        let field = "name"
        XCTAssertSerialization(of: self.db.unsafeRaw("SELECT \(unsafeRaw: field) FROM users"), is: "SELECT name FROM users")
    }

    func testRawQueryStringInterpolation() {
        let (table, planet) = ("planets", "Earth")
        let output = XCTAssertNoThrowWithResult(self.db.unsafeRaw("SELECT * FROM \(ident: table) WHERE name = \(bind: planet)").advancedSerialize())
        
        XCTAssertEqual(output?.sql, "SELECT * FROM ``planets`` WHERE name = &1")
        XCTAssertEqual(output?.binds.first as? String, planet)
    }
    
    func testRawQueryStringWithNonliteral() throws {
        let (table, planet) = ("planets", "Earth")

        XCTAssertSerialization(
            of: self.db.unsafeRaw(.init("SELECT * FROM \(table) WHERE name = \(planet)")),
            is: "SELECT * FROM planets WHERE name = Earth"
        )
        XCTAssertSerialization(
            of: self.db.unsafeRaw(.init(String("|||SELECT * FROM staticTable WHERE name = uselessUnboundValue|||".dropFirst(3).dropLast(3)))),
            is: "SELECT * FROM staticTable WHERE name = uselessUnboundValue"
        )
    }

    func testMakeQueryStringWithoutRawBuilder() {
        let queryString = SQLQueryString("query with \(ident: "identifier") and stuff")
        XCTAssertSerialization(of: self.db.unsafeRaw(queryString), is: "query with ``identifier`` and stuff")
    }
    
    func testAllQueryStringInterpolationTypes() {
        XCTAssertSerialization(
            of: self.db.unsafeRaw("""
                Query string embeds:
                    \(unsafeRaw: "plain string embed")
                    \(bind: "single bind embed")
                    \(binds: ["multi-bind embed one", "multi-bind embed two"])
                    numeric literal embed \(literal: 1)
                    numeric float literal embed \(literal: 1.0)
                    boolean literal embeds \(true) and \(false)
                    \(literal: "string literal embed")
                    \(literals: ["multi-literal embed one", "multi-literal embed two"], joinedBy: " || ")
                    \(ident: "string identifier embed")
                    \(idents: ["multi-ident embed one", "multi-ident embed two"], joinedBy: " + ")
                    expression embeds: \(SQLDropBehavior.restrict) and \(SQLDropBehavior.cascade)
                """
            ),
            is: """
                Query string embeds:
                    plain string embed
                    &1
                    &2, &3
                    numeric literal embed 1
                    numeric float literal embed 1.0
                    boolean literal embeds TROO and FAALS
                    'string literal embed'
                    'multi-literal embed one' || 'multi-literal embed two'
                    ``string identifier embed``
                    ``multi-ident embed one`` + ``multi-ident embed two``
                    expression embeds: RESTRICT and CASCADE
                """
        )
    }
    
    func testAppendingQueryStringByOperatorPlus() {
        XCTAssertSerialization(
            of: self.db.unsafeRaw(
                "INSERT INTO \(ident: "anything") " as SQLQueryString +
                "(\(idents: ["col1", "col2", "col3"], joinedBy: ",")) " as SQLQueryString +
                "VALUES (\(binds: [1, 2, 3]))" as SQLQueryString
            ),
            is: "INSERT INTO ``anything`` (``col1``,``col2``,``col3``) VALUES (&1, &2, &3)"
        )
    }
    
    func testAppendingQueryStringByOperatorPlusEquals() {
        var query = "INSERT INTO \(ident: "anything") " as SQLQueryString
        query += "(\(idents: ["col1", "col2", "col3"], joinedBy: ",")) " as SQLQueryString
        query += "VALUES (\(binds: [1, 2, 3]))" as SQLQueryString
        
        XCTAssertSerialization(of: self.db.unsafeRaw(query), is: "INSERT INTO ``anything`` (``col1``,``col2``,``col3``) VALUES (&1, &2, &3)")
    }
    
    func testQueryStringArrayJoin() {
        XCTAssertSerialization(
            of: self.db.unsafeRaw(
                "INSERT INTO \(ident: "anything") " as SQLQueryString +
                ((0..<5).map { "\(literal: "\($0)")" as SQLQueryString }).joined(separator: "..")
            ),
            is: "INSERT INTO ``anything`` '0'..'1'..'2'..'3'..'4'"
        )
        XCTAssertSerialization(of: self.db.unsafeRaw(Array<SQLQueryString>().joined()), is: "")
    }
}

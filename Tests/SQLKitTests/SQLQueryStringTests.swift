import SQLKit
import Testing

@Suite("SQLQueryString tests")
struct QueryStringTests {
    @Test("with literal string")
    func withLiteralString() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("TEST"), is: "TEST")
    }

    @Test("raw CustomStringConvertible")
    func rawCustomStringConvertible() throws {
        let db = TestDatabase()
        let field = "name"
        try expectSerialization(of: db.raw("SELECT \(unsafeRaw: field) FROM users"), is: "SELECT name FROM users")
    }

    @Test("raw query string interpolation")
    func rawQueryStringInterpolation() {
        let db = TestDatabase()
        let (table, planet) = ("planets", "Earth")
        let output = db.raw("SELECT * FROM \(ident: table) WHERE name = \(bind: planet)").advancedSerialize()

        #expect(output.sql == "SELECT * FROM ``planets`` WHERE name = &1")
        #expect(output.binds.first as? String == planet)
    }

    @Test("raw query string with nonliteral")
    func rawQueryStringWithNonliteral() throws {
        let db = TestDatabase()
        let (table, planet) = ("planets", "Earth")

        try expectSerialization(
            of: db.raw(.init("SELECT * FROM \(table) WHERE name = \(planet)")),
            is: "SELECT * FROM planets WHERE name = Earth"
        )
        try expectSerialization(
            of: db.raw(.init(String("|||SELECT * FROM staticTable WHERE name = uselessUnboundValue|||".dropFirst(3).dropLast(3)))),
            is: "SELECT * FROM staticTable WHERE name = uselessUnboundValue"
        )
    }

    @Test("make query string without raw builder")
    func makeQueryStringWithoutRawBuilder() throws {
        let db = TestDatabase()
        let queryString = SQLQueryString("query with \(ident: "identifier") and stuff")

        try expectSerialization(of: db.raw(queryString), is: "query with ``identifier`` and stuff")
    }

    @Test("all query string interpolation types")
    func allQueryStringInterpolationTypes() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.raw("""
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

    @Test("appending query string by operator+")
    func appendingQueryStringByOperatorPlus() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.raw(
                "INSERT INTO \(ident: "anything") " as SQLQueryString +
                "(\(idents: ["col1", "col2", "col3"], joinedBy: ",")) " as SQLQueryString +
                "VALUES (\(binds: [1, 2, 3]))" as SQLQueryString
            ),
            is: "INSERT INTO ``anything`` (``col1``,``col2``,``col3``) VALUES (&1, &2, &3)"
        )
    }

    @Test("appending query string by operator+=")
    func appendingQueryStringByOperatorPlusEquals() throws {
        let db = TestDatabase()
        var query = "INSERT INTO \(ident: "anything") " as SQLQueryString
        query += "(\(idents: ["col1", "col2", "col3"], joinedBy: ",")) " as SQLQueryString
        query += "VALUES (\(binds: [1, 2, 3]))" as SQLQueryString

        try expectSerialization(of: db.raw(query), is: "INSERT INTO ``anything`` (``col1``,``col2``,``col3``) VALUES (&1, &2, &3)")
    }

    @Test("query string array join")
    func queryStringArrayJoin() throws {
        let db = TestDatabase()

        try expectSerialization(
            of: db.raw(
                "INSERT INTO \(ident: "anything") " as SQLQueryString +
                ((0..<5).map { "\(literal: "\($0)")" as SQLQueryString }).joined(separator: "..")
            ),
            is: "INSERT INTO ``anything`` '0'..'1'..'2'..'3'..'4'"
        )
        try expectSerialization(of: db.raw(Array<SQLQueryString>().joined()), is: "")
    }
}

@testable import SQLKit
import Testing

@Suite("Expression tests")
struct ExpressionTests {
    @Test("data types")
    func dataTypes() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLDataType.smallint)"), is: "SMALLINT")
        try expectSerialization(of: db.raw("\(SQLDataType.int)"), is: "INTEGER")
        try expectSerialization(of: db.raw("\(SQLDataType.bigint)"), is: "BIGINT")
        try expectSerialization(of: db.raw("\(SQLDataType.real)"), is: "REAL")
        try expectSerialization(of: db.raw("\(SQLDataType.text)"), is: "TEXT")
        try expectSerialization(of: db.raw("\(SQLDataType.blob)"), is: "BLOB")
        try expectSerialization(of: db.raw("\(SQLDataType.timestamp)"), is: "TIMESTAMP")
        try expectSerialization(of: db.raw("\(SQLDataType.custom(SQLRaw("STANDARD")))"), is: "CUSTOM")
    }

    @Test("directionalities")
    func directionalities() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLDirection.ascending)"), is: "ASC")
        try expectSerialization(of: db.raw("\(SQLDirection.descending)"), is: "DESC")
        try expectSerialization(of: db.raw("\(SQLDirection.null)"), is: "NULL")
        try expectSerialization(of: db.raw("\(SQLDirection.notNull)"), is: "NOT NULL")
    }

    @Test("DISTINCT expr")
    func distinctExpr() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLDistinct(Array<String>()))"), is: "")
        try expectSerialization(of: db.raw("\(SQLDistinct.all)"), is: "DISTINCT *")
        try expectSerialization(of: db.raw("\(SQLDistinct("a", "b"))"), is: "DISTINCT ``a``, ``b``")
        try expectSerialization(of: db.raw("\(SQLDistinct(["a", "b"]))"), is: "DISTINCT ``a``, ``b``")
        try expectSerialization(of: db.raw("\(SQLDistinct(SQLIdentifier("a"), SQLIdentifier("b")))"), is: "DISTINCT ``a``, ``b``")
        try expectSerialization(of: db.raw("\(SQLDistinct([SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "DISTINCT ``a``, ``b``")
    }

    @Test("FORIEGN KEY actions")
    func foreignKeyActions() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLForeignKeyAction.noAction)"), is: "NO ACTION")
        try expectSerialization(of: db.raw("\(SQLForeignKeyAction.restrict)"), is: "RESTRICT")
        try expectSerialization(of: db.raw("\(SQLForeignKeyAction.cascade)"), is: "CASCADE")
        try expectSerialization(of: db.raw("\(SQLForeignKeyAction.setNull)"), is: "SET NULL")
        try expectSerialization(of: db.raw("\(SQLForeignKeyAction.setDefault)"), is: "SET DEFAULT")
    }

    @Test("qualified table")
    func qualifiedTable() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLQualifiedTable("a", space: "b"))"), is: "``b``.``a``")
        try expectSerialization(of: db.raw("\(SQLQualifiedTable(SQLIdentifier("a"), space: SQLIdentifier("b")))"), is: "``b``.``a``")
    }

    @Test("alter column definition type")
    func alterColumnDefinitionType() throws {
        let db = TestDatabase()

        db._dialect.alterTableSyntax.alterColumnDefinitionTypeKeyword = nil
        try expectSerialization(of: db.raw("\(SQLAlterColumnDefinitionType(column: .init("a"), dataType: .int))"), is: "``a`` INTEGER")
        try expectSerialization(of: db.raw("\(SQLAlterColumnDefinitionType(column: SQLRaw("a"), dataType: SQLDataType.int))"), is: "a INTEGER")

        db._dialect.alterTableSyntax.alterColumnDefinitionTypeKeyword = SQLRaw("SET TYPE")
        try expectSerialization(of: db.raw("\(SQLAlterColumnDefinitionType(column: .init("a"), dataType: .int))"), is: "``a`` SET TYPE INTEGER")
        try expectSerialization(of: db.raw("\(SQLAlterColumnDefinitionType(column: SQLRaw("a"), dataType: SQLDataType.int))"), is: "a SET TYPE INTEGER")
    }

    @Test("column assignment")
    func columnAssignment() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLColumnAssignment(setting: "a", to: "b"))"), is: "``a`` = &1")
        try expectSerialization(of: db.raw("\(SQLColumnAssignment(setting: "a", to: SQLIdentifier("b")))"), is: "``a`` = ``b``")
        try expectSerialization(of: db.raw("\(SQLColumnAssignment(setting: SQLIdentifier("a"), to: "b"))"), is: "``a`` = &1")
        try expectSerialization(of: db.raw("\(SQLColumnAssignment(setting: SQLIdentifier("a"), to: SQLIdentifier("b")))"), is: "``a`` = ``b``")
        try expectSerialization(of: db.raw("\(SQLColumnAssignment(settingExcludedValueFor: "a"))"), is: "``a`` = EXCLUDED.``a``")
        try expectSerialization(of: db.raw("\(SQLColumnAssignment(settingExcludedValueFor: SQLIdentifier("a")))"), is: "``a`` = EXCLUDED.``a``")
    }

    @Test("column constraint algorithm")
    func columnConstraintAlgorithm() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))"), is: "PRIMARY KEY")
        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: true))"), is: "PRIMARY KEY AWWTOEINCREMENT")
        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.primaryKey)"), is: "PRIMARY KEY AWWTOEINCREMENT")

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.notNull)"), is: "NOT NULL")

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.unique)"), is: "UNIQUE")

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.check(SQLRaw("CHECK")))"), is: "CHECK (CHECK)")

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.collate(name: "ascii"))"), is: "COLLATE ``ascii``")
        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.collate(name: SQLIdentifier("ascii")))"), is: "COLLATE ``ascii``")

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.default("a"))"), is: "DEFAULT 'a'")
        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.default(1))"), is: "DEFAULT 1")
        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.default(1.0))"), is: "DEFAULT 1.0")
        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.default(true))"), is: "DEFAULT TROO")

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.references("a", "b", onDelete: .cascade, onUpdate: .cascade))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")
        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.references(SQLIdentifier("a"), SQLIdentifier("b"), onDelete: SQLForeignKeyAction.cascade, onUpdate: SQLForeignKeyAction.cascade))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")
        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.foreignKey(references: SQLForeignKey(table: SQLIdentifier("a"), columns: [SQLIdentifier("b")], onDelete: SQLForeignKeyAction.cascade, onUpdate: SQLForeignKeyAction.cascade)))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.generated(SQLRaw("value")))"), is: "GENERATED ALWAYS AS (value) STORED")

        try expectSerialization(of: db.raw("\(SQLColumnConstraintAlgorithm.custom(SQLRaw("whatever")))"), is: "whatever")
    }

    @Test("conflict resolution strategy")
    func conflictResolutionStrategy() throws {
        let db = TestDatabase()

        db._dialect.upsertSyntax = .standard
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: db) ?? SQLRaw(""))"), is: "")
        try expectSerialization(
            of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: "ON CONFLICT (``a``) DO UPDATE SET ``a`` = &1 WHERE ``a`` = ``b``"
        )
        try expectSerialization(
            of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: db) ?? SQLRaw(""))"),
            is: ""
        )

        db._dialect.upsertSyntax = .mysqlLike
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: db) ?? SQLRaw(""))"), is: "IGNORE")
        try expectSerialization(
            of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: "ON DUPLICATE KEY UPDATE ``a`` = &1"
        )
        try expectSerialization(
            of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: db) ?? SQLRaw(""))"),
            is: ""
        )

        db._dialect.upsertSyntax = .unsupported
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "")
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: db) ?? SQLRaw(""))"), is: "")
        try expectSerialization(
            of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: ""
        )
        try expectSerialization(
            of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: db) ?? SQLRaw(""))"),
            is: ""
        )

        db._dialect.upsertSyntax = .mysqlLike
        var serializer1 = SQLSerializer(database: db)
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: serializer1) ?? SQLRaw(""))"), is: "IGNORE")
        serializer1.statement {
            #expect((try? expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: $0) ?? SQLRaw(""))"), is: "IGNORE")) != nil)
        }

        db._dialect.upsertSyntax = .unsupported
        let serializer2 = SQLSerializer(database: db)
        try expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: serializer2) ?? SQLRaw(""))"), is: "")
        serializer1.statement {
            #expect((try? expectSerialization(of: db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: $0) ?? SQLRaw(""))"), is: "")) != nil)
        }
    }

    @Test("enum data type")
    func enumDataType() throws {
        let db = TestDatabase()

        db._dialect.enumSyntax = .inline
        try expectSerialization(of: db.raw("\(SQLDataType.enum("a", "b"))"), is: "ENUM ('a', 'b')")
        try expectSerialization(of: db.raw("\(SQLDataType.enum(["a", "b"]))"), is: "ENUM ('a', 'b')")
        try expectSerialization(of: db.raw("\(SQLDataType.enum([SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "ENUM ('a', 'b')")
        try expectSerialization(of: db.raw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "ENUM ('a', 'b')")
        try expectSerialization(of: db.raw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "ENUM ('a', 'b')")
        db._dialect.enumSyntax = .typeName
        try expectSerialization(of: db.raw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "TEXT")
        try expectSerialization(of: db.raw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "TEXT")
        db._dialect.enumSyntax = .unsupported
        try expectSerialization(of: db.raw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "TEXT")
        try expectSerialization(of: db.raw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "TEXT")
    }

    @Test("excluded column")
    func excludedColumn() throws {
        let db = TestDatabase()

        db._dialect.upsertSyntax = .standard
        try expectSerialization(of: db.raw("\(SQLExcludedColumn("a"))"), is: "EXCLUDED.``a``")
        try expectSerialization(of: db.raw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "EXCLUDED.``a``")
        db._dialect.upsertSyntax = .mysqlLike
        try expectSerialization(of: db.raw("\(SQLExcludedColumn("a"))"), is: "VALUES(``a``)")
        try expectSerialization(of: db.raw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "VALUES(``a``)")
        db._dialect.upsertSyntax = .unsupported
        try expectSerialization(of: db.raw("\(SQLExcludedColumn("a"))"), is: "")
        try expectSerialization(of: db.raw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "")
    }

    @available(*, deprecated, message: "Tests deprecated functionality")
    @Test("join method")
    func joinMethod() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLJoinMethod.inner)"), is: "INNER")
        try expectSerialization(of: db.raw("\(SQLJoinMethod.outer)"), is: "OUTER")
        try expectSerialization(of: db.raw("\(SQLJoinMethod.left)"), is: "LEFT")
        try expectSerialization(of: db.raw("\(SQLJoinMethod.right)"), is: "RIGHT")
    }

    @Test("RETURNING expr")
    func returningExpr() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLReturning(SQLColumn("a")))"), is: "RETURNING ``a``")
        try expectSerialization(of: db.raw("\(SQLReturning([SQLColumn("a")]))"), is: "RETURNING ``a``")
        try expectSerialization(of: db.raw("\(SQLReturning([]))"), is: "")
    }

    @Test("ALTER TABLE query")
    func alterTableQuery() throws {
        let db = TestDatabase()
        var query = SQLAlterTable(name: SQLIdentifier("table"))

        query.renameTo = SQLIdentifier("table2")
        query.addColumns = [SQLColumnDefinition("a", dataType: .bigint)]
        query.modifyColumns = [SQLAlterColumnDefinitionType(column: "b", dataType: .blob)]
        query.dropColumns = [SQLColumn("c")]
        query.addTableConstraints = [SQLTableConstraintAlgorithm.unique(columns: [SQLColumn("d")])]
        query.dropTableConstraints = [SQLIdentifier("e")]

        db._dialect.alterTableSyntax.allowsBatch = false
        db._dialect.alterTableSyntax.alterColumnDefinitionClause = nil
        try expectSerialization(of: db.raw("\(query)"), is: "ALTER TABLE ``table`` RENAME TO ``table2`` ADD ``a`` BIGINT , ADD UNIQUE (``d``) , DROP ``c`` , DROP ``e`` , __INVALID__ ``b`` BLOB")

        db._dialect.alterTableSyntax.allowsBatch = true
        db._dialect.alterTableSyntax.alterColumnDefinitionClause = SQLRaw("MODIFY")
        try expectSerialization(of: db.raw("\(query)"), is: "ALTER TABLE ``table`` RENAME TO ``table2`` ADD ``a`` BIGINT , ADD UNIQUE (``d``) , DROP ``c`` , DROP ``e`` , MODIFY ``b`` BLOB")
    }

    @Test("CREATE INDEX query")
    func createIndexQuery() throws {
        let db = TestDatabase()
        var query = SQLCreateIndex(name: SQLIdentifier("index"))

        query.table = SQLIdentifier("table")
        query.modifier = SQLColumnConstraintAlgorithm.unique
        query.columns = [SQLIdentifier("a"), SQLIdentifier("b")]
        query.predicate = SQLBinaryExpression(SQLIdentifier("c"), .equal, SQLIdentifier("d"))
        try expectSerialization(of: db.raw("\(query)"), is: "CREATE UNIQUE INDEX ``index`` ON ``table`` (``a``, ``b``) WHERE ``c`` = ``d``")
    }

    @Test("binary operators")
    func binaryOperators() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLBinaryOperator.equal)"), is: "=")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.notEqual)"), is: "<>")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.greaterThan)"), is: ">")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.lessThan)"), is: "<")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.greaterThanOrEqual)"), is: ">=")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.lessThanOrEqual)"), is: "<=")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.like)"), is: "LIKE")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.notLike)"), is: "NOT LIKE")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.in)"), is: "IN")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.notIn)"), is: "NOT IN")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.and)"), is: "AND")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.or)"), is: "OR")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.multiply)"), is: "*")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.divide)"), is: "/")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.modulo)"), is: "%")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.add)"), is: "+")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.subtract)"), is: "-")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.is)"), is: "IS")
        try expectSerialization(of: db.raw("\(SQLBinaryOperator.isNot)"), is: "IS NOT")
    }

    @Test("function initializers")
    func functionInitializers() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLFunction("test", args: "a", "b"))"), is: "test(``a``, ``b``)")
        try expectSerialization(of: db.raw("\(SQLFunction("test", args: ["a", "b"]))"), is: "test(``a``, ``b``)")
        try expectSerialization(of: db.raw("\(SQLFunction("test", args: SQLIdentifier("a"), SQLIdentifier("b")))"), is: "test(``a``, ``b``)")
        try expectSerialization(of: db.raw("\(SQLFunction("test", args: [SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "test(``a``, ``b``)")
    }

    @Test("COALESCE function")
    func coalesceFunction() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLFunction.coalesce(SQLIdentifier("a"), SQLIdentifier("b")))"), is: "COALESCE(``a``, ``b``)")
        try expectSerialization(of: db.raw("\(SQLFunction.coalesce([SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "COALESCE(``a``, ``b``)")
    }

    @Test("weird quoting")
    func weirdQuoting() throws {
        let db = TestDatabase()

        db._dialect.identifierQuote = SQLQueryString("_")
        db._dialect.literalStringQuote = SQLQueryString("~")
        try expectSerialization(of: db.raw("\(ident: "hello") \(literal: "there")"), is: "_hello_ ~there~")
    }

    @Test("columns")
    func columns() throws {
        let db = TestDatabase()

        try expectSerialization(of: db.raw("\(SQLColumn("*"))"), is: "*")
        try expectSerialization(of: db.raw("\(SQLColumn(SQLIdentifier("*")))"), is: "``*``")
        try expectSerialization(of: db.raw("\(SQLColumn(SQLLiteral.all))"), is: "*")
        try expectSerialization(of: db.raw("\(SQLColumn("*", table: "foo"))"), is: "``foo``.*")
        try expectSerialization(of: db.raw("\(SQLColumn(SQLIdentifier("*"), table: SQLIdentifier("foo")))"), is: "``foo``.``*``")
        try expectSerialization(of: db.raw("\(SQLColumn(SQLLiteral.all, table: SQLIdentifier("foo")))"), is: "``foo``.*")
    }
}

@testable import SQLKit
import XCTest

final class SQLExpressionTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testDataTypes() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.smallint)"), is: "SMALLINT")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.int)"), is: "INTEGER")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.bigint)"), is: "BIGINT")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.real)"), is: "REAL")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.text)"), is: "TEXT")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.blob)"), is: "BLOB")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.timestamp)"), is: "TIMESTAMP")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.custom(SQLUnsafeRaw("STANDARD")))"), is: "CUSTOM")
    }
    
    func testDirectionalities() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDirection.ascending)"), is: "ASC")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDirection.descending)"), is: "DESC")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDirection.null)"), is: "NULL")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDirection.notNull)"), is: "NOT NULL")
    }
    
    func testDistinctExpr() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDistinct(Array<String>()))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDistinct.all)"), is: "DISTINCT *")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDistinct("a", "b"))"), is: "DISTINCT ``a``, ``b``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDistinct(["a", "b"]))"), is: "DISTINCT ``a``, ``b``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDistinct(SQLIdentifier("a"), SQLIdentifier("b")))"), is: "DISTINCT ``a``, ``b``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDistinct([SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "DISTINCT ``a``, ``b``")
    }
    
    func testForeignKeyActions() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLForeignKeyAction.noAction)"), is: "NO ACTION")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLForeignKeyAction.restrict)"), is: "RESTRICT")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLForeignKeyAction.cascade)"), is: "CASCADE")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLForeignKeyAction.setNull)"), is: "SET NULL")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLForeignKeyAction.setDefault)"), is: "SET DEFAULT")
    }
    
    func testQualifiedTable() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLQualifiedTable("a", space: "b"))"), is: "``b``.``a``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLQualifiedTable(SQLIdentifier("a"), space: SQLIdentifier("b")))"), is: "``b``.``a``")
    }
    
    func testAlterColumnDefinitionType() {
        self.db._dialect.alterTableSyntax.alterColumnDefinitionTypeKeyword = nil
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLAlterColumnDefinitionType(column: .init("a"), dataType: .int))"), is: "``a`` INTEGER")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLAlterColumnDefinitionType(column: SQLUnsafeRaw("a"), dataType: SQLDataType.int))"), is: "a INTEGER")

        self.db._dialect.alterTableSyntax.alterColumnDefinitionTypeKeyword = SQLUnsafeRaw("SET TYPE")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLAlterColumnDefinitionType(column: .init("a"), dataType: .int))"), is: "``a`` SET TYPE INTEGER")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLAlterColumnDefinitionType(column: SQLUnsafeRaw("a"), dataType: SQLDataType.int))"), is: "a SET TYPE INTEGER")
    }
    
    func testColumnAssignment() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnAssignment(setting: "a", to: "b"))"), is: "``a`` = &1")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnAssignment(setting: "a", to: SQLIdentifier("b")))"), is: "``a`` = ``b``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnAssignment(setting: SQLIdentifier("a"), to: "b"))"), is: "``a`` = &1")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnAssignment(setting: SQLIdentifier("a"), to: SQLIdentifier("b")))"), is: "``a`` = ``b``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnAssignment(settingExcludedValueFor: "a"))"), is: "``a`` = EXCLUDED.``a``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnAssignment(settingExcludedValueFor: SQLIdentifier("a")))"), is: "``a`` = EXCLUDED.``a``")
    }
    
    func testColumnConstraintAlgorithm() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))"), is: "PRIMARY KEY")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: true))"), is: "PRIMARY KEY AWWTOEINCREMENT")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.primaryKey)"), is: "PRIMARY KEY AWWTOEINCREMENT")

        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.notNull)"), is: "NOT NULL")

        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.unique)"), is: "UNIQUE")

        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.check(SQLUnsafeRaw("CHECK")))"), is: "CHECK (CHECK)")

        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.collate(name: "ascii"))"), is: "COLLATE ``ascii``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.collate(name: SQLIdentifier("ascii")))"), is: "COLLATE ``ascii``")

        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.default("a"))"), is: "DEFAULT 'a'")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.default(1))"), is: "DEFAULT 1")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.default(1.0))"), is: "DEFAULT 1.0")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.default(true))"), is: "DEFAULT TROO")

        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.references("a", "b", onDelete: .cascade, onUpdate: .cascade))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.references(SQLIdentifier("a"), SQLIdentifier("b"), onDelete: SQLForeignKeyAction.cascade, onUpdate: SQLForeignKeyAction.cascade))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.foreignKey(references: SQLForeignKey(table: SQLIdentifier("a"), columns: [SQLIdentifier("b")], onDelete: SQLForeignKeyAction.cascade, onUpdate: SQLForeignKeyAction.cascade)))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")

        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.generated(SQLUnsafeRaw("value")))"), is: "GENERATED ALWAYS AS (value) STORED")

        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumnConstraintAlgorithm.custom(SQLUnsafeRaw("whatever")))"), is: "whatever")
    }
    
    func testConflictResolutionStrategy() {
        self.db._dialect.upsertSyntax = .standard
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: self.db) ?? SQLUnsafeRaw(""))"), is: "")
        XCTAssertSerialization(
            of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: "ON CONFLICT (``a``) DO UPDATE SET ``a`` = &1 WHERE ``a`` = ``b``"
        )
        XCTAssertSerialization(
            of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: self.db) ?? SQLUnsafeRaw(""))"),
            is: ""
        )

        self.db._dialect.upsertSyntax = .mysqlLike
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: self.db) ?? SQLUnsafeRaw(""))"), is: "IGNORE")
        XCTAssertSerialization(
            of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: "ON DUPLICATE KEY UPDATE ``a`` = &1"
        )
        XCTAssertSerialization(
            of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: self.db) ?? SQLUnsafeRaw(""))"),
            is: ""
        )

        self.db._dialect.upsertSyntax = .unsupported
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: self.db) ?? SQLUnsafeRaw(""))"), is: "")
        XCTAssertSerialization(
            of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: ""
        )
        XCTAssertSerialization(
            of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: self.db) ?? SQLUnsafeRaw(""))"),
            is: ""
        )
        
        self.db._dialect.upsertSyntax = .mysqlLike
        var serializer1 = SQLSerializer(database: self.db)
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: serializer1) ?? SQLUnsafeRaw(""))"), is: "IGNORE")
        serializer1.statement {
            XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: $0) ?? SQLUnsafeRaw(""))"), is: "IGNORE")
        }

        self.db._dialect.upsertSyntax = .unsupported
        let serializer2 = SQLSerializer(database: self.db)
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: serializer2) ?? SQLUnsafeRaw(""))"), is: "")
        serializer1.statement {
            XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: $0) ?? SQLUnsafeRaw(""))"), is: "")
        }
    }
    
    func testEnumDataType() {
        self.db._dialect.enumSyntax = .inline
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.enum("a", "b"))"), is: "ENUM ('a', 'b')")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.enum(["a", "b"]))"), is: "ENUM ('a', 'b')")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLDataType.enum([SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "ENUM ('a', 'b')")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "ENUM ('a', 'b')")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "ENUM ('a', 'b')")
        self.db._dialect.enumSyntax = .typeName
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "TEXT")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "TEXT")
        self.db._dialect.enumSyntax = .unsupported
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "TEXT")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "TEXT")
    }
    
    func testExcludedColumn() {
        self.db._dialect.upsertSyntax = .standard
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLExcludedColumn("a"))"), is: "EXCLUDED.``a``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "EXCLUDED.``a``")
        self.db._dialect.upsertSyntax = .mysqlLike
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLExcludedColumn("a"))"), is: "VALUES(``a``)")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "VALUES(``a``)")
        self.db._dialect.upsertSyntax = .unsupported
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLExcludedColumn("a"))"), is: "")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "")
    }
    
    @available(*, deprecated, message: "Tests deprecated functionality")
    func testJoinMethod() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLJoinMethod.inner)"), is: "INNER")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLJoinMethod.outer)"), is: "OUTER")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLJoinMethod.left)"), is: "LEFT")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLJoinMethod.right)"), is: "RIGHT")
    }
    
    func testReturningExpr() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLReturning(SQLColumn("a")))"), is: "RETURNING ``a``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLReturning([SQLColumn("a")]))"), is: "RETURNING ``a``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLReturning([]))"), is: "")
    }
    
    func testAlterTableQuery() {
        var query = SQLAlterTable(name: SQLIdentifier("table"))
        
        query.renameTo = SQLIdentifier("table2")
        query.addColumns = [SQLColumnDefinition("a", dataType: .bigint)]
        query.modifyColumns = [SQLAlterColumnDefinitionType(column: "b", dataType: .blob)]
        query.dropColumns = [SQLColumn("c")]
        query.addTableConstraints = [SQLTableConstraintAlgorithm.unique(columns: [SQLColumn("d")])]
        query.dropTableConstraints = [SQLIdentifier("e")]

        self.db._dialect.alterTableSyntax.allowsBatch = false
        self.db._dialect.alterTableSyntax.alterColumnDefinitionClause = nil
        XCTAssertSerialization(of: self.db.unsafeRaw("\(query)"), is: "ALTER TABLE ``table`` RENAME TO ``table2`` ADD ``a`` BIGINT , ADD UNIQUE (``d``) , DROP ``c`` , DROP ``e`` , __INVALID__ ``b`` BLOB")

        self.db._dialect.alterTableSyntax.allowsBatch = true
        self.db._dialect.alterTableSyntax.alterColumnDefinitionClause = SQLUnsafeRaw("MODIFY")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(query)"), is: "ALTER TABLE ``table`` RENAME TO ``table2`` ADD ``a`` BIGINT , ADD UNIQUE (``d``) , DROP ``c`` , DROP ``e`` , MODIFY ``b`` BLOB")
    }
    
    func testCreateIndexQuery() {
        var query = SQLCreateIndex(name: SQLIdentifier("index"))
        
        query.table = SQLIdentifier("table")
        query.modifier = SQLColumnConstraintAlgorithm.unique
        query.columns = [SQLIdentifier("a"), SQLIdentifier("b")]
        query.predicate = SQLBinaryExpression(SQLIdentifier("c"), .equal, SQLIdentifier("d"))
        XCTAssertSerialization(of: self.db.unsafeRaw("\(query)"), is: "CREATE UNIQUE INDEX ``index`` ON ``table`` (``a``, ``b``) WHERE ``c`` = ``d``")
    }
    
    func testBinaryOperators() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.equal)"), is: "=")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.notEqual)"), is: "<>")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.greaterThan)"), is: ">")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.lessThan)"), is: "<")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.greaterThanOrEqual)"), is: ">=")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.lessThanOrEqual)"), is: "<=")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.like)"), is: "LIKE")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.notLike)"), is: "NOT LIKE")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.in)"), is: "IN")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.notIn)"), is: "NOT IN")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.and)"), is: "AND")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.or)"), is: "OR")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.multiply)"), is: "*")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.divide)"), is: "/")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.modulo)"), is: "%")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.add)"), is: "+")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.subtract)"), is: "-")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.is)"), is: "IS")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLBinaryOperator.isNot)"), is: "IS NOT")
    }
    
    func testFunctionInitializers() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLFunction("test", args: "a", "b"))"), is: "test(``a``, ``b``)")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLFunction("test", args: ["a", "b"]))"), is: "test(``a``, ``b``)")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLFunction("test", args: SQLIdentifier("a"), SQLIdentifier("b")))"), is: "test(``a``, ``b``)")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLFunction("test", args: [SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "test(``a``, ``b``)")
    }
    
    func testCoalesceFunction() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLFunction.coalesce(SQLIdentifier("a"), SQLIdentifier("b")))"), is: "COALESCE(``a``, ``b``)")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLFunction.coalesce([SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "COALESCE(``a``, ``b``)")
    }
    
    func testWeirdQuoting() {
        self.db._dialect.identifierQuote = SQLQueryString("_")
        self.db._dialect.literalStringQuote = SQLQueryString("~")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(ident: "hello") \(literal: "there")"), is: "_hello_ ~there~")
    }
    
    func testColumns() {
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumn("*"))"), is: "*")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumn(SQLIdentifier("*")))"), is: "``*``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumn(SQLLiteral.all))"), is: "*")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumn("*", table: "foo"))"), is: "``foo``.*")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumn(SQLIdentifier("*"), table: SQLIdentifier("foo")))"), is: "``foo``.``*``")
        XCTAssertSerialization(of: self.db.unsafeRaw("\(SQLColumn(SQLLiteral.all, table: SQLIdentifier("foo")))"), is: "``foo``.*")
    }
}

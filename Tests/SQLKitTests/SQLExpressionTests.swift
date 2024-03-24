@testable import SQLKit
import XCTest

final class SQLExpressionTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testDataTypes() {
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.smallint)"), is: "SMALLINT")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.int)"), is: "INTEGER")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.bigint)"), is: "BIGINT")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.real)"), is: "REAL")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.text)"), is: "TEXT")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.blob)"), is: "BLOB")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.timestamp)"), is: "TIMESTAMP")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.custom(SQLRaw("STANDARD")))"), is: "CUSTOM")
    }
    
    func testDirectionalities() {
        XCTAssertSerialization(of: self.db.raw("\(SQLDirection.ascending)"), is: "ASC")
        XCTAssertSerialization(of: self.db.raw("\(SQLDirection.descending)"), is: "DESC")
        XCTAssertSerialization(of: self.db.raw("\(SQLDirection.null)"), is: "NULL")
        XCTAssertSerialization(of: self.db.raw("\(SQLDirection.notNull)"), is: "NOT NULL")
    }
    
    func testDistinctExpr() {
        XCTAssertSerialization(of: self.db.raw("\(SQLDistinct(Array<String>()))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLDistinct.all)"), is: "DISTINCT *")
        XCTAssertSerialization(of: self.db.raw("\(SQLDistinct("a", "b"))"), is: "DISTINCT ``a``, ``b``")
        XCTAssertSerialization(of: self.db.raw("\(SQLDistinct(["a", "b"]))"), is: "DISTINCT ``a``, ``b``")
        XCTAssertSerialization(of: self.db.raw("\(SQLDistinct(SQLIdentifier("a"), SQLIdentifier("b")))"), is: "DISTINCT ``a``, ``b``")
        XCTAssertSerialization(of: self.db.raw("\(SQLDistinct([SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "DISTINCT ``a``, ``b``")
    }
    
    func testForeignKeyActions() {
        XCTAssertSerialization(of: self.db.raw("\(SQLForeignKeyAction.noAction)"), is: "NO ACTION")
        XCTAssertSerialization(of: self.db.raw("\(SQLForeignKeyAction.restrict)"), is: "RESTRICT")
        XCTAssertSerialization(of: self.db.raw("\(SQLForeignKeyAction.cascade)"), is: "CASCADE")
        XCTAssertSerialization(of: self.db.raw("\(SQLForeignKeyAction.setNull)"), is: "SET NULL")
        XCTAssertSerialization(of: self.db.raw("\(SQLForeignKeyAction.setDefault)"), is: "SET DEFAULT")
    }
    
    func testQualifiedTable() {
        XCTAssertSerialization(of: self.db.raw("\(SQLQualifiedTable("a", space: "b"))"), is: "``b``.``a``")
        XCTAssertSerialization(of: self.db.raw("\(SQLQualifiedTable(SQLIdentifier("a"), space: SQLIdentifier("b")))"), is: "``b``.``a``")
    }
    
    func testAlterColumnDefinitionType() {
        self.db._dialect.alterTableSyntax.alterColumnDefinitionTypeKeyword = nil
        XCTAssertSerialization(of: self.db.raw("\(SQLAlterColumnDefinitionType(column: .init("a"), dataType: .int))"), is: "``a`` INTEGER")
        XCTAssertSerialization(of: self.db.raw("\(SQLAlterColumnDefinitionType(column: SQLRaw("a"), dataType: SQLDataType.int))"), is: "a INTEGER")
        
        self.db._dialect.alterTableSyntax.alterColumnDefinitionTypeKeyword = SQLRaw("SET TYPE")
        XCTAssertSerialization(of: self.db.raw("\(SQLAlterColumnDefinitionType(column: .init("a"), dataType: .int))"), is: "``a`` SET TYPE INTEGER")
        XCTAssertSerialization(of: self.db.raw("\(SQLAlterColumnDefinitionType(column: SQLRaw("a"), dataType: SQLDataType.int))"), is: "a SET TYPE INTEGER")
    }
    
    func testColumnAssignment() {
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnAssignment(setting: "a", to: "b"))"), is: "``a`` = &1")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnAssignment(setting: "a", to: SQLIdentifier("b")))"), is: "``a`` = ``b``")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnAssignment(setting: SQLIdentifier("a"), to: "b"))"), is: "``a`` = &1")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnAssignment(setting: SQLIdentifier("a"), to: SQLIdentifier("b")))"), is: "``a`` = ``b``")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnAssignment(settingExcludedValueFor: "a"))"), is: "``a`` = EXCLUDED.``a``")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnAssignment(settingExcludedValueFor: SQLIdentifier("a")))"), is: "``a`` = EXCLUDED.``a``")
    }
    
    func testColumnConstraintAlgorithm() {
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: false))"), is: "PRIMARY KEY")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.primaryKey(autoIncrement: true))"), is: "PRIMARY KEY AWWTOEINCREMENT")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.primaryKey)"), is: "PRIMARY KEY AWWTOEINCREMENT")

        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.notNull)"), is: "NOT NULL")

        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.unique)"), is: "UNIQUE")

        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.check(SQLRaw("CHECK")))"), is: "CHECK (CHECK)")

        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.collate(name: "ascii"))"), is: "COLLATE ``ascii``")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.collate(name: SQLIdentifier("ascii")))"), is: "COLLATE ``ascii``")

        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.default("a"))"), is: "DEFAULT 'a'")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.default(1))"), is: "DEFAULT 1")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.default(1.0))"), is: "DEFAULT 1.0")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.default(true))"), is: "DEFAULT TROO")

        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.references("a", "b", onDelete: .cascade, onUpdate: .cascade))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.references(SQLIdentifier("a"), SQLIdentifier("b"), onDelete: SQLForeignKeyAction.cascade, onUpdate: SQLForeignKeyAction.cascade))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")
        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.foreignKey(references: SQLForeignKey(table: SQLIdentifier("a"), columns: [SQLIdentifier("b")], onDelete: SQLForeignKeyAction.cascade, onUpdate: SQLForeignKeyAction.cascade)))"), is: "REFERENCES ``a`` (``b``) ON DELETE CASCADE ON UPDATE CASCADE")

        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.generated(SQLRaw("value")))"), is: "GENERATED ALWAYS AS (value) STORED")

        XCTAssertSerialization(of: self.db.raw("\(SQLColumnConstraintAlgorithm.custom(SQLRaw("whatever")))"), is: "whatever")
    }
    
    func testConflictResolutionStrategy() {
        self.db._dialect.upsertSyntax = .standard
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "ON CONFLICT (``a``) DO NOTHING")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: self.db) ?? SQLRaw(""))"), is: "")
        XCTAssertSerialization(
            of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: "ON CONFLICT (``a``) DO UPDATE SET ``a`` = &1 WHERE ``a`` = ``b``"
        )
        XCTAssertSerialization(
            of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: self.db) ?? SQLRaw(""))"),
            is: ""
        )

        self.db._dialect.upsertSyntax = .mysqlLike
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: self.db) ?? SQLRaw(""))"), is: "IGNORE")
        XCTAssertSerialization(
            of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: "ON DUPLICATE KEY UPDATE ``a`` = &1"
        )
        XCTAssertSerialization(
            of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: self.db) ?? SQLRaw(""))"),
            is: ""
        )

        self.db._dialect.upsertSyntax = .unsupported
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(targets: ["a"], action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: SQLIdentifier("a"), action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(targets: [SQLIdentifier("a")], action: .noAction))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: self.db) ?? SQLRaw(""))"), is: "")
        XCTAssertSerialization(
            of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))))"),
            is: ""
        )
        XCTAssertSerialization(
            of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .update(assignments: [SQLColumnAssignment(setting: "a", to: "b")], predicate: SQLBinaryExpression(SQLIdentifier("a"), .equal, SQLIdentifier("b")))).queryModifier(for: self.db) ?? SQLRaw(""))"),
            is: ""
        )
        
        self.db._dialect.upsertSyntax = .mysqlLike
        var serializer1 = SQLSerializer(database: self.db)
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: serializer1) ?? SQLRaw(""))"), is: "IGNORE")
        serializer1.statement {
            XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: $0) ?? SQLRaw(""))"), is: "IGNORE")
        }

        self.db._dialect.upsertSyntax = .unsupported
        let serializer2 = SQLSerializer(database: self.db)
        XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: serializer2) ?? SQLRaw(""))"), is: "")
        serializer1.statement {
            XCTAssertSerialization(of: self.db.raw("\(SQLConflictResolutionStrategy(target: "a", action: .noAction).queryModifier(for: $0) ?? SQLRaw(""))"), is: "")
        }
    }
    
    func testEnumDataType() {
        self.db._dialect.enumSyntax = .inline
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.enum("a", "b"))"), is: "ENUM ('a', 'b')")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.enum(["a", "b"]))"), is: "ENUM ('a', 'b')")
        XCTAssertSerialization(of: self.db.raw("\(SQLDataType.enum([SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "ENUM ('a', 'b')")
        XCTAssertSerialization(of: self.db.raw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "ENUM ('a', 'b')")
        XCTAssertSerialization(of: self.db.raw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "ENUM ('a', 'b')")
        self.db._dialect.enumSyntax = .typeName
        XCTAssertSerialization(of: self.db.raw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "TEXT")
        XCTAssertSerialization(of: self.db.raw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "TEXT")
        self.db._dialect.enumSyntax = .unsupported
        XCTAssertSerialization(of: self.db.raw("\(SQLEnumDataType(cases: ["a", "b"]))"), is: "TEXT")
        XCTAssertSerialization(of: self.db.raw("\(SQLEnumDataType(cases: [SQLLiteral.string("a"), SQLLiteral.string("b")]))"), is: "TEXT")
    }
    
    func testExcludedColumn() {
        self.db._dialect.upsertSyntax = .standard
        XCTAssertSerialization(of: self.db.raw("\(SQLExcludedColumn("a"))"), is: "EXCLUDED.``a``")
        XCTAssertSerialization(of: self.db.raw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "EXCLUDED.``a``")
        self.db._dialect.upsertSyntax = .mysqlLike
        XCTAssertSerialization(of: self.db.raw("\(SQLExcludedColumn("a"))"), is: "VALUES(``a``)")
        XCTAssertSerialization(of: self.db.raw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "VALUES(``a``)")
        self.db._dialect.upsertSyntax = .unsupported
        XCTAssertSerialization(of: self.db.raw("\(SQLExcludedColumn("a"))"), is: "")
        XCTAssertSerialization(of: self.db.raw("\(SQLExcludedColumn(SQLIdentifier("a")))"), is: "")
    }
    
    @available(*, deprecated, message: "Tests deprecated functionality")
    func testJoinMethod() {
        XCTAssertSerialization(of: self.db.raw("\(SQLJoinMethod.inner)"), is: "INNER")
        XCTAssertSerialization(of: self.db.raw("\(SQLJoinMethod.outer)"), is: "OUTER")
        XCTAssertSerialization(of: self.db.raw("\(SQLJoinMethod.left)"), is: "LEFT")
        XCTAssertSerialization(of: self.db.raw("\(SQLJoinMethod.right)"), is: "RIGHT")
    }
    
    func testReturningExpr() {
        XCTAssertSerialization(of: self.db.raw("\(SQLReturning(SQLColumn("a")))"), is: "RETURNING ``a``")
        XCTAssertSerialization(of: self.db.raw("\(SQLReturning([SQLColumn("a")]))"), is: "RETURNING ``a``")
        XCTAssertSerialization(of: self.db.raw("\(SQLReturning([]))"), is: "")
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
        XCTAssertSerialization(of: self.db.raw("\(query)"), is: "ALTER TABLE ``table`` RENAME TO ``table2`` ADD ``a`` BIGINT , ADD UNIQUE (``d``) , DROP ``c`` , DROP ``e`` , __INVALID__ ``b`` BLOB")

        self.db._dialect.alterTableSyntax.allowsBatch = true
        self.db._dialect.alterTableSyntax.alterColumnDefinitionClause = SQLRaw("MODIFY")
        XCTAssertSerialization(of: self.db.raw("\(query)"), is: "ALTER TABLE ``table`` RENAME TO ``table2`` ADD ``a`` BIGINT , ADD UNIQUE (``d``) , DROP ``c`` , DROP ``e`` , MODIFY ``b`` BLOB")
    }
    
    func testCreateIndexQuery() {
        var query = SQLCreateIndex(name: SQLIdentifier("index"))
        
        query.table = SQLIdentifier("table")
        query.modifier = SQLColumnConstraintAlgorithm.unique
        query.columns = [SQLIdentifier("a"), SQLIdentifier("b")]
        query.predicate = SQLBinaryExpression(SQLIdentifier("c"), .equal, SQLIdentifier("d"))
        XCTAssertSerialization(of: self.db.raw("\(query)"), is: "CREATE UNIQUE INDEX ``index`` ON ``table`` (``a``, ``b``) WHERE ``c`` = ``d``")
    }
    
    func testBinaryOperators() {
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.equal)"), is: "=")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.notEqual)"), is: "<>")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.greaterThan)"), is: ">")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.lessThan)"), is: "<")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.greaterThanOrEqual)"), is: ">=")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.lessThanOrEqual)"), is: "<=")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.like)"), is: "LIKE")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.notLike)"), is: "NOT LIKE")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.in)"), is: "IN")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.notIn)"), is: "NOT IN")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.and)"), is: "AND")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.or)"), is: "OR")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.multiply)"), is: "*")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.divide)"), is: "/")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.modulo)"), is: "%")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.add)"), is: "+")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.subtract)"), is: "-")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.is)"), is: "IS")
        XCTAssertSerialization(of: self.db.raw("\(SQLBinaryOperator.isNot)"), is: "IS NOT")
    }
    
    func testFunctionInitializers() {
        XCTAssertSerialization(of: self.db.raw("\(SQLFunction("test", args: "a", "b"))"), is: "test(``a``, ``b``)")
        XCTAssertSerialization(of: self.db.raw("\(SQLFunction("test", args: ["a", "b"]))"), is: "test(``a``, ``b``)")
        XCTAssertSerialization(of: self.db.raw("\(SQLFunction("test", args: SQLIdentifier("a"), SQLIdentifier("b")))"), is: "test(``a``, ``b``)")
        XCTAssertSerialization(of: self.db.raw("\(SQLFunction("test", args: [SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "test(``a``, ``b``)")
    }
    
    func testCoalesceFunction() {
        XCTAssertSerialization(of: self.db.raw("\(SQLFunction.coalesce(SQLIdentifier("a"), SQLIdentifier("b")))"), is: "COALESCE(``a``, ``b``)")
        XCTAssertSerialization(of: self.db.raw("\(SQLFunction.coalesce([SQLIdentifier("a"), SQLIdentifier("b")]))"), is: "COALESCE(``a``, ``b``)")
    }
    
    func testWeirdQuoting() {
        self.db._dialect.identifierQuote = SQLQueryString("_")
        self.db._dialect.literalStringQuote = SQLQueryString("~")
        XCTAssertSerialization(of: self.db.raw("\(ident: "hello") \(literal: "there")"), is: "_hello_ ~there~")
    }
}

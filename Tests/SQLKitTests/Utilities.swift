import SQLKit
import NIOCore
@_implementationOnly import NIOEmbedded
import Logging
import XCTest

struct Serialized {
    let sql: String
    let binds: [any Encodable]
}
    
extension SQLQueryBuilder {
    func simpleSerialize() throws -> String { self.database.serialize(self.query).sql }
    
    func advancedSerialize() throws -> Serialized {
        let result = self.database.serialize(self.query)
        return .init(sql: result.sql, binds: result.binds)
    }
}

final class TestDatabase: SQLDatabase {
    let logger: Logger = .init(label: "codes.vapor.sql.test")
    let eventLoop: any EventLoop = EmbeddedEventLoop()
    var results: [String] = []
    var bindResults: [[any Encodable]] = []
    var dialect: any SQLDialect { self._dialect }
    var _dialect: GenericDialect = .init()
    
    func execute(sql query: any SQLExpression, _ onRow: @escaping (any SQLRow) -> ()) -> EventLoopFuture<Void> {
        let (sql, binds) = self.serialize(query)
        results.append(sql)
        bindResults.append(binds)
        return self.eventLoop.makeSucceededFuture(())
    }
}

struct TestRow: SQLRow {
    var data: [String: (any Encodable)?]

    var allColumns: [String] { .init(self.data.keys) }
    func contains(column: String) -> Bool { self.data.keys.contains(column) }
    func decodeNil(column: String) throws -> Bool { if case .some(.some(_)) = self.data[column] { return false } else { return true } }
    func decode<D: Decodable & Sendable>(column: String, as: D.Type) throws -> D {
        let key = SomeCodingKey(stringValue: column)
        guard self.contains(column: column) else {
            throw DecodingError.keyNotFound(key, .init(codingPath: [], debugDescription: "No value associated with key '\(column)'."))
        }
        guard case let .some(.some(value)) = self.data[column] else {
            throw DecodingError.valueNotFound(D.self, .init(codingPath: [key], debugDescription: "No value of type \(D.self) associated with key '\(column)'."))
        }
        guard let cast = value as? D else {
            throw DecodingError.typeMismatch(D.self, .init(codingPath: [key], debugDescription: "Expected to decode \(D.self) but found \(type(of: value)) instead."))
        }
        return cast
    }
}

struct GenericDialect: SQLDialect {
    var name: String { "generic" }

    func bindPlaceholder(at position: Int) -> any SQLExpression { SQLRaw("?") }
    func literalBoolean(_ value: Bool) -> any SQLExpression { SQLRaw("\(value)") }
    var supportsAutoIncrement: Bool = true
    var supportsIfExists: Bool = true
    var supportsReturning: Bool = true
    var identifierQuote: any SQLExpression = SQLRaw("`")
    var literalStringQuote: any SQLExpression = SQLRaw("'")
    var enumSyntax: SQLEnumSyntax = .inline
    var autoIncrementClause: any SQLExpression = SQLRaw("AUTOINCREMENT")
    var autoIncrementFunction: (any SQLExpression)? = nil
    var supportsDropBehavior: Bool = false
    var triggerSyntax = SQLTriggerSyntax(create: [], drop: [])
    var alterTableSyntax = SQLAlterTableSyntax(alterColumnDefinitionClause: SQLRaw("MODIFY"), alterColumnDefinitionTypeKeyword: nil)
    var upsertSyntax: SQLUpsertSyntax = .standard
    var unionFeatures: SQLUnionFeatures = []
    var sharedSelectLockExpression: (any SQLExpression)? { SQLRaw("FOR SHARE") }
    var exclusiveSelectLockExpression: (any SQLExpression)? { SQLRaw("FOR UPDATE") }
    func nestedSubpathExpression(in column: any SQLExpression, for path: [String]) -> (any SQLExpression)? {
        precondition(!path.isEmpty)
        let descender = SQLList([column] + path.dropLast().map(SQLLiteral.string(_:)), separator: SQLRaw("->"))
        return SQLGroupExpression(SQLList([descender, SQLLiteral.string(path.last!)], separator: SQLRaw("->>")))
    }

    mutating func setTriggerSyntax(create: SQLTriggerSyntax.Create = [], drop: SQLTriggerSyntax.Drop = []) {
        self.triggerSyntax.create = create
        self.triggerSyntax.drop = drop
    }
}

func XCTAssertNoThrowWithResult<T>(
    _ expression: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) -> T? {
    var result: T?
    XCTAssertNoThrow(result = try expression(), message(), file: file, line: line)
    return result
}

let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        handler.logLevel = ProcessInfo.processInfo.environment["LOG_LEVEL"].flatMap { Logger.Level(rawValue: $0) } ?? .info
        return handler
    }
    return true
}()

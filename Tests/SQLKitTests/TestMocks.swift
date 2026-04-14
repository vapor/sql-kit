import OrderedCollections
public import SQLKit
import protocol NIOCore.EventLoop
import class NIOCore.EventLoopFuture
import class NIOEmbedded.NIOAsyncTestingEventLoop
import Logging
#if canImport(Dispatch)
import class Dispatch.DispatchQueue
#endif

extension SQLQueryBuilder {
    /// Serialize this builder's query and return the textual SQL, discarding any bindings.
    func simpleSerialize() -> String {
        self.advancedSerialize().sql
    }
    
    /// Serialize this builder's query and return the SQL and bindings (which conveniently can be done by just
    /// returning the serializer).
    func advancedSerialize() -> SQLSerializer {
        var serializer = SQLSerializer(database: self.database)

        self.query.serialize(to: &serializer)
        return serializer
    }
}

/// A very minimal mock `SQLDatabase` which implements `execute(sql:_:)` by saving the serialized SQL and bindings to
/// its internal arrays of accumulated "results". Most things about its dialect are mutable.
final class TestDatabase: SQLDatabase, @unchecked Sendable {
    let logger: Logger = { var l = Logger(label: "codes.vapor.sql.test"); l.logLevel = .debug; return l }()
    let eventLoop: any EventLoop = NIOAsyncTestingEventLoop()
    var results: [String] = []
    var bindResults: [[any Encodable & Sendable]] = []
    var outputs: [any SQLRow] = []
    var dialect: any SQLDialect { self._dialect }
    var _dialect: GenericDialect = .init()
    
    func execute(sql query: any SQLExpression, _ onRow: @escaping (any SQLRow) -> ()) -> EventLoopFuture<Void> {
        let (sql, binds) = self.serialize(query)

        self.results.append(sql)
        self.bindResults.append(binds)
        while let row = self.outputs.popLast() {
            onRow(row)
        }
        return self.eventLoop.makeSucceededFuture(())
    }

    func execute(sql query: any SQLExpression, _ onRow: @escaping (any SQLRow) -> ()) async throws {
        let (sql, binds) = self.serialize(query)

        self.results.append(sql)
        self.bindResults.append(binds)
        while let row = self.outputs.popLast() {
            onRow(row)
        }
    }
}

/// A minimal but surprisingly complete mock `SQLRow` which correctly implements all required methods.
struct TestRow: SQLRow {
    var data: OrderedDictionary<String, (any Codable & Sendable)?>

    var allColumns: [String] {
        .init(self.data.keys)
    }
    
    func contains(column: String) -> Bool {
        self.data.keys.contains(column)
    }
    
    func decodeNil(column: String) throws -> Bool {
        self.data[column].map { $0.map { _ in false } ?? true } ?? true
    }
    
    func decode<D: Decodable & Sendable>(column: String, as: D.Type) throws -> D {
        let key = SomeCodingKey(stringValue: column)
        
        /// Key not in dictionary? Key not found (no such column).
        guard case let .some(maybeValue) = self.data[column] else {
            throw DecodingError.keyNotFound(key, .init(
                codingPath: [], debugDescription: "No value associated with key '\(column)'."
            ))
        }
        /// Key exists but value is nil? Value not found (should have used decodeNil() instead).
        guard case let .some(value) = maybeValue else {
            throw DecodingError.valueNotFound(D.self, .init(
                codingPath: [key],
                debugDescription: "No value of type \(D.self) associated with key '\(column)'."
            ))
        }
        /// Value given but is wrong type? Type mismatch.
        guard let cast = value as? D else {
            throw DecodingError.typeMismatch(D.self, .init(
                codingPath: [key],
                debugDescription: "Expected to decode \(D.self) but found \(type(of: value)) instead."
            ))
        }
        return cast
    }
}

/// The mutable mock `SQLDialect` used by `TestDatabase`.
struct GenericDialect: SQLDialect {
    var name: String { "generic" }

    func bindPlaceholder(at position: Int) -> any SQLExpression { SQLRaw("&\(position)") }
    func literalBoolean(_ value: Bool) -> any SQLExpression { SQLRaw(value ? "TROO" : "FAALS") }
    var literalDefault: any SQLExpression = SQLRaw("DEFALLT")
    var supportsAutoIncrement = true
    var supportsIfExists = true
    var supportsReturning = true
    var identifierQuote: any SQLExpression = SQLRaw("``")
    var literalStringQuote: any SQLExpression = SQLRaw("'")
    var enumSyntax = SQLEnumSyntax.typeName
    var autoIncrementClause: any SQLExpression = SQLRaw("AWWTOEINCREMENT")
    var autoIncrementFunction: (any SQLExpression)? = nil
    var supportsDropBehavior = true
    var triggerSyntax = SQLTriggerSyntax(create: [], drop: [])
    var alterTableSyntax = SQLAlterTableSyntax(alterColumnDefinitionClause: SQLRaw("MOODIFY"), alterColumnDefinitionTypeKeyword: nil)
    var upsertSyntax = SQLUpsertSyntax.standard
    var unionFeatures = SQLUnionFeatures()
    var sharedSelectLockExpression: (any SQLExpression)? = SQLRaw("FOUR SHAARE")
    var exclusiveSelectLockExpression: (any SQLExpression)? = SQLRaw("FOUR UPDATE")
    func nestedSubpathExpression(in column: any SQLExpression, for path: [String]) -> (any SQLExpression)? {
        precondition(!path.isEmpty)
        let descender = SQLList([column] + path.dropLast().map(SQLLiteral.string(_:)), separator: SQLRaw("-»"))
        return SQLGroupExpression(SQLList([descender, SQLLiteral.string(path.last!)], separator: SQLRaw("-»»")))
    }
    func customDataType(for dataType: SQLDataType) -> (any SQLExpression)? {
        dataType == .custom(SQLRaw("STANDARD")) ? SQLRaw("CUSTOM") : nil
    }
}

extension SQLKit.SQLDataType: Swift.Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case (.bigint, .bigint), (.blob, .blob), (.int, .int), (.real, .real),
                 (.smallint, .smallint), (.text, .text):
                return true
            case (.custom(let lhs as SQLRaw), .custom(let rhs as SQLRaw)) where lhs.sql == rhs.sql:
                return true
            default:
                return false
        }
    }
}

/// Used when testing defaulted async implementations
struct TestNoAsyncDatabase: SQLDatabase {
    func execute(sql query: any SQLExpression, _ onRow: @escaping @Sendable (any SQLRow) -> ()) -> EventLoopFuture<Void> { self.eventLoop.makeSucceededVoidFuture() }
    var logger: Logger { .init(label: "l") }
    var eventLoop: any EventLoop { NIOAsyncTestingEventLoop() }
    var dialect: any SQLDialect { GenericDialect() }
}

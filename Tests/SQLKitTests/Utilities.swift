import SQLKit
import NIOCore
import NIOEmbedded
import Logging

final class TestDatabase: SQLDatabase {
    let logger: Logger
    let eventLoop: any EventLoop
    var results: [String]
    var bindResults: [[any Encodable]]
    var dialect: any SQLDialect { self._dialect }
    var _dialect: GenericDialect
    
    init() {
        self.logger = .init(label: "codes.vapor.sql.test")
        self.eventLoop = EmbeddedEventLoop()
        self.results = []
        self.bindResults = []
        self._dialect = GenericDialect()
    }
    
    func execute(sql query: any SQLExpression, _ onRow: @escaping (any SQLRow) -> ()) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(database: self)
        query.serialize(to: &serializer)
        results.append(serializer.sql)
        bindResults.append(serializer.binds)
        return self.eventLoop.makeSucceededFuture(())
    }
}

struct TestRow: SQLRow {
    enum Datum { // yes, this is just Optional by another name
        case some(any Encodable)
        case none
    }
    
    var data: [String: Datum]

    enum _Error: Error {
        case missingColumn(String)
        case typeMismatch(Any, Any.Type)
    }

    var allColumns: [String] {
        .init(self.data.keys)
    }

    func contains(column: String) -> Bool {
        self.data.keys.contains(column)
    }

    func decodeNil(column: String) throws -> Bool {
        if case .some(.none) = self.data[column] { return true }
        return false
    }

    func decode<D>(column: String, as type: D.Type) throws -> D
        where D : Decodable
    {
        guard case let .some(.some(value)) = self.data[column] else {
            throw _Error.missingColumn(column)
        }
        guard let cast = value as? D else {
            throw _Error.typeMismatch(value, D.self)
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

    mutating func setTriggerSyntax(create: SQLTriggerSyntax.Create = [], drop: SQLTriggerSyntax.Drop = []) {
        self.triggerSyntax.create = create
        self.triggerSyntax.drop = drop
    }
}

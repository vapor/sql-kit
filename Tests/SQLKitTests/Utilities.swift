import SQLKit
import NIO

final class TestDatabase: SQLDatabase {
    let logger: Logger
    let eventLoop: EventLoop
    var results: [String]
    var dialect: SQLDialect {
        self._dialect
    }
    var _dialect: GenericDialect
    
    init() {
        self.logger = .init(label: "codes.vapor.sql.test")
        self.eventLoop = EmbeddedEventLoop()
        self.results = []
        self._dialect = GenericDialect()
    }
    
    func execute(sql query: SQLExpression, _ onRow: @escaping (SQLRow) -> ()) -> EventLoopFuture<Void> {
        var serializer = SQLSerializer(database: self)
        query.serialize(to: &serializer)
        results.append(serializer.sql)
        return self.eventLoop.makeSucceededFuture(())
    }
}

struct TestRow: SQLRow {
    var data: [String: Any]

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
        if let value = self.data[column], let optional = value as? OptionalType {
            return optional.isNil
        } else {
            return false
        }
    }

    func decode<D>(column: String, as type: D.Type) throws -> D
        where D : Decodable
    {
        guard let value = self.data[column] else {
            throw _Error.missingColumn(column)
        }
        guard let cast = value as? D else {
            throw _Error.typeMismatch(value, D.self)
        }
        return cast
    }
}

protocol OptionalType {
    var isNil: Bool { get }
}

extension Optional: OptionalType {
    var isNil: Bool {
        self == nil
    }
}

struct GenericDialect: SQLDialect {
    var supportsAutoIncrement: Bool = true

    var name: String = "generic sql"
    
    var supportsIfExists: Bool = true

    var supportsReturning: Bool = true

    var identifierQuote: SQLExpression {
        return SQLRaw("`")
    }
    
    var literalStringQuote: SQLExpression {
        return SQLRaw("'")
    }
    
    func bindPlaceholder(at position: Int) -> SQLExpression {
        return SQLRaw("?")
    }
    
    func literalBoolean(_ value: Bool) -> SQLExpression {
        switch value {
        case true: return SQLRaw("true")
        case false: return SQLRaw("false")
        }
    }

    var enumSyntax: SQLEnumSyntax = .inline
    
    var autoIncrementClause: SQLExpression {
        return SQLRaw("AUTOINCREMENT")
    }

    var autoIncrementFunction: SQLExpression? = nil

    var supportsDropBehavior: Bool = false

    var triggerSyntax = SQLTriggerSyntax()

    var alterTableSyntax = SQLAlterTableSyntax(alterColumnDefinitionClause: SQLRaw("MODIFY"), alterColumnDefinitionTypeKeyword: nil)

    mutating func setTriggerSyntax(create: SQLTriggerSyntax.Create = [], drop: SQLTriggerSyntax.Drop = []) {
        self.triggerSyntax.create = create
        self.triggerSyntax.drop = drop
    }
}

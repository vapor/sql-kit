#warning("add collate")
#warning("add cast")

/// A SQL expression, i.e., a column name, value placeholder, function,
/// subquery, or binary expression.
///
/// These expression are evaluated by the SQL engine and are used throughout many
/// types in this package.
///
/// This type is also highly recursive. Binary expressions, for example, have a left
/// and right sub expression and so on. Function expressions have zero or more arguments
/// that are also expressions.
//public protocol SQLExpression: SQLSerializable {
//    var isNull: Bool { get }
//}

public struct SQLFunction: SQLExpression {
    public let name: String
    public let args: [SQLExpression]
    
    
    public init(_ name: String, args: String...) {
        self.init(name, args: args.map { SQLIdentifier($0) })
    }
    
    public init(_ name: String, args: SQLExpression...) {
        self.init(name, args: args)
    }
    
    public init(_ name: String, args: [SQLExpression] = []) {
        self.name = name
        self.args = args
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self.name)
        serializer.write("(")
        self.args.serialize(to: &serializer, joinedBy: ", ")
        serializer.write(")")
    }
}

public struct SQLBinaryExpression: SQLExpression {
    public let left: SQLExpression
    public let op: SQLExpression
    public let right: SQLExpression
    
    public init(left: SQLExpression, op: SQLExpression, right: SQLExpression) {
        self.left = left
        self.op = op
        self.right = right
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        self.left.serialize(to: &serializer)
        serializer.write(" ")
        self.op.serialize(to: &serializer)
        serializer.write(" ")
        self.right.serialize(to: &serializer)
    }
}

public struct SQLGroupExpression: SQLExpression {
    public let expression: SQLExpression
    
    public init(_ expression: SQLExpression) {
        self.expression = expression
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("(")
        self.expression.serialize(to: &serializer)
        serializer.write(")")
    }
}

//public enum SQLExpression: SQLSerializable {
//    /// Literal strings, integers, and constants.
//    case literal(SQLLiteral)
//
//    /// Bound value.
//    case bind(SQLBind)
//
//    /// Binary expression.
//    case binary(SQLSerializable, SQLSerializable, SQLSerializable)
//
//    /// Creates a new `SQLFunction`.
//    case function(String, [SQLExpression])
//
//    /// Group of expressions.
//    case group([SQLSerializable])
//
//    /// `(SELECT ...)`
//    case subquery(SQLSerializable)
//
//    /// Special expression type, all, `*`.
//    case all(table: SQLSerializable?)
//
//    case alias(SQLSerializable, as: SQLSerializable)
//
//    /// Creates a new `SQLExpression` from a raw SQL string.
//    /// This will be included in the query as is, no escaping.
//    case raw(String)
//
//    public var isNull: Bool {
//        switch self {
//        case .literal(let literal):
//            return literal.isNull
//        default: return false
//        }
//    }
//
//    public func serialize(to serializer: SQLSerializer) {
//        switch self {
//        case .literal(let literal):
//            literal.serialize(to: serializer)
//        case .column(let column):
//            column.serialize(to: serializer)
//        default:
//            print(self)
//            fatalError()
//        }
//    }
//}

// MARK: Convenience
//
//extension SQLExpression {
//    public static var all: SQLExpression {
//        return .all(table: nil)
//    }
//
//    /// Convenience for creating a function call.
//    ///
//    ///     .function("UUID")
//    ///
//    public static func function(_ name: String) -> SQLExpression {
//        return .function(name, [])
//    }
//
//    /// Convenience for creating a `SUM(foo)` function call on a given KeyPath.
//    ///
//    ///     .sum(\Planet.mass)
//    ///
//    public static func sum(_ column: String) -> SQLExpression {
//        return .function("SUM", [
//            .column(SQLColumnIdentifier(name: GenericSQLIdentifier(string: column)))
//        ])
//    }

//    /// Convenience for creating a `COUNT(foo)` function call on a given KeyPath.
//    ///
//    ///     .count(\Planet.id)
//    ///
//    public static func count(_ column: Self) -> Self {
//        return .function("COUNT", [column])
//    }
//
//    /// Variadic convenience method for creating a group of expressions.
//    ///
//    ///     .group(a, b, c)
//    ///
//    public static func group(_ exprs: Self...) -> Self {
//        return group(exprs)
//    }
//
//    /// Bound value. Shorthand for `.bind(.encodable(...))`.
//    public static func bind<E>(_ value: E) -> Self
//        where E: Encodable
//    {
//        return bind(.encodable(value))
//    }
//
//    /// Bound value. Shorthand for `.bind(.encodable(...))`.
//    public static func binds<E>(_ values: [E]) -> Self
//        where E: Encodable
//    {
//        return group(values.map { .bind($0) })
//    }
//
//    static func coalesce(_ expressions: [Self]) -> Self {
//        return self.function("COALESCE", expressions)
//    }
//
//    /// Convenience for creating a `COALESCE(foo)` function call (returns the first non-null expression).
//    public static func coalesce(_ exprs: Self...) -> Self {
//        return coalesce(exprs)
//    }
//}

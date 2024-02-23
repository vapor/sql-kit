/// A fundamental syntactical expression - one of several various kinds of literal SQL expressions.
///
/// The supported literal types are:
///
/// - ``SQLLiteral/all``:
/// - ``SQLLiteral/default``:
/// - ``SQLLiteral/null``: SQL's `NULL` keyword. ()
/// - ``SQLLiteral/boolean(_:)``: A boolean value (`true` or `false`). May be serialized as `0` and `1` in some
///   dialects, or `true` and `false` in others.
/// - ``SQLLiteral/numeric(_:)``: Any numeric value.
/// - ``SQLLiteral/string(_:)``: A quoted and escaped string literal.
public enum SQLLiteral: SQLExpression {
    /// The `*` symbol, when used as a column name (but _not_ when used as the multiplication operator),
    /// meaning "all columns".
    case all
    
    /// An ``SQLLiteral`` representing the current dialect's equivalent of the `DEFAULT` keyword.
    ///
    /// > Note: There isn't really any reason for this to be a literal with special handling, especially since there
    /// > aren't any dialects which don't use `DEFAULT` as their ``SQLDialect/literalDefault-4l1ox`` but it's
    /// > long-standing public API.
    case `default`
    
    /// An ``SQLLiteral`` representing an SQL `NULL`  in the current dialect.
    ///
    /// > Note: This makes more sense as a literal; although `NULL` is a keyword, it nonetheless represents a
    /// > specific literal value.
    case null
    
    /// An ``SQLLiteral`` representing a boolean literal in the current dialect.
    case boolean(Bool)
    
    /// An ``SQLLiteral`` representing a numeric literal in the current dialect.
    ///
    /// Because the range of supported numeric types between SQL dialects is extremely wide, and that range rarely
    /// at best overlaps cleanyl with Swift's numeric type support, numeric literals are specified using their
    /// stringified representations.
    case numeric(String)
    
    /// An ``SQLLiteral`` representing a literal string in the current dialect.
    ///
    /// Literal strings undergo quoting and escaping in exactly the same fashion described by ``SQLIdentifier``,
    /// except the dialect's ``SQLDialect/literalStringQuote-2vqlo`` is used.
    case string(String)
    
    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .all:                  serializer.write("*")
        case .default:              serializer.dialect.literalDefault.serialize(to: &serializer)
        case .null:                 serializer.write("NULL")
        case .boolean(let bool):    serializer.dialect.literalBoolean(bool).serialize(to: &serializer)
        case .numeric(let numeric): serializer.write(numeric)
        case .string(let string):
            /// See ``SQLIdentifier/serialize(to:)`` for a discussion on why this is written the way it is.
            if let rawQuote = (serializer.dialect.literalStringQuote as? SQLRaw)?.sql {
                serializer.write("\(rawQuote)\(string.sqlkit_replacing(rawQuote, with: "\(rawQuote)\(rawQuote)"))\(rawQuote)")
            } else {
                serializer.dialect.literalStringQuote.serialize(to: &serializer)
                serializer.write(string)
                serializer.dialect.literalStringQuote.serialize(to: &serializer)
            }
        }
    }
}

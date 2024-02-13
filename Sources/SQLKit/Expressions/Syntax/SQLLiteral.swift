/// Literal expression value, i.e., `DEFAULT`, `FALSE`, `42`, etc.
public enum SQLLiteral: SQLExpression {
    /// `*`
    case all
    
    /// An ``SQLLiteral`` representing the current dialect's equivalent of the `DEFAULT` keyword.
    case `default`
    
    /// An ``SQLLiteral`` representing an SQL `NULL`  in the current dialect.
    case null
    
    /// An ``SQLLiteral`` representing a boolean literal in the current dialect.
    case boolean(Bool)
    
    /// An ``SQLLiteral`` representing a numeric literal in the current dialect.
    case numeric(String)
    
    /// An ``SQLLiteral`` representing a literal string in the current dialect.
    case string(String)
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .all:                  serializer.write("*")
        case .default:              serializer.dialect.literalDefault.serialize(to: &serializer)
        case .null:                 serializer.write("NULL")
        case .boolean(let bool):    serializer.dialect.literalBoolean(bool).serialize(to: &serializer)
        case .numeric(let numeric): serializer.write(numeric)
        case .string(let string):
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

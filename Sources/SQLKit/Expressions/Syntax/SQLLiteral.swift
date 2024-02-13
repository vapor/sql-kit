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
        case .all:
            serializer.write("*")
            
        case .string(let string):
            #if DEBUG
            if let rawQuote = (serializer.dialect.literalStringQuote as? SQLRaw)?.sql {
                let containsQuote: Bool
                if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
                    containsQuote = string.contains(rawQuote)
                } else {
                    containsQuote = string.indices.first(where: {
                        string[$0..<(string.index($0, offsetBy: rawQuote.count + 1, limitedBy: string.endIndex) ?? string.endIndex)]
                            .prefix(rawQuote.count) == rawQuote
                    }) != nil
                }
                if containsQuote {
                    serializer.database.logger.debug("WARNING: Literal string used in SQL expression contains one or more literal string delimiters; this is extremely unsafe and can lead to trivial SQL injection.")
                }
            }
            #endif
        
            serializer.dialect.literalStringQuote.serialize(to: &serializer)
            serializer.write(string)
            serializer.dialect.literalStringQuote.serialize(to: &serializer)
        
        case .numeric(let numeric):
            serializer.write(numeric)
        
        case .null:
            serializer.write("NULL")
        
        case .default:
            serializer.dialect.literalDefault.serialize(to: &serializer)
        
        case .boolean(let bool):
            serializer.dialect.literalBoolean(bool).serialize(to: &serializer)
        }
    }
}

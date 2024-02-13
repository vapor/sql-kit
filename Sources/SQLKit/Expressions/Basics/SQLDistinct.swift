/// A thin wrapper around SQL's spottily-supported `DISTINCT ()` syntax.
///
/// This is a legacy expression of limited practical use. It is not yet deprecated, but its use is discouraged.
/// It is not clear what database actually supports this syntax. It is strongly suggested to use
/// `SQLFunction("DISTINCT", args: ...)` instead if a need for it does arise.
public struct SQLDistinct: SQLExpression {
    /// The identifiers to treat as a combined uniquing key.
    public let args: [any SQLExpression]
    
    /// Shorthand for `SQLDistinct(SQLLiteral.all)`.
    @inlinable
    public static var all: SQLDistinct {
        .init(SQLLiteral.all)
    }

    /// Create a `DISTINCT` expression with a list of string arguments.
    @inlinable
    public init(_ args: String...) {
        self.init(args.map(SQLIdentifier.init(_:)))
    }
    
    /// Create a `DISTINCT` expression with a list of expressions.
    @inlinable
    public init(_ args: any SQLExpression...) {
        self.init(args)
    }
    
    /// Create a `DISTINCT` expression with a list of expressions.
    @inlinable
    public init(_ args: [any SQLExpression]) {
        self.args = args
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        guard !self.args.isEmpty else { return }
        
        serializer.statement {
            $0.append("DISTINCT", SQLGroupExpression(self.args))
        }
    }
}

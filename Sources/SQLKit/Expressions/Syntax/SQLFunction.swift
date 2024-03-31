public struct SQLFunction: SQLExpression {
    public let name: String
    public let args: [any SQLExpression]
    
    @inlinable
    public init(_ name: String, args: String...) {
        self.init(name, args: args.map { SQLIdentifier($0) })
    }
    
    @inlinable
    public init(_ name: String, args: [String]) {
        self.init(name, args: args.map { SQLIdentifier($0) })
    }
    
    @inlinable
    public init(_ name: String, args: any SQLExpression...) {
        self.init(name, args: args)
    }
    
    @inlinable
    public init(_ name: String, args: [any SQLExpression] = []) {
        self.name = name
        self.args = args
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self.name)
        SQLGroupExpression(self.args).serialize(to: &serializer)
    }
}

extension SQLFunction {
    @inlinable
    public static func coalesce(_ expressions: [any SQLExpression]) -> SQLFunction {
        .init("COALESCE", args: expressions)
    }

    /// Convenience for creating a `COALESCE(foo)` function call (returns the first non-null expression).
    @inlinable
    public static func coalesce(_ exprs: any SQLExpression...) -> SQLFunction {
        self.coalesce(exprs)
    }
}

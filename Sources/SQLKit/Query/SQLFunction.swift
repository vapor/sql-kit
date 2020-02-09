public struct SQLFunction: SQLExpression {
    public let name: String
    public let args: [SQLExpression]
    
    
    public init(_ name: String, args: String...) {
        self.init(name, args: args.map { SQLIdentifier($0) })
    }
    
    public init(_ name: String, args: [String]) {
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
        SQLGroupExpression(self.args).serialize(to: &serializer)
    }
}

extension SQLFunction {
    public static func coalesce(_ expressions: [SQLExpression]) -> SQLFunction {
        return .init("COALESCE", args: expressions)
    }

    /// Convenience for creating a `COALESCE(foo)` function call (returns the first non-null expression).
    public static func coalesce(_ exprs: SQLExpression...) -> SQLFunction {
        return self.coalesce(exprs)
    }
}

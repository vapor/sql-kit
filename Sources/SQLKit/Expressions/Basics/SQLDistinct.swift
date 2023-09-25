public struct SQLDistinct: SQLExpression {
    public let args: [any SQLExpression]
    
    @inlinable
    public  init(_ args: String...) {
        self.init(args.map(SQLIdentifier.init(_:)))
    }
    
    @inlinable
    public init(_ args: any SQLExpression...) {
        self.init(args)
    }
    
    @inlinable
    public init(_ args: [any SQLExpression]) {
        self.args = args
    }

    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        guard !args.isEmpty else { return }
        serializer.write("DISTINCT")
        SQLGroupExpression(args).serialize(to: &serializer)
    }
}

extension SQLDistinct {
    @inlinable
    public static var all: SQLDistinct {
        .init(SQLLiteral.all)
    }
}

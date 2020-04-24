public struct SQLDistinct: SQLExpression {
    public let args: [SQLExpression]
    
    public  init(_ args: String...) {
        self.args = args.map(SQLIdentifier.init(_:))
    }
    
    public init(_ args: SQLExpression...) {
        self.args = args
    }
    
    public init(_ args: [SQLExpression]) {
        self.args = args
    }

    public func serialize(to serializer: inout SQLSerializer) {
        guard !args.isEmpty else { return }
        serializer.write("DISTINCT")
        SQLGroupExpression(args).serialize(to: &serializer)
    }
}

extension SQLDistinct {
    public static var all: SQLDistinct {
        .init(SQLLiteral.all)
    }
}

public struct SQLUnion: SQLExpression {
    public let args: [SQLExpression]

    public init(_ args: SQLExpression...) {
        self.init(args)
    }

    public init(_ args: [SQLExpression]) {
        self.args = args
    }

    public func serialize(to serializer: inout SQLSerializer) {
        let groups = args.map(SQLGroupExpression.init)
        guard let first = groups.first else { return }
        first.serialize(to: &serializer)
        for arg in groups.dropFirst() {
            serializer.write(" UNION ")
            arg.serialize(to: &serializer)
        }
    }
}


public struct SQLUnion: SQLExpression {
    public let args: [SQLExpression]
    public let all: Bool

    public init(_ args: SQLExpression..., all: Bool = false) {
        self.init(args, all: all)
    }

    public init(_ args: [SQLExpression], all: Bool = false) {
        precondition(!args.isEmpty, "Empty SQLUnions are not valid.") 
        self.args = args
        self.all = all
    }

    public func serialize(to serializer: inout SQLSerializer) {
        let groups = self.args.map(SQLGroupExpression.init)
        guard let first = groups.first else { return }
        first.serialize(to: &serializer)
        for arg in groups.dropFirst() {
            serializer.write(all ? " UNION ALL " : " UNION ")
            arg.serialize(to: &serializer)
        }
    }
}


public struct SQLUnion: SQLExpression {
    public let args: [SQLExpression]
    public let all: Bool

    public init(all: Bool = false, _ args: SQLExpression...) {
        self.init(all: all, args)
    }

    public init(all: Bool = false, _ args: [SQLExpression]) {
        self.all = all
        self.args = args
    }

    public func serialize(to serializer: inout SQLSerializer) {
        let groups = args.map(SQLGroupExpression.init)
        guard let first = groups.first else { return }
        first.serialize(to: &serializer)
        for arg in groups.dropFirst() {
            serializer.write(all ? " UNION ALL " : " UNION ")
            arg.serialize(to: &serializer)
        }
    }
}


public struct SQLUnion: SQLExpression {
    public let args: [SQLExpression]
    public let all: Bool

    public init(_ args: SQLExpression..., all: Bool = false) {
        self.init(args, all: all)
    }

    public init(_ args: [SQLExpression], all: Bool = false) {
        self.args = args
        self.all = all
    }

    public func serialize(to serializer: inout SQLSerializer) {
        let groups = args.map(SQLGroupExpression.init)
        guard let first = groups.first else { return }
        first.serialize(to: &serializer)
        for arg in groups.dropFirst() {
            if all {
                serializer.write(" UNION ALL ")
            } else {
                serializer.write(" UNION ")
            }
            arg.serialize(to: &serializer)
        }
    }
}


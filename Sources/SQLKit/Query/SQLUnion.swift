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
        self.args
            .map { [SQLGroupExpression($0)] }
            .joined([SQLUnionJoiner(all: self.all)])
            .forEach { $0.serialize(to: &serializer) }
    }
}

fileprivate struct SQLUnionJoiner: SQLExpression {
    let all: Bool
    
    func serialize(to serializer: inout SQLSerializer) {
        serializer.write("UNION\(self.all ? " ALL" : "") ")
    }
}


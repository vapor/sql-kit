public struct SQLQueryString {
    enum Fragment {
        case literal(String)
        case value(Encodable)
        case values([Encodable])
    }
    
    var fragments: [Fragment]
    
    public init<S: StringProtocol>(_ string: S) {
        fragments = [.literal(string.description)]
    }
}

extension SQLQueryString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        fragments = [.literal(value)]
    }
}

extension SQLQueryString: ExpressibleByStringInterpolation {
    
    public init(stringInterpolation: SQLQueryString) {
        fragments = stringInterpolation.fragments
    }
}

extension SQLQueryString: StringInterpolationProtocol {
    public init(literalCapacity: Int, interpolationCount: Int) {
        fragments = []
    }
    
    mutating public func appendLiteral(_ literal: String) {
        fragments.append(.literal(literal))
    }
    
    mutating public func appendInterpolation(_ literal: String) {
        fragments.append(.literal(literal))
    }

    mutating public func appendInterpolation(bind value: Encodable) {
        fragments.append(.value(value))
    }

    /// Binds multiple values in a comma separated list.
    /// Commonly used with the `IN` operator.
    mutating public func appendInterpolation(binds values: [Encodable]) {
        fragments.append(.values(values))
    }
}

extension SQLQueryString: SQLExpression {
    public func serialize(to serializer: inout SQLSerializer) {
        for fragment in fragments {
            switch fragment {
            case let .literal(str):
                serializer.write(str)
            case let .value(v):
                serializer.write(bind: v)
            case let .values(l):
                SQLList(l.map { SQLBind($0) }).serialize(to: &serializer)
            }
        }
    }
}

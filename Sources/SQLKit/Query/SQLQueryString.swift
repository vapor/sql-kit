public struct SQLQueryString {
    enum Fragment {
        case literal(String)
        case value(Encodable)
        case values([Encodable])
    }
    
    var fragments: [Fragment]
    
    init(fragments: [Fragment]) {
        self.fragments = fragments
    }
    
    public init<S: StringProtocol>(_ string: S) {
        self.init(fragments: [.literal(string.description)])
    }
}

extension SQLQueryString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(fragments: [.literal(value)])
    }
}

extension SQLQueryString: ExpressibleByStringInterpolation {
    
    public init(stringInterpolation: SQLQueryString) {
        self.init(fragments: stringInterpolation.fragments)
    }
}

extension SQLQueryString: StringInterpolationProtocol {
    public init(literalCapacity: Int, interpolationCount: Int) {
        self.init(fragments: [])
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
    
    mutating public func appendInterpolation(_ queryString: SQLQueryString) {
        fragments.append(contentsOf: queryString.fragments)
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

extension SQLQueryString {
    public static func +(lhs: SQLQueryString, rhs: SQLQueryString) -> SQLQueryString {
        self.init(fragments: lhs.fragments + rhs.fragments)
    }
}

extension Array where Element == SQLQueryString {
    public func joined(separator: String) -> SQLQueryString {
        guard var fragments = self.first?.fragments else {
            return ""
        }
        
        for element in self.dropFirst() {
            fragments.append(.literal(separator))
            fragments.append(contentsOf: element.fragments)
        }
        
        return SQLQueryString(fragments: fragments)
    }
}

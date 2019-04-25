public struct SQLQueryString {
    
    public enum Fragment {
        case literal(String)
        case value(Encodable)
    }
    
    var fragments: [Fragment]
}

extension SQLQueryString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        fragments = [.literal(value)]
    }
}

extension SQLQueryString: ExpressibleByStringInterpolation {
    public typealias StringInterpolation = SQLQueryString
    
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
}

extension SQLQueryString: SQLExpression {
    public func serialize(to serializer: inout SQLSerializer) {
        for fragment in fragments {
            switch fragment {
            case let .literal(str):
                serializer.write(str)
            case let .value(v):
                serializer.dialect.nextBindPlaceholder().serialize(to: &serializer)
                serializer.binds.append(v)
            }
        }
    }
}

extension Array: SQLExpression where Element == SQLQueryString.Fragment {
    public func serialize(to serializer: inout SQLSerializer) {
        for fragment in self {
            switch fragment {
            case let .literal(str):
                serializer.write(str)
            case let .value(v):
                serializer.dialect.nextBindPlaceholder().serialize(to: &serializer)
                serializer.binds.append(v)
            }
        }
    }
}

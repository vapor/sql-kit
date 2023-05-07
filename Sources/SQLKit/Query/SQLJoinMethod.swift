public enum SQLJoinMethod: SQLExpression {
    case inner
    case outer
    case left
    case right
    
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .inner: serializer.write("INNER")
        case .outer: serializer.write("OUTER")
        case .left: serializer.write("LEFT")
        case .right: serializer.write("RIGHT")
        }
    }
}

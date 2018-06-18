public protocol SQLJoinMethod: SQLSerializable {
    static var `default`: Self { get }
}

public enum GenericSQLJoinMethod: SQLJoinMethod {
    /// See `SQLJoinMethod`.
    public static var `default`: GenericSQLJoinMethod {
        return .inner
    }
    
    case inner
    case left
    case right
    case full
    
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case .inner: return "INNER"
        case .left: return "LEFT"
        case .right: return "RIGHT"
        case .full: return "FULL"
        }
    }
}

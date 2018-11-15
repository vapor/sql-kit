/// `JOIN` clause method, i.e., `INNER`, `LEFT`, etc.
public protocol SQLJoinMethod: SQLSerializable {
    /// Default join method, usually `INNER`.
    static var `default`: Self { get }
}

// MARK: Generic

/// Generic implementation of `SQLJoinMethod`.
public enum GenericSQLJoinMethod: SQLJoinMethod {
    /// See `SQLJoinMethod`.
    public static var `default`: GenericSQLJoinMethod {
        return .inner
    }
    
    /// See `SQLJoinMethod`.
    case inner
    
    /// See `SQLJoinMethod`.
    case left
    
    /// See `SQLJoinMethod`.
    case right
    
    /// See `SQLJoinMethod`.
    case full
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        switch self {
        case .inner: return "INNER"
        case .left: return "LEFT"
        case .right: return "RIGHT"
        case .full: return "FULL"
        }
    }
}

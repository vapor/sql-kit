/// `JOIN` clause method, i.e., `INNER`, `LEFT`, etc.
public protocol SQLJoinMethod: SQLSerializable {
    /// Default join method, usually `INNER`.
    static var `default`: Self { get }
}

/// Collects binds while serializing SQL queries.
public struct Binds {
    /// Collected binds.
    public var values: [Encodable]

    /// Creates a new `Binds`.
    public init() {
        self.values = []
    }
}

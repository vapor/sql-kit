/// A fundamental syntactical expression - an arbitrary string of raw SQL with no escaping or formating of any kind.
///
/// Users should almost never need to use ``SQLUnsafeRaw`` directly; there is almost always a better/safer/more specific
/// expression available for any given purpose. The most common use for ``SQLUnsafeRaw`` by end users is to represent SQL
/// keywords specific to a dialect, such as `SQLRaw("EXPLAIN VERBOSE")`.
///
/// In effect, ``SQLUnsafeRaw`` is nothing but a wrapper which makes `String`s into ``SQLExpression``s, since conforming
/// `String` directly to the protocol would cause numerous issues with SQLKit's existing public API (yet another design
/// flaw). In the past, ``SQLUnsafeRaw`` was intended to also contain bound values to be serialized with the text, but this
/// functionality was never implemented fully and is now entirely defunct.
///
/// > Note: Just to add further insult to injury, ``SQLUnsafeRaw`` is entirely redundant in the presence of
/// > ``SQLQueryString`` and ``SQLStatement``, but is used so pervasively that it cannot reasonably be deprecated.
public struct SQLUnsafeRaw: SQLExpression {
    /// The raw SQL text serialized by this expression.
    public var sql: String

    /// Legacy property specifying bound values. This property's value is **IGNORED**.
    ///
    /// The original intention was that bindings set in this property be serialized along with the SQL text, but this
    /// functionality was never properly implemented and was never used, and is deprecated. Use ``SQLBind`` and/or
    /// ``SQLQueryString`` to achieve the same effect.
    @available(*, deprecated, message: "Binds set in an `SQLRaw` are ignored. Use `SQLBind` instead.")
    public var binds: [any Encodable & Sendable] = []
    
    /// Create a new raw SQL text expression.
    ///
    /// - Parameter sql: The raw SQL text to serialize.
    @inlinable
    public init(_ sql: String) {
        self.sql = sql
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write(self.sql)
    }
}

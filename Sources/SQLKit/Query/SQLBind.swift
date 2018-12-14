/// A parameterizied value bound to the SQL query.
public protocol SQLBind: SQLSerializable {
    /// Creates a `SQLBind` from an `Encodable` value.
    static func encodable<E>(_ value: E) -> Self
        where E: Encodable
}

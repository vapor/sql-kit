/// SQL data type protocol, i.e., `INTEGER`, `TEXT`, etc.
public protocol SQLDataType: SQLSerializable {
    static var smallint: Self { get }
    static var int: Self { get }
    static var bigint: Self { get }
    static var text: Self { get }
    static var real: Self { get }
    static var blob: Self { get }
    static func custom(_ name: String) -> Self
}

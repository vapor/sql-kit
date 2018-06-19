public protocol SQLPrimaryKeyDefault: SQLSerializable {
    static var `default`: Self { get }
}

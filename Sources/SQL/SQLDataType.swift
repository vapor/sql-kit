public protocol SQLDataType: SQLSerializable {
    static func dataType(appropriateFor: Any.Type) -> Self?
}

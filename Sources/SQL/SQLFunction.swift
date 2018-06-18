public protocol SQLFunction: SQLSerializable {
    associatedtype Argument: SQLFunctionArgument
    static func function(_ name: String, _ args: [Argument]) -> Self
}

// MARK: Generic

public struct GenericSQLFunction<Argument>: SQLFunction where Argument: SQLFunctionArgument {
    /// See `SQLFunction`.
    public static func function(_ name: String, _ args: [Argument]) -> GenericSQLFunction<Argument> {
        return .init(name: name, arguments: args)
    }
    
    public var name: String
    public var arguments: [Argument]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return name + "(" + arguments.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
    }
}

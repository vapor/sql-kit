/// SQL function with zero or more arguments, i.e., `COUNT(*)`, `MAX(...)`, etc.
public protocol SQLFunction: SQLSerializable {
    /// See `SQLFunctionArgument`.
    associatedtype Argument: SQLFunctionArgument
    
    /// Creates a new `SQLFunction`.
    static func function(_ name: String, _ args: [Argument]) -> Self
}

// MARK: Generic

/// Generic implementation of `SQLFunction`.
public struct GenericSQLFunction<Argument>: SQLFunction where Argument: SQLFunctionArgument {
    /// See `SQLFunction`.
    public static func function(_ name: String, _ args: [Argument]) -> GenericSQLFunction<Argument> {
        return .init(name: name, arguments: args)
    }
    
    /// See `SQLFunction`.
    public var name: String
    
    /// See `SQLFunction`.
    public var arguments: [Argument]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        return name + "(" + arguments.map { $0.serialize(&binds) }.joined(separator: ", ") + ")"
    }
}

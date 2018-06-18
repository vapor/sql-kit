public protocol SQLColumnDefinition: SQLSerializable {
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    associatedtype DataType: SQLDataType
    associatedtype ColumnConstraint: SQLColumnConstraint
    static func columnDefinition(_ column: ColumnIdentifier, _ dataType: DataType, _ constraints: [ColumnConstraint]) -> Self
}

// MARK: Generic

public struct GenericSQLColumnDefinition<ColumnIdentifier, DataType, ColumnConstraint>: SQLColumnDefinition
    where ColumnIdentifier: SQLColumnIdentifier, DataType: SQLDataType, ColumnConstraint: SQLColumnConstraint
{
    public typealias `Self` = GenericSQLColumnDefinition<ColumnIdentifier, DataType, ColumnConstraint>
    
    /// See `SQLColumnDefinition`.
    public static func columnDefinition(_ column: ColumnIdentifier, _ dataType: DataType, _ constraints: [ColumnConstraint]) -> Self {
        return .init(column: column, dataType: dataType, constraints: constraints)
    }
    
    public var column: ColumnIdentifier
    public var dataType: DataType
    public var constraints: [ColumnConstraint]
    
    /// See `SQLSerializable`.
    public func serialize(_ binds: inout [Encodable]) -> String {
        var sql: [String] = []
        sql.append(column.identifier.serialize(&binds))
        sql.append(dataType.serialize(&binds))
        sql.append(constraints.serialize(&binds, joinedBy: " "))
        return sql.joined(separator: " ")
    }
}

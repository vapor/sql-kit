/// Table column definition. DDL. Used by `SQLCreateTable` and `SQLAlterTable`.
///
/// See `SQLCreateTableBuilder` and `SQLAlterTableBuilder`.
public protocol SQLColumnDefinition: SQLSerializable {
    /// See `SQLColumnIdentifier`.
    associatedtype ColumnIdentifier: SQLColumnIdentifier
    
    /// See `SQLDataType`.
    associatedtype DataType: SQLDataType
    
    /// See `SQLColumnConstraint`.
    associatedtype ColumnConstraint: SQLColumnConstraint
    
    /// Creates a new `SQLColumnDefinition` from column identifier, data type, and zero or more constraints.
    static func columnDefinition(_ column: ColumnIdentifier, _ dataType: DataType, _ constraints: [ColumnConstraint]) -> Self
}

// MARK: Generic

/// Generic implementation of `SQLColumnDefinition`.
public struct GenericSQLColumnDefinition<ColumnIdentifier, DataType, ColumnConstraint>: SQLColumnDefinition
    where ColumnIdentifier: SQLColumnIdentifier, DataType: SQLDataType, ColumnConstraint: SQLColumnConstraint
{
    /// Convenience alias for self.
    public typealias `Self` = GenericSQLColumnDefinition<ColumnIdentifier, DataType, ColumnConstraint>
    
    /// See `SQLColumnDefinition`.
    public static func columnDefinition(_ column: ColumnIdentifier, _ dataType: DataType, _ constraints: [ColumnConstraint]) -> Self {
        return .init(column: column, dataType: dataType, constraints: constraints)
    }
    
    /// See `SQLColumnDefinition`.
    public var column: ColumnIdentifier
    
    /// See `SQLColumnDefinition`.
    public var dataType: DataType
    
    /// See `SQLColumnDefinition`.
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

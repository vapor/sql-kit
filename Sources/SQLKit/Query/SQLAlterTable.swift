/// `ALTER TABLE` query.
///
///     conn.alter(table: Planet.self)
///         .column(for: \.name)
///         .run()
///
/// See `SQLAlterTableBuilder` for more information.
public struct SQLAlterTable: SQLExpression {
    public var name: SQLExpression
    /// Columns to add.
    public var addColumns: [SQLExpression]
    /// Columns to add.
    public var modifyColumns: [SQLExpression]

    public var dropColumns: [SQLExpression]
    
    /// Creates a new `SQLAlterTable`. See `SQLAlterTableBuilder`.
    public init(name: SQLExpression) {
        self.name = name
        self.addColumns = []
        self.modifyColumns = []
        self.dropColumns = []
    }
    
    public func serialize(to serializer: inout SQLSerializer) {
        let dialect = serializer.dialect
        serializer.statement {
            $0.append("ALTER TABLE")
            $0.append(self.name)
            for column in self.addColumns {
                $0.append("ADD")
                $0.append(column)
            }
            for column in self.modifyColumns{
                if dialect.name == "mysql" {
                    $0.append("MODIFY")
                } else {
                    $0.append("ALTER COLUMN")
                }
                $0.append(column)
            }
            for column in self.dropColumns {
                $0.append("DROP")
                $0.append(column)
            }
        }
    }
}


/// Table column definition. DDL. Used by `SQLCreateTable` and `SQLAlterTable`.
///
/// See `SQLCreateTableBuilder` and `SQLAlterTableBuilder`.
public struct SQLModifyColumn: SQLExpression {
    public var column: SQLExpression

    public var dataType: SQLExpression?

    public var constraints: [SQLExpression]

    /// Creates a new `SQLColumnDefinition` from column identifier, data type, and zero or more constraints.
    public init(column: SQLExpression, dataType: SQLExpression, constraints: [SQLExpression] = []) {
        self.column = column
        self.dataType = dataType
        self.constraints = constraints
    }

    public func serialize(to serializer: inout SQLSerializer) {
        let dialect = serializer.dialect
        serializer.statement {
            $0.append(self.column)
            if let dataType = self.dataType {
                if dialect.name == "postgresql" {
                    $0.append("TYPE")
                }
                $0.append(dataType)
            }
            for constraint in self.constraints {
                $0.append(constraint)
            }
        }
    }
}

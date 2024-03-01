/// Table-level data constraints.
///
/// Most dialects of SQL support both column-level (specific to a single column) and table-level (applicable to a list
/// of one or more columns within the table) constraints. While some constraints can be expressed either way, others
/// are only allowed at the column level. See ``SQLColumnConstraintAlgorithm`` for column-level constraints.
///
/// Most table-level constraints can optionally be explicitly named; see ``SQLConstraint`` for this functionality.
///
/// Table constraints are used by ``SQLCreateTable`` and ``SQLAlterTable``, and also appear directly in the APIs of
/// ``SQLAlterTableBuilder``, ``SQLCreateIndexBuilder``, and ``SQLCreateTableBuilder``.
public enum SQLTableConstraintAlgorithm: SQLExpression {
    /// A `PRIMARY KEY` constraint over one or more columns.
    ///
    /// Table-level primary key constraints are not associated with auto-increment functionality, and in most dialects,
    /// a primary key constraint either has no name at all or always has the same name.
    ///
    /// See also ``SQLColumnConstraintAlgorithm/primaryKey(autoIncrement:)``.
    case primaryKey(columns: [any SQLExpression])

    /// A `UNIQUE` value constraint, also called a unique key, over one or more columns.
    ///
    /// In most SQL dialects, a `UNIQUE` constraint also implies the presence of an index over the constrained
    /// column(s), such that uniqueness is treated as a boolean attribute of such an index.
    ///
    /// See also ``SQLColumnConstraintAlgorithm/unique``.
    case unique(columns: [any SQLExpression])

    /// A `CHECK` constraint and its associated validation expression.
    ///
    /// See also ``SQLColumnConstraintAlgorithm/check(_:)``.
    case check(any SQLExpression)

    /// A `FOREIGN KEY` constraint over one or more columns, specifying the referenced data.
    ///
    /// The `references` expression is usually an instance of ``SQLForeignKey``, and must specify the same number of
    /// columns as are present in the `columns` array of the constraint.
    ///
    /// See also ``SQLColumnConstraintAlgorithm/foreignKey(references:)``.
    case foreignKey(columns: [any SQLExpression], references: any SQLExpression)

    // See `SQLExpression.serialize(to:)`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.statement {
            switch self {
            case .primaryKey(columns: let columns):
                $0.append("PRIMARY KEY", SQLGroupExpression(columns))
            case .unique(columns: let columns):
                $0.append("UNIQUE", SQLGroupExpression(columns))
            case .check(let expression):
                $0.append("CHECK", SQLGroupExpression(expression))
            case .foreignKey(columns: let columns, let foreignKey):
                $0.append("FOREIGN KEY", SQLGroupExpression(columns), foreignKey)
            }
        }
    }
}

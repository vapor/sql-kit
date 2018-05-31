extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(ddl: DDL) -> String {
        var statement: [String] = []
        let table = makeEscapedString(from: ddl.table)

        switch ddl.statement.verb {
        case "CREATE":
            statement.append("CREATE TABLE")
            statement.append(table)

            let columns = ddl.createColumns.map { serialize(column: $0) }
                + ddl.createConstraints.map { serialize(constraint: $0) }
            statement.append("(" + columns.joined(separator: ", ") + ")")
        case "ALTER":
            statement.append("ALTER TABLE")
            statement.append(table)

            if !ddl.createColumns.isEmpty {
                statement.append(ddl.createColumns.map { "ADD " + serialize(column: $0) }.joined(separator: ", "))
            }
            if !ddl.deleteColumns.isEmpty {
                statement.append(ddl.deleteColumns.map { "DROP " + serialize(column: $0) }.joined(separator: ", "))
            }

            if !ddl.createConstraints.isEmpty {
                statement.append(ddl.deleteConstraints.map { "ADD " + serialize(constraint: $0) }.joined(separator: ", "))
            }
            if !ddl.deleteConstraints.isEmpty {
                statement.append(ddl.deleteConstraints.map { "DROP CONSTRAINT " + makeName(for: $0) }.joined(separator: ", "))
            }
        case "DROP":
            statement.append("DROP TABLE")
            statement.append(table)
        case "TRUNCATE":
            statement.append("TRUNCATE")
            statement.append(table)
        default: break
        }

        return statement.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(column: DDL.ColumnDefinition) -> String {
        var sql: [String] = []

        let name = makeEscapedString(from: column.name)
        sql.append(name)
        sql.append(column.dataType.name)
        if !column.dataType.parameters.isEmpty {
            sql.append("(" + column.dataType.parameters.joined(separator: ",") + ")")
        }
        sql += column.dataType.attributes
        return sql.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(constraint: DDL.Constraint) -> String {
        var sql: [String] = []

        // CONSTRAINT galleries_gallery_tmpltid_fk
        sql.append("CONSTRAINT")
        sql.append(makeEscapedString(from: makeName(for: constraint)))

        switch constraint.storage {
        case .foreignKey(let foreignKey):
            sql.append(serialize(foreignKey: foreignKey))
        case .unique(let unique):
            sql.append(serialize(unique: unique))
        }

        return sql.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(unique: DDL.Constraint.Unique) -> String {
        // UNIQUE (ID,LastName);
        var sql: [String] = []
        sql.append("UNIQUE")
        sql.append("(" + unique.columns.map { makeEscapedString(from: $0.name) }.joined(separator: ", ") + ")")
        return sql.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(foreignKey: DDL.Constraint.ForeignKey) -> String {
        // FOREIGN KEY(trackartist) REFERENCES artist(artistid)
        var sql: [String] = []
        sql.append("FOREIGN KEY")
        if let table = foreignKey.local.table {
            sql.append(makeEscapedString(from: table))
        }
        sql.append("(" + makeEscapedString(from: foreignKey.local.name) + ")")
        sql.append("REFERENCES")
        if let table = foreignKey.foreign.table {
            sql.append(makeEscapedString(from: table))
        }
        sql.append("(" + makeEscapedString(from: foreignKey.foreign.name) + ")")
        if let onUpdate = foreignKey.onUpdate {
            sql.append("ON UPDATE")
            sql.append(serialize(foreignKeyAction: onUpdate))
        }
        if let onDelete = foreignKey.onDelete {
            sql.append("ON DELETE")
            sql.append(serialize(foreignKeyAction: onDelete))
        }
        return sql.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func makeName(for constraint: DDL.Constraint) -> String {
        switch constraint.storage {
        case .foreignKey(let foreignKey):
            let local: String = (foreignKey.local.table.flatMap { $0 + "." } ?? "") + foreignKey.local.name
            let foreign: String = (foreignKey.foreign.table.flatMap { $0 + "." } ?? "") + foreignKey.foreign.name
            return "fk:" + local + "+" + foreign
        case .unique(let unique):
            return "uq:" + unique.columns.map { $0.table.flatMap { $0 + "." } ?? "" + $0.name }.joined(separator: "+")
        }
    }

    /// See `SQLSerializer`.
    public func serialize(foreignKeyAction: DDL.Constraint.ForeignKey.Action) -> String {
        switch foreignKeyAction {
        case .noAction: return "NO ACTION"
        case .restrict: return "RESTRICT"
        case .setNull: return "SET NULL"
        case .setDefault: return "SET DEFAULT"
        case .cascade: return "CASCADE"
        }
    }
}

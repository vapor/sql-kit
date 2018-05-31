extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(ddl: Query<Database>.DDL) -> String {
        var statement: [String] = []
        let table = makeEscapedString(from: ddl.table)
        statement.append(ddl.statement.verb)
        statement.append("TABLE")
        statement += ddl.statement.modifiers
        statement.append(table)

        switch ddl.statement.verb {
        case "CREATE":
            let columns = ddl.createColumns.map { serialize(column: $0) }
                + ddl.createConstraints.map { serialize(constraint: $0) }
            statement.append("(" + columns.joined(separator: ", ") + ")")
        case "ALTER":
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
        default: break
        }

        return statement.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(column: Query<Database>.DDL.ColumnDefinition) -> String {
        var sql: [String] = []

        let name = makeEscapedString(from: column.name)
        sql.append(name)
        sql.append(serialize(columnType: column.columnType))
        return sql.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(constraint: Query<Database>.DDL.Constraint) -> String {
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
    public func serialize(unique: Query<Database>.DDL.Constraint.Unique) -> String {
        // UNIQUE (ID,LastName);
        var sql: [String] = []
        sql.append("UNIQUE")
        sql.append("(" + unique.columns.map { makeEscapedString(from: $0.name) }.joined(separator: ", ") + ")")
        return sql.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(foreignKey: Query<Database>.DDL.Constraint.ForeignKey) -> String {
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
    public func makeName(for constraint: Query<Database>.DDL.Constraint) -> String {
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
    public func serialize(foreignKeyAction: Query<Database>.DDL.Constraint.ForeignKey.Action) -> String {
        switch foreignKeyAction {
        case .noAction: return "NO ACTION"
        case .restrict: return "RESTRICT"
        case .setNull: return "SET NULL"
        case .setDefault: return "SET DEFAULT"
        case .cascade: return "CASCADE"
        }
    }
}

extension SQLSerializer {
    /// See `SQLSerializer`.
    public func serialize(query: DataDefinitionQuery) -> String {
        var statement: [String] = []
        let table = makeEscapedString(from: query.table)

        switch query.statement {
        case .create:
            statement.append("CREATE TABLE")
            statement.append(table)

            let columns = query.createColumns.map { serialize(column: $0) }
                + query.createConstraints.map { serialize(constraint: $0) }
            statement.append("(" + columns.joined(separator: ", ") + ")")
        case .alter:
            statement.append("ALTER TABLE")
            statement.append(table)

            if !query.createColumns.isEmpty {
                statement.append(query.createColumns.map { "ADD " + serialize(column: $0) }.joined(separator: ", "))
            }
            if !query.deleteColumns.isEmpty {
                statement.append(query.deleteColumns.map { "DROP " + serialize(column: $0) }.joined(separator: ", "))
            }

            if !query.createConstraints.isEmpty {
                statement.append(query.deleteConstraints.map { "ADD " + serialize(constraint: $0) }.joined(separator: ", "))
            }
            if !query.deleteConstraints.isEmpty {
                statement.append(query.deleteConstraints.map { "DROP CONSTRAINT " + makeName(for: $0) }.joined(separator: ", "))
            }
        case .drop:
            statement.append("DROP TABLE")
            statement.append(table)
        case .truncate:
            statement.append("TRUNCATE")
            statement.append(table)
        }

        return statement.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(column: DataDefinitionColumn) -> String {
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
    public func serialize(constraint: DataDefinitionConstraint) -> String {
        var sql: [String] = []

        // CONSTRAINT galleries_gallery_tmpltid_fk
        sql.append("CONSTRAINT")
        sql.append(makeEscapedString(from: makeName(for: constraint)))

        switch constraint {
        case .foreignKey(let foreignKey):
            sql.append(serialize(foreignKey: foreignKey))
        case .unique(let unique):
            sql.append(serialize(unique: unique))
        }

        return sql.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(unique: DataDefinitionUnique) -> String {
        // UNIQUE (ID,LastName);
        var sql: [String] = []
        sql.append("UNIQUE")
        sql.append(unique.columns.map { serialize(column: $0) }.joined(separator: ", "))
        return sql.joined(separator: " ")
    }

    /// See `SQLSerializer`.
    public func serialize(foreignKey: DataDefinitionForeignKey) -> String {
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
    public func makeName(for constraint: DataDefinitionConstraint) -> String {
        switch constraint {
        case .foreignKey(let foreignKey):
            return "fk:\(foreignKey.local.table ?? "").\(foreignKey.local.name)_\(foreignKey.foreign.table ?? "").\(foreignKey.foreign.name)"
        case .unique(let unique):
            return "uq:" + unique.columns.map { "\($0.table ?? "").\($0.name)" }.joined(separator: "_")
        }
    }

    /// See `SQLSerializer`.
    public func serialize(foreignKeyAction: DataDefinitionForeignKeyAction) -> String {
        switch foreignKeyAction {
        case .noAction: return "NO ACTION"
        case .restrict: return "RESTRICT"
        case .setNull: return "SET NULL"
        case .setDefault: return "SET DEFAULT"
        case .cascade: return "CASCADE"
        }
    }
}

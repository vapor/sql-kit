/// Capable of serializing SQL queries into strings.
/// This protocol has free implementations for most of the requirements
/// and tries to conform to general (flavor-agnostic) SQL.
///
/// You are expected to implement only the methods that require
/// different serialization logic for your given SQL flavor.
public protocol SQLSerializer {
    // MARK: All
    
    /// Serializes both `DML` and `DDL`.
    func serialize(query: SQLQuery, binds: inout Binds) -> String
    
    // MARK: DML

    /// Serializes a SQL `DML` to a string.
    ///
    ///     INSERT INTO `users` (`name`) VALUES (?)
    ///
    /// And read statements.
    ///
    ///     SELECT `users`.* FROM `users`
    ///
    /// - note: Avoid overriding this method if possible
    ///         as it is complex. Much of what this method
    ///         serializes can be modified by overriding other methods.
    func serialize(dml: SQLQuery.DML, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationKey` to a string.
    ///
    ///     `foo`.`id` as `fooid`
    ///
    func serialize(key: SQLQuery.DML.Key) -> String

    /// Serializes a SQL `DataManipulationColumn` to a string.
    ///
    ///     `foo`.`id` = ?
    ///
    func serialize(column: SQLQuery.DML.Column, value: SQLQuery.DML.Value, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationValue` to a string.
    ///
    ///     ?
    ///
    func serialize(value: SQLQuery.DML.Value, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationColumn` to a string.
    ///
    ///     `foo`.`id`
    ///
    func serialize(column: SQLQuery.DML.Column) -> String

    /// Serializes a SQL `DataComputedColumn` to a string.
    ///
    ///     average(`users`.`age`) as `averageAge`
    ///
    func serialize(column: SQLQuery.DML.ComputedColumn) -> String

    /// Serializes multiple SQL `DataManipulationJoin`s to a string.
    ///
    ///     JOIN `bar` ON `foo`.`bar_id` = `bar`.`id`
    ///
    func serialize(joins: [SQLQuery.DML.Join]) -> String

    /// Serializes a single SQL `DataManipulationJoin` to a string.
    ///
    ///     JOIN `bar` ON `foo`.`bar_id` = `bar`.`id`
    ///
    func serialize(join: SQLQuery.DML.Join) -> String

    /// Serializes multiple SQL `DataManipulationOrderBy`s to a string.
    ///
    ///     ORDER BY `users`.`age` DESC, `foo`.`bar` ASC
    ///
    func serialize(orderBys: [SQLQuery.DML.OrderBy]) -> String

    /// Serializes a single SQL `DataManipulationOrderBy` to a string.
    ///
    ///     `users`.`age` DESC
    ///
    func serialize(orderBy: SQLQuery.DML.OrderBy) -> String
    
    /// Serializes multiple SQL `DataManipulationGroupBy`s to a string.
    ///
    ///     GROUP BY YEAR(`users`.`born`), `users`.`sex`
    ///
    func serialize(groupBys: [SQLQuery.DML.GroupBy]) -> String

    /// Serializes a SQL `OrderByDirection` to a string.
    ///
    ///     DESC
    ///
    func serialize(orderByDirection: SQLQuery.DML.OrderBy.Direction) -> String

    /// Serializes a SQL `DataPredicate` to a string.
    ///
    ///     `user`.`id` = ?
    ///
    func serialize(predicate: SQLQuery.DML.Predicate, binds: inout Binds) -> String

    /// Serializes a SQL `DataPredicateGroupRelation` to a string.
    ///
    ///     AND
    ///
    func serialize(predicate: SQLQuery.DML.Predicate.Relation) -> String

    /// Serializes a SQL `DataPredicateComparison` to a string.
    ///
    ///     =
    ///
    func serialize(comparison: SQLQuery.DML.Predicate.Comparison) -> String


    // MARK: DDL

    /// Serializes a SQL `DataDefinitionQuery` to a string.
    ///
    ///     CREATE TABLE `foo` (`id` INT PRIMARY KEY)
    ///
    func serialize(ddl: SQLQuery.DDL) -> String

    /// Serializes a SQL `DataDefinitionColumn` to a string.
    ///
    ///     `id` INT PRIMARY KEY
    ///
    func serialize(column: SQLQuery.DDL.ColumnDefinition) -> String
    
    /// Serializes a SQL `Database.ColumnType` to a string.
    ///
    ///     INT PRIMARY KEY
    ///
    func serialize(columnType: SQLQuery.DDL.ColumnDefinition.ColumnType) -> String

    /// Serializes a SQL `DataDefinitionConstraint` to a string.
    ///
    ///     CONSTRAINT UC_Person UNIQUE (ID,LastName)
    ///
    func serialize(constraint: SQLQuery.DDL.Constraint) -> String

    /// Serializes a SQL `DataDefinitionUnique` to a string.
    ///
    ///     CONSTRAINT UC_Person UNIQUE (ID,LastName)
    ///
    func serialize(unique: SQLQuery.DDL.Constraint.Unique) -> String

    /// Serializes a SQL `DataDefinitionColumn` to a string.
    ///
    ///     FOREIGN KEY (`trackartist`) REFERENCES `artist`(`artistid`) ON UPDATE RESTRICT ON DELETE RESTRICT
    ///
    func serialize(foreignKey: SQLQuery.DDL.Constraint.ForeignKey) -> String

    /// Serializes a SQL `DataDefinitionForeignKeyAction` to a string.
    ///
    ///     ON UPDATE RESTRICT ON DELETE RESTRICT
    ///
    func serialize(foreignKeyAction: SQLQuery.DDL.Constraint.ForeignKey.Action) -> String


    // MARK: Utility

    /// Creates a placeholder.
    ///
    ///     ?
    ///
    func makePlaceholder() -> String

    /// Escapes the supplied string.
    ///
    /// Important: This is not guaranteed to be injection safe and
    /// should _not_ be relied upon to prevent injection.
    ///
    /// This method should be used for ensuring table, column,
    /// and key names are not mistaken for SQL syntax.
    ///
    ///     `foo`
    ///
    func makeEscapedString(from string: String) -> String

    /// Creates a name for the supplied constraint.
    ///
    ///     persons_fk
    ///
    func makeName(for constraint: SQLQuery.DDL.Constraint) -> String
}

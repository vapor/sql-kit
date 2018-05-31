/// Capable of serializing SQL queries into strings.
/// This protocol has free implementations for most of the requirements
/// and tries to conform to general (flavor-agnostic) SQL.
///
/// You are expected to implement only the methods that require
/// different serialization logic for your given SQL flavor.
public protocol SQLSerializer {
    associatedtype Database: SQLSupporting
    
    // MARK: All
    
    /// Serializes both `DataManipulationQuery` and `DataDefinitionQuery`.
    func serialize(query: Query<Database>, binds: inout Binds) -> String
    
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
    func serialize(dml: Query<Database>.DML, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationKey` to a string.
    ///
    ///     `foo`.`id` as `fooid`
    ///
    func serialize(key: Query<Database>.DML.Key) -> String

    /// Serializes a SQL `DataManipulationColumn` to a string.
    ///
    ///     `foo`.`id` = ?
    ///
    func serialize(column: Query<Database>.DML.Column, value: Query<Database>.DML.Value, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationValue` to a string.
    ///
    ///     ?
    ///
    func serialize(value: Query<Database>.DML.Value, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationColumn` to a string.
    ///
    ///     `foo`.`id`
    ///
    func serialize(column: Query<Database>.DML.Column) -> String

    /// Serializes a SQL `DataComputedColumn` to a string.
    ///
    ///     average(`users`.`age`) as `averageAge`
    ///
    func serialize(column: Query<Database>.DML.ComputedColumn) -> String

    /// Serializes multiple SQL `DataManipulationJoin`s to a string.
    ///
    ///     JOIN `bar` ON `foo`.`bar_id` = `bar`.`id`
    ///
    func serialize(joins: [Query<Database>.DML.Join]) -> String

    /// Serializes a single SQL `DataManipulationJoin` to a string.
    ///
    ///     JOIN `bar` ON `foo`.`bar_id` = `bar`.`id`
    ///
    func serialize(join: Query<Database>.DML.Join) -> String

    /// Serializes multiple SQL `DataManipulationOrderBy`s to a string.
    ///
    ///     ORDER BY `users`.`age` DESC, `foo`.`bar` ASC
    ///
    func serialize(orderBys: [Query<Database>.DML.OrderBy]) -> String

    /// Serializes a single SQL `DataManipulationOrderBy` to a string.
    ///
    ///     `users`.`age` DESC
    ///
    func serialize(orderBy: Query<Database>.DML.OrderBy) -> String
    
    /// Serializes multiple SQL `DataManipulationGroupBy`s to a string.
    ///
    ///     GROUP BY YEAR(`users`.`born`), `users`.`sex`
    ///
    func serialize(groupBys: [Query<Database>.DML.GroupBy]) -> String

    /// Serializes a SQL `OrderByDirection` to a string.
    ///
    ///     DESC
    ///
    func serialize(orderByDirection: Query<Database>.DML.OrderBy.Direction) -> String

    /// Serializes a SQL `DataPredicate` to a string.
    ///
    ///     `user`.`id` = ?
    ///
    func serialize(predicate: Query<Database>.DML.Predicate, binds: inout Binds) -> String

    /// Serializes a SQL `DataPredicateGroupRelation` to a string.
    ///
    ///     AND
    ///
    func serialize(predicate: Query<Database>.DML.Predicate.Relation) -> String

    /// Serializes a SQL `DataPredicateComparison` to a string.
    ///
    ///     =
    ///
    func serialize(comparison: Query<Database>.DML.Predicate.Comparison) -> String


    // MARK: DDL

    /// Serializes a SQL `DataDefinitionQuery` to a string.
    ///
    ///     CREATE TABLE `foo` (`id` INT PRIMARY KEY)
    ///
    func serialize(ddl: Query<Database>.DDL) -> String

    /// Serializes a SQL `DataDefinitionColumn` to a string.
    ///
    ///     `id` INT PRIMARY KEY
    ///
    func serialize(column: Query<Database>.DDL.ColumnDefinition) -> String
    
    /// Serializes a SQL `Database.ColumnType` to a string.
    ///
    ///     INT PRIMARY KEY
    ///
    func serialize(columnType: Database.ColumnType) -> String

    /// Serializes a SQL `DataDefinitionConstraint` to a string.
    ///
    ///     CONSTRAINT UC_Person UNIQUE (ID,LastName)
    ///
    func serialize(constraint: Query<Database>.DDL.Constraint) -> String

    /// Serializes a SQL `DataDefinitionUnique` to a string.
    ///
    ///     CONSTRAINT UC_Person UNIQUE (ID,LastName)
    ///
    func serialize(unique: Query<Database>.DDL.Constraint.Unique) -> String

    /// Serializes a SQL `DataDefinitionColumn` to a string.
    ///
    ///     FOREIGN KEY (`trackartist`) REFERENCES `artist`(`artistid`) ON UPDATE RESTRICT ON DELETE RESTRICT
    ///
    func serialize(foreignKey: Query<Database>.DDL.Constraint.ForeignKey) -> String

    /// Serializes a SQL `DataDefinitionForeignKeyAction` to a string.
    ///
    ///     ON UPDATE RESTRICT ON DELETE RESTRICT
    ///
    func serialize(foreignKeyAction: Query<Database>.DDL.Constraint.ForeignKey.Action) -> String


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
    func makeName(for constraint: Query<Database>.DDL.Constraint) -> String
}

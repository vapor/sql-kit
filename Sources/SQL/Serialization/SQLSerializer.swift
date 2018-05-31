/// Capable of serializing SQL queries into strings.
/// This protocol has free implementations for most of the requirements
/// and tries to conform to general (flavor-agnostic) SQL.
///
/// You are expected to implement only the methods that require
/// different serialization logic for your given SQL flavor.
public protocol SQLSerializer {
    // MARK: All
    
    /// Serializes both `DataManipulationQuery` and `DataDefinitionQuery`.
    func serialize(query: DataQuery, binds: inout Binds) -> String
    
    // MARK: Data Manipulation

    /// Serializes a SQL `DataManipulationQuery` to a string.
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
    func serialize(query: DataManipulationQuery, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationKey` to a string.
    ///
    ///     `foo`.`id` as `fooid`
    ///
    func serialize(key: DataManipulationQuery.Key) -> String

    /// Serializes a SQL `DataManipulationColumn` to a string.
    ///
    ///     `foo`.`id` = ?
    ///
    func serialize(column: DataManipulationQuery.Column, value: DataManipulationQuery.Value, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationValue` to a string.
    ///
    ///     ?
    ///
    func serialize(value: DataManipulationQuery.Value, binds: inout Binds) -> String

    /// Serializes a SQL `DataManipulationColumn` to a string.
    ///
    ///     `foo`.`id`
    ///
    func serialize(column: DataManipulationQuery.Column) -> String

    /// Serializes a SQL `DataComputedColumn` to a string.
    ///
    ///     average(`users`.`age`) as `averageAge`
    ///
    func serialize(column: DataManipulationQuery.ComputedColumn) -> String

    /// Serializes multiple SQL `DataManipulationJoin`s to a string.
    ///
    ///     JOIN `bar` ON `foo`.`bar_id` = `bar`.`id`
    ///
    func serialize(joins: [DataManipulationQuery.Join]) -> String

    /// Serializes a single SQL `DataManipulationJoin` to a string.
    ///
    ///     JOIN `bar` ON `foo`.`bar_id` = `bar`.`id`
    ///
    func serialize(join: DataManipulationQuery.Join) -> String

    /// Serializes multiple SQL `DataManipulationOrderBy`s to a string.
    ///
    ///     ORDER BY `users`.`age` DESC, `foo`.`bar` ASC
    ///
    func serialize(orderBys: [DataManipulationQuery.OrderBy]) -> String

    /// Serializes a single SQL `DataManipulationOrderBy` to a string.
    ///
    ///     `users`.`age` DESC
    ///
    func serialize(orderBy: DataManipulationQuery.OrderBy) -> String
    
    /// Serializes multiple SQL `DataManipulationGroupBy`s to a string.
    ///
    ///     GROUP BY YEAR(`users`.`born`), `users`.`sex`
    ///
    func serialize(groupBys: [DataManipulationQuery.GroupBy]) -> String

    /// Serializes a SQL `OrderByDirection` to a string.
    ///
    ///     DESC
    ///
    func serialize(orderByDirection: DataManipulationQuery.OrderBy.Direction) -> String

    /// Serializes a SQL `DataPredicates` to a string.
    ///
    ///     `user`.`id` = ?
    ///
    func serialize(predicates: DataManipulationQuery.Predicates, binds: inout Binds) -> String

    /// Serializes a SQL `DataPredicate` to a string.
    ///
    ///     `user`.`id` = ?
    ///
    func serialize(predicate: DataManipulationQuery.Predicate, binds: inout Binds) -> String

    /// Serializes a SQL `DataPredicateGroupRelation` to a string.
    ///
    ///     AND
    ///
    func serialize(predicate: DataManipulationQuery.Predicates.Relation) -> String

    /// Serializes a SQL `DataPredicateComparison` to a string.
    ///
    ///     =
    ///
    func serialize(comparison: DataManipulationQuery.Predicate.Comparison) -> String


    // MARK: Data Definition

    /// Serializes a SQL `DataDefinitionQuery` to a string.
    ///
    ///     CREATE TABLE `foo` (`id` INT PRIMARY KEY)
    ///
    func serialize(query: DataDefinitionQuery) -> String

    /// Serializes a SQL `DataDefinitionColumn` to a string.
    ///
    ///     `id` INT PRIMARY KEY
    ///
    func serialize(column: DataDefinitionColumn) -> String

    /// Serializes a SQL `DataDefinitionConstraint` to a string.
    ///
    ///     CONSTRAINT UC_Person UNIQUE (ID,LastName)
    ///
    func serialize(constraint: DataDefinitionConstraint) -> String

    /// Serializes a SQL `DataDefinitionUnique` to a string.
    ///
    ///     CONSTRAINT UC_Person UNIQUE (ID,LastName)
    ///
    func serialize(unique: DataDefinitionUnique) -> String

    /// Serializes a SQL `DataDefinitionColumn` to a string.
    ///
    ///     FOREIGN KEY (`trackartist`) REFERENCES `artist`(`artistid`) ON UPDATE RESTRICT ON DELETE RESTRICT
    ///
    func serialize(foreignKey: DataDefinitionForeignKey) -> String

    /// Serializes a SQL `DataDefinitionForeignKeyAction` to a string.
    ///
    ///     ON UPDATE RESTRICT ON DELETE RESTRICT
    ///
    func serialize(foreignKeyAction: DataDefinitionForeignKeyAction) -> String


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
    func makeName(for constraint: DataDefinitionConstraint) -> String
}

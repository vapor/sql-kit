/// An abstract definition of a specific dialect of SQL. SQLKit uses an ``SQLDatabase``'s
/// dialect to control various aspects of query serialization, with the intent of keeping
/// SQLKit's user-facing API from having to expose database-specific details as much as
/// possible. While SQL dialects in the wild vary too widely in practice for this to ever
/// be 100% effective, they also have enough in common to avoid having to rewrite the
/// entire serialization logic for each database driver.
public protocol SQLDialect {
    /// The name of the dialect.
    ///
    /// Dialect names were intended to just be human-readable strings, but in reality there
    /// are several code paths which rely on checking for specific dialect names. As a result,
    /// dialect names are implicitly required to be globally unique (though there's no way
    /// to enforce this). SQLKit currenly recommends dialect names match a regular expression
    /// of the form `/^[a-z][a-z0-9-]*$/` (starts with a lowercase ASCII letter, remainder
    /// consists of only lowercase ASCII letters, ASCII digits, and/or dashes).
    ///
    /// No default is provided.
    var name: String { get }
    
    /// An expression (usually an `SQLRaw`) giving the character(s) used to quote SQL
    /// identifiers, such as table and column names. The identifier quote is placed
    /// immediately preceding and following each identifier.
    ///
    /// No default is provided.
    var identifierQuote: any SQLExpression { get }
    
    /// An expression (usually an `SQLRaw`) giving the character(s) used to quote literal
    /// string values which appear in a query, such as enumerator names. The literal quote
    /// is placed immediately preceding and following each string literal.
    ///
    /// Defaults to an apostrophe (`'`).
    var literalStringQuote: any SQLExpression { get }
    
    /// `true` if the dialect supports auto-increment for primary key values when inserting
    /// new rows, `false` if not. See also ``autoIncrementClause`` and ``autoIncrementFunction``.
    ///
    /// No default is provided.
    var supportsAutoIncrement: Bool { get }

    /// An expression inserted in a column definition when a `.primaryKey(autoincrement: true)`
    /// constraint is specified for the column. The clause will be included immediately after
    /// `PRIMARY KEY` in the resulting SQL.
    ///
    /// This property is ignored when ``supportsAutoIncrement`` is `false`, or when
    /// ``autoIncrementFunction`` is _not_ `nil`.
    ///
    /// No default is provided.
    var autoIncrementClause: any SQLExpression { get }
    
    /// An expression inserted in a column definition when a `.primaryKey(autoincrement: true)`
    /// constraint is specified for the column. The expression will be immediately preceded by
    /// the ``literalDefault`` expression  and appear immediately before `PRIMARY KEY` in the
    /// resulting SQL.
    ///
    /// This property is ignored when ``supportsAutoIncrement`` is `false`. If this property is
    /// not `nil`, it takes precedence over ``autoIncrementClause``.
    ///
    /// Defaults to `nil`.
    ///
    /// - Note: The design of this and the other autoincrement-released properties is less than
    ///   ideal, but it's public API and we're stuck with it for now.
    var autoIncrementFunction: (any SQLExpression)? { get }

    /// A function which returns an expression to be used as the placeholder for the `position`th
    /// bound parameter in a query. The function can ignore the value of `position` if the syntax
    /// doesn't require it.
    ///
    /// - Parameter position: Indicates which bound parameter to create a placeholder for, where
    ///   the first parameter has position `1`. This value is guaranteed to be greater than zero.
    ///
    /// No default is provided.
    func bindPlaceholder(at position: Int) -> any SQLExpression
    
    /// A function which returns an SQL expression (usually an `SQLRaw`) representing the given
    /// literal boolean value.
    ///
    /// No default is provided.
    func literalBoolean(_ value: Bool) -> any SQLExpression
    
    /// An expression (usually an `SQLRaw`) giving the syntax used to express both "use this as
    /// the default value" in a column definition and "use the default value for this column" in
    /// a value list. ``SQLLiteral.literal`` always serializes to this expression.
    ///
    /// Defaults to `SQLRaw("DEFAULT")`.
    var literalDefault: any SQLExpression { get }
    
    /// `true` if the dialect supports the `IF EXISTS` modifier for all types of `DROP` queries
    /// (such as `SQLDropEnum`, `SQLDropIndex`, `SQLDropTable`, and `SQLDropTrigger`) and the
    /// `IF NOT EXISTS` modifier for `SQLCreateTable` queries. It is not possible to indicate
    /// partial support at this time.
    ///
    /// Defaults to `true`.
    var supportsIfExists: Bool { get }
    
    /// The syntax the dialect supports for strongly-typed enumerations. See ``SQLEnumSyntax``
    /// for possible values.
    ///
    /// No default is provided. // TODO: Why not?
    var enumSyntax: SQLEnumSyntax { get }
    
    /// `true` if the dialect supports the ``SQLDropBehavior`` modifiers for `DROP` queries,
    /// `false` if not. See ``SQLDropBehavior`` for more information.
    ///
    /// Defauls to `false`.
    var supportsDropBehavior: Bool { get }
    
    /// `true` if the dialect supports the `RETURNING` syntax for retrieving output values from
    /// DML queries (`INSERT`, `UPDATE`, `DELETE`). See ``SQLReturning`` and ``SQLReturningBuilder``.
    ///
    /// Defaults to `false`.
    var supportsReturning: Bool { get }
    
    /// Various flags describing the dialect's support for specific features of `CREATE/DROP TRIGGER`
    /// queries. See ``SQLTriggerSyntax`` for more information.
    ///
    /// Defaults to no feature flags set.
    var triggerSyntax: SQLTriggerSyntax { get }
    
    /// A description of the syntax the dialect supports for `ALTER TABLE` queries. See
    /// ``SQLAlterTableSyntax`` for more information.
    ///
    /// Defaults to indicating no support at all.
    var alterTableSyntax: SQLAlterTableSyntax { get }
    
    /// A function which is consulted whenever an ``SQLDataType`` will be serialized into a
    /// query. The dialect may return an expression which will replace the default serialization
    /// of the given type. Returning `nil` causes the default to be used. This is intended to
    /// provide a customization point for dialects to override or supplement the default set of
    /// types and their default definitions.
    ///
    /// Defaults to returning `nil` for all inputs.
    func customDataType(for dataType: SQLDataType) -> (any SQLExpression)?
    
    /// A function which is consulted whenever a constraint name will be serialized into a
    /// query. The dialect must return an expression for an identifer which is unique to the
    /// input identifier and is a valid constraint name for the dialect. This provides an
    /// interception point for dialects which impose limitations on constraint names, such as
    /// length limits or a database-wide uniqueness requirement. It is not required that it
    /// be possible to convert a normalized identifer back to its original form (the conversion
    /// may be lossy). This function must not return the same result for different inputs, and
    /// must always return the same result when given the same input. A hashing function with
    /// a sufficiently large output size, such as SHA-256, is one possible correct implementation.
    ///
    /// Defaults to returning the input identifier unchanged.
    func normalizeSQLConstraint(identifier: any SQLExpression) -> any SQLExpression
    
    /// The type of `UPSERT` syntax supported by the dialect. See ``SQLUpsertSyntax`` for possible
    /// values and more information.
    ///
    /// Defaults to `.unsupported`.
    var upsertSyntax: SQLUpsertSyntax { get }
    
    /// A set of feature flags describing the dialect's support for various forms of `UNION` with
    /// `SELECT` queries. See ``SQLUnionFeatures`` for the possible flags and more information.
    ///
    /// Defaults to `[.union, .unionAll]`.
    var unionFeatures: SQLUnionFeatures { get }
    
    /// A serialization for ``SQLLockingClause/share``, representing a request for a shared "reader"
    /// lock on rows retrieved by a `SELECT` query. A `nil` value means the database doesn't
    /// support shared locking requests, which causes the locking clause to be silently ignored.
    var sharedSelectLockExpression: (any SQLExpression)? { get }
    
    /// A serialization for ``SQLLockingClause/update``, representing a request for an exclusive
    /// "writer" lock on rows retrieved by a `SELECT` query. A `nil` value means the database doesn't
    /// support exclusive locking requests, which causes the locking clause to be silently ignored.
    var exclusiveSelectLockExpression: (any SQLExpression)? { get }
    
}

/// Controls `ALTER TABLE` syntax.
public struct SQLAlterTableSyntax {
    /// Expression for altering a column's definition.
    ///
    ///     ALTER TABLE table [alterColumnDefinitionClause] column column_definition
    ///
    /// `nil` indicates lack of support for altering existing column definitions.
    public var alterColumnDefinitionClause: (any SQLExpression)?

    /// Expression for altering a column definition's type.
    ///
    ///     ALTER TABLE table [alterColumnDefinitionClause] column [alterColumnDefinitionTypeClause] dataType
    ///
    /// `nil` indicates that no extra keyword is required.
    public var alterColumnDefinitionTypeKeyword: (any SQLExpression)?

    /// If true, the dialect supports chaining multiple modifications together. If false,
    /// the dialect requires separate statements for each change.
    public var allowsBatch: Bool

    @inlinable
    public init(
        alterColumnDefinitionClause: (any SQLExpression)? = nil,
        alterColumnDefinitionTypeKeyword: (any SQLExpression)? = nil,
        allowsBatch: Bool = true
    ) {
        self.alterColumnDefinitionClause = alterColumnDefinitionClause
        self.alterColumnDefinitionTypeKeyword = alterColumnDefinitionTypeKeyword
        self.allowsBatch = allowsBatch
    }
}

/// Controls strongly-typed enumeration syntax.
public enum SQLEnumSyntax {
    /// For ex. MySQL, which uses the `ENUM` literal followed by the options.
    case inline

    /// For ex. PostgreSQL, which uses the name of a type that must be
    /// created separately.
    case typeName

    /// For ex. SQL Server, which does not have an enum syntax.
    ///
    /// - Note: you can likely simulate an enum with a `CHECK` constraint.
    case unsupported
}

/// Controls `CREATE TRIGGER` and `DROP TRIGGER` syntax.
public struct SQLTriggerSyntax {
    public struct Create: OptionSet {
        public var rawValue = 0
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static var requiresForEachRow: Self           { .init(rawValue: 1 << 0) }
        public static var supportsBody: Self                 { .init(rawValue: 1 << 1) }
        public static var supportsCondition: Self            { .init(rawValue: 1 << 2) }
        public static var supportsDefiner: Self              { .init(rawValue: 1 << 3) }
        public static var supportsForEach: Self              { .init(rawValue: 1 << 4) }
        public static var supportsOrder: Self                { .init(rawValue: 1 << 5) }
        public static var supportsUpdateColumns: Self        { .init(rawValue: 1 << 6) }
        public static var supportsConstraints: Self          { .init(rawValue: 1 << 7) }
        public static var postgreSQLChecks: Self             { .init(rawValue: 1 << 8) }
        public static var conditionRequiresParentheses: Self { .init(rawValue: 1 << 9) }
    }

    public struct Drop: OptionSet {
        public var rawValue = 0
        public init(rawValue: Int) { self.rawValue = rawValue }

        public static var supportsTableName: Self            { .init(rawValue: 1 << 0) }
        public static var supportsCascade: Self              { .init(rawValue: 1 << 1) }
    }

    public var create: Create
    public var drop: Drop

    public init(create: Create = [], drop: Drop = []) {
        self.create = create
        self.drop = drop
    }
}

/// The supported syntax variants which a SQL dialect can use to to specify `UPSERT` clauses.
public enum SQLUpsertSyntax: Equatable, CaseIterable {
    /// Indicates usage of the SQL-standard `ON CONFLICT ...` syntax, including index and update predicates, the
    /// `excluded.` pseudo-table name, and the `DO NOTHING` action for "ignore conflicts".
    case standard
    
    /// Indicates usage of the nonstandard `ON DUPLICATE KEY UPDATE ...` syntax, the `VALUES()` function, and
    /// `INSERT IGNORE` for "ignore conflicts". This syntax does not support conflict targets or update predicates.
    case mysqlLike
    
    /// Indicates that upserts are not supported at all.
    case unsupported
}

/// A set of feature support flags for `UNION` queries.
///
/// - Note: The `union` and `unionAll` flags are a bit redundant, since every dialect SQLKit supports
///   at the time of this writing supports them. Still, there are SQL dialects in the wild that do not,
///   such as mSQL, so the flags are here for completeness' sake.
public struct SQLUnionFeatures: OptionSet {
    // See ``RawRepresentable.rawValue``.
    public var rawValue: Int = 0
    
    // See ``RawRepresentable.init(rawValue:)``.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Indicates basic support for `UNION` queries. All other flags are ignored unless this one is set.
    public static var union: Self                   { .init(rawValue: 1 << 0) }
    
    /// Indicates whether the dialect supports `UNION ALL`.
    public static var unionAll: Self                { .init(rawValue: 1 << 1) }
    
    /// Indicates whether the dialect supports `INTERSECT`.
    public static var intersect: Self               { .init(rawValue: 1 << 2) }
    
    /// Indicates whether the dialect supports `INTERSECT ALL`.
    public static var intersectAll: Self            { .init(rawValue: 1 << 3) }
    
    /// Indicates whether the dialect supports `EXCEPT`.
    public static var except: Self                  { .init(rawValue: 1 << 4) }
    
    /// Indicates whether the dialect supports `EXCEPT ALL`.
    public static var exceptAll: Self               { .init(rawValue: 1 << 5) }

    /// Indicates whether the dialect supports explicitly specifying `DISTINCT` on supported union types.
    public static var explicitDistinct: Self        { .init(rawValue: 1 << 6) }
    
    /// Indicates whether the dialect allows parenthesizing the individual `SELECT` queries in a union.
    public static var parenthesizedSubqueries: Self { .init(rawValue: 1 << 7) }
    
}

/// Provides defaults for many of the `SQLDialect` properties. The defaults are chosen to reflect
/// a baseline set of syntax and features which are correct for as many dialects as possible,
/// so as to avoid breaking all existing dialects every time a new requirement is added to the
/// protocol and allow gradual adoption of new capabilities.
extension SQLDialect {
    public var literalDefault: any SQLExpression { SQLRaw("DEFAULT") }
    public var literalStringQuote: any SQLExpression { SQLRaw("'") }
    public var supportsIfExists: Bool { true }
    public var autoIncrementFunction: (any SQLExpression)? { nil }
    public var supportsDropBehavior: Bool { false }
    public var supportsReturning: Bool { false }
    public var alterTableSyntax: SQLAlterTableSyntax { .init() }
    public var triggerSyntax: SQLTriggerSyntax { .init() }
    public func customDataType(for dataType: SQLDataType) -> (any SQLExpression)? { nil }
    public func normalizeSQLConstraint(identifier: any SQLExpression) -> any SQLExpression { identifier }
    public var upsertSyntax: SQLUpsertSyntax { .unsupported }
    public var unionFeatures: SQLUnionFeatures { [.union, .unionAll] }
    public var sharedSelectLockExpression: (any SQLExpression)? { nil }
    public var exclusiveSelectLockExpression: (any SQLExpression)? { nil }
}

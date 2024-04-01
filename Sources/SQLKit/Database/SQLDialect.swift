/// An abstract definition of a specific dialect of SQL.
///
/// SQLKit uses the dialect provided by an instance of ``SQLDatabase`` to control various aspects
/// of query serialization, with the intent of keeping SQLKit's user-facing API from having to
/// expose database-specific details as much as possible. While SQL dialects in the wild vary too
/// widely in practice for this to ever be 100% effective, they also have enough in common to avoid
/// having to rewrite every line of serialization logic for each database driver.
public protocol SQLDialect: Sendable {
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
    
    /// An expression (usually an ``SQLRaw``) giving the character(s) used to quote SQL
    /// identifiers, such as table and column names.
    ///
    /// The identifier quote is placed immediately preceding and following each identifier.
    ///
    /// No default is provided.
    var identifierQuote: any SQLExpression { get }
    
    /// An expression (usually an ``SQLRaw``) giving the character(s) used to quote literal
    /// string values which appear in a query, such as enumerator names.
    ///
    /// The literal quote is placed immediately preceding and following each string literal.
    ///
    /// Defaults to an apostrophe (`'`).
    var literalStringQuote: any SQLExpression { get }
    
    /// `true` if the dialect supports auto-increment for primary key values when inserting
    /// new rows, `false` if not.
    ///
    /// See also ``autoIncrementClause`` and ``autoIncrementFunction-4cc1b``.
    ///
    /// No default is provided.
    var supportsAutoIncrement: Bool { get }

    /// An expression inserted in a column definition when a `.primaryKey(autoincrement: true)`
    /// constraint is specified for the column.
    ///
    /// The expression will be included immediately after `PRIMARY KEY` in the resulting SQL.
    ///
    /// This property is ignored when ``supportsAutoIncrement`` is `false`, or when
    /// ``autoIncrementFunction-4cc1b`` is _not_ `nil`.
    ///
    /// No default is provided.
    var autoIncrementClause: any SQLExpression { get }
    
    /// An expression inserted in a column definition when a
    /// ``SQLColumnConstraintAlgorithm/primaryKey(autoIncrement:)`` or
    /// ``SQLTableConstraintAlgorithm/primaryKey(columns:)`` constraint is specified for the
    /// column.
    ///
    /// The expression will be immediately preceded by the ``literalDefault-4l1ox`` expression
    /// and appear immediately before `PRIMARY KEY` in the resulting SQL.
    ///
    /// This property is ignored when ``supportsAutoIncrement`` is `false`. If this property is
    /// not `nil`, it takes precedence over ``autoIncrementClause``.
    ///
    /// Defaults to `nil`.
    ///
    /// > Note: The design of this and the other autoincrement-released properties is less than
    /// > ideal, but it's public API and we're stuck with it for now.
    var autoIncrementFunction: (any SQLExpression)? { get }

    /// A function which returns an expression to be used as the placeholder for the `position`th
    /// bound parameter in a query.
    ///
    /// The function may ignore the value of `position` if the syntax doesn't require or
    /// support it.
    ///
    /// No default is provided.
    ///
    /// - Parameter position: Indicates which bound parameter to create a placeholder for, where
    ///   the first parameter has position `1`. This value is guaranteed to be greater than zero.
    func bindPlaceholder(at position: Int) -> any SQLExpression
    
    /// A function which returns an SQL expression (usually an ``SQLRaw``) representing the given
    /// literal boolean value.
    /// 
    /// No default is provided.
    ///
    /// - Parameter value: The boolean value to represent.
    func literalBoolean(_ value: Bool) -> any SQLExpression
    
    /// An expression (usually an ``SQLRaw``) giving the syntax used to express both "use this as
    /// the default value" in a column definition and "use the default value for this column" in
    /// a value list.
    ///
    /// ``SQLLiteral/default`` always serializes to this expression.
    ///
    /// Defaults to `SQLRaw("DEFAULT")`.
    var literalDefault: any SQLExpression { get }
    
    /// `true` if the dialect supports the `IF EXISTS` modifier for all types of `DROP` queries
    /// (such as ``SQLDropEnum``, ``SQLDropIndex``, ``SQLDropTable``, and ``SQLDropTrigger``) and
    /// the `IF NOT EXISTS` modifier for ``SQLCreateTable`` queries.
    ///
    /// It is not possible to indicate partial support at this time.
    ///
    /// Defaults to `true`.
    var supportsIfExists: Bool { get }
    
    /// The syntax the dialect supports for strongly-typed enumerations.
    ///
    /// See ``SQLEnumSyntax`` for possible values.
    ///
    /// Defaults to ``SQLEnumSyntax/unsupported``.
    var enumSyntax: SQLEnumSyntax { get }
    
    /// `true` if the dialect supports the `behavior modifiers for `DROP` queries, `false` if not.
    ///
    /// See ``SQLDropBehavior`` for more information.
    ///
    /// Defauls to `false`.
    var supportsDropBehavior: Bool { get }
    
    /// `true` if the dialect supports `RETURNING` syntax for retrieving output values from
    /// DML queries (`INSERT`, `UPDATE`, `DELETE`).
    ///
    /// See ``SQLReturning`` and ``SQLReturningBuilder`` for more information.
    ///
    /// Defaults to `false`.
    var supportsReturning: Bool { get }
    
    /// Various flags describing the dialect's support for specific features of
    /// ``SQLCreateTrigger`` and ``SQLDropTrigger`` queries.
    ///
    /// See ``SQLTriggerSyntax`` for more information.
    ///
    /// Defaults to no feature flags set.
    var triggerSyntax: SQLTriggerSyntax { get }
    
    /// A description of the syntax the dialect supports for ``SQLAlterTable`` queries.
    ///
    /// See ``SQLAlterTableSyntax`` for more information.
    ///
    /// Defaults to indicating no support at all.
    var alterTableSyntax: SQLAlterTableSyntax { get }
    
    /// A function which is consulted whenever an ``SQLDataType`` will be serialized into a
    /// query. The dialect may return an expression which will replace the default serialization
    /// of the given type. Returning `nil` causes the default to be used.
    ///
    /// This is intended to provide a customization point for dialects to override or supplement
    /// the default set of types and their default definitions.
    ///
    /// Defaults to returning `nil` for all inputs.
    func customDataType(for dataType: SQLDataType) -> (any SQLExpression)?
    
    /// A function which is consulted whenever a constraint name will be serialized into a
    /// query. The dialect must return an expression for an identifer which is unique to the
    /// input identifier and is a valid constraint name for the dialect.
    ///
    /// This provides an interception point for dialects which impose limitations on constraint
    /// names, such as length limits or a database-wide uniqueness requirement. It is not
    /// required that it be possible to convert a normalized identifer back to its original form
    /// (the conversion may be lossy). This function must not return the same result for
    /// different inputs, and must always return the same result when given the same input. A
    /// hashing function with a sufficiently large output size, such as SHA-256, is one possible
    /// correct implementation.
    ///
    /// Defaults to returning the input identifier unchanged.
    func normalizeSQLConstraint(identifier: any SQLExpression) -> any SQLExpression
    
    /// The type of `UPSERT` syntax supported by the dialect.
    ///
    /// See ``SQLUpsertSyntax`` for possible values and more information.
    ///
    /// Defaults to ``SQLUpsertSyntax/unsupported``.
    var upsertSyntax: SQLUpsertSyntax { get }
    
    /// A set of feature flags describing the dialect's support for various forms of `UNION` with
    /// `SELECT` queries.
    ///
    /// See ``SQLUnionFeatures`` for the possible flags and more information.
    ///
    /// Defaults to `[.union, .unionAll]`.
    var unionFeatures: SQLUnionFeatures { get }
    
    /// A serialization for ``SQLLockingClause/share``.
    ///
    /// Represents a request for a shared "reader" lock on rows retrieved by a `SELECT` query. A
    /// `nil` value signals that the dialect doesn't support shared locking requests, in which
    /// cas the locking clause is silently ignored.
    ///
    /// Defaults to `nil`.
    var sharedSelectLockExpression: (any SQLExpression)? { get }
    
    /// A serialization for ``SQLLockingClause/update``.
    /// 
    /// Represents a request for an exclusive "writer" lock on rows retrieved by a `SELECT`
    /// query. A `nil` value signals that the dialect doesn't support exclusive locking requests,
    /// in which case the locking clause is silently ignored.
    ///
    /// Defaults to `nil`.
    var exclusiveSelectLockExpression: (any SQLExpression)? { get }
    
    /// Given a column name and a path consisting of one or more elements, return an expression
    /// appropriate for accessing a value at the given JSON path.
    ///
    /// A `nil` result signals that JSON subpath expressions are not supported, or that the given
    /// path is not valid for this dialect.
    ///
    /// Defaults to returning `nil`.
    func nestedSubpathExpression(in column: any SQLExpression, for path: [String]) -> (any SQLExpression)?
}

/// Encapsulates a dialect's support for `ALTER TABLE` syntax.
public struct SQLAlterTableSyntax: Sendable {
    /// Expression used when altering a column's definition.
    ///
    /// ```sql
    /// ALTER TABLE table [alterColumnDefinitionClause] column column_definition
    /// ```
    ///
    /// `nil` indicates lack of support for altering existing column definitions.
    public var alterColumnDefinitionClause: (any SQLExpression)?

    /// Expression used when altering a column's type. Ignored if ``alterColumnDefinitionClause`` is `nil`.
    ///
    /// ```sql
    /// ALTER TABLE table [alterColumnDefinitionClause] column [alterColumnDefinitionTypeClause] dataType
    /// ```
    ///
    /// `nil` indicates that no extra keyword is required.
    public var alterColumnDefinitionTypeKeyword: (any SQLExpression)?

    /// Indicates support for performing multiple alterations to a table in a single query.
    ///
    /// If `false`, a separate `ALTER TABLE` statement must be executed for each desired change.
    public var allowsBatch: Bool
    
    /// Memberwise initializer.
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

/// Possible values for a dialect's strongly-typed enumeration support.
public enum SQLEnumSyntax: Sendable {
    /// MySQL's "inline" enumerations.
    ///
    /// MySQL defines an `ENUM` field type, which contains a listing of its individual cases
    /// inline. The cases can be changed after the initial defintion via `ALTER TABLE`.
    ///
    /// MySQL example:
    /// ```sql
    /// CREATE TABLE `foo` (
    ///     `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    ///     `my_fruit` ENUM ('apple', 'orange', 'banana') NOT NULL
    /// );
    /// ```
    case inline

    /// PostgreSQL's custom user type enumerations.
    ///
    /// PostgreSQL implements enums as one of a few different kinds of user-defined custom data
    /// types, which must be created separately before their use in a table. Once created, an
    /// enumeration may add new cases and rename existing ones, but may not delete them without
    /// deleting the entire custom type.
    ///
    /// PostgreSQL example:
    /// ```sql
    /// CREATE TYPE "fruit" AS ENUM ( 'apple', 'orange', 'banana' );
    ///
    /// CREATE TABLE "foo" (
    ///     "id" BIGINT NOT NULL PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    ///     "my_fruit" fruit NOT NULL
    /// );
    /// ```
    case typeName

    /// No enumeration type is supported.
    ///
    /// For dialects which do not have native enumeration support, a simple string column can
    /// serve the same function, with the caveat that its correctness will not be enforced by the
    /// database, unless the database supports `CHECK` constraints and such a constraint is
    /// appropriately applied.
    ///
    /// SQLite example:
    /// ```sql
    /// CREATE TABLE "foo" (
    ///     "id" INTEGER PRIMARY KEY,
    ///     "my_fruit" TEXT NOT NULL CHECK
    ///         ("my_fruit" IN ('apple', 'orange', 'banana'))
    /// );
    /// ```
    case unsupported
}

/// Encapsulates a dialect's support for `CREATE TRIGGER` and `DROP TRIGGER` syntax.
public struct SQLTriggerSyntax: Sendable {
    /// Describes specific feature support for `CREATE TRIGGER` syntax.
    public struct Create: OptionSet, Sendable {
        // See `RawRepresentable.rawValue`.
        public var rawValue = 0
        
        // See `OptionSet.init(rawValue:)`.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Indicates that the `FOR EACH ROW` clause is syntactically required for trigger creation.
        public static var requiresForEachRow: Self {
            .init(rawValue: 1 << 0)
        }

        /// Indicates support for specifying a trigger's implementation as an inline sequence of statements.
        public static var supportsBody: Self {
            .init(rawValue: 1 << 1)
        }

        /// Indicates support for a conditional predicate controlling invocation of the trigger.
        public static var supportsCondition: Self {
            .init(rawValue: 1 << 2)
        }

        /// Indicates support for specifying a `DEFINER` clause for the purposes of access control.
        public static var supportsDefiner: Self {
            .init(rawValue: 1 << 3)
        }

        /// Indicates support for the `FOR EACH ROW` and `FOR EACH STATEMENT` syntax.
        public static var supportsForEach: Self {
            .init(rawValue: 1 << 4)
        }

        /// `Indicates support for ordering triggers relative to one another.
        public static var supportsOrder: Self {
            .init(rawValue: 1 << 5)
        }

        /// Indicates support for an `OF` clause on `UPDATE` triggers specifying that only a subset of columns should
        /// invoke the trigger.
        public static var supportsUpdateColumns: Self {
            .init(rawValue: 1 << 6)
        }

        /// Indicates support for the `CONSTRAINT` trigger type.
        public static var supportsConstraints: Self {
            .init(rawValue: 1 << 7)
        }

        /// Indicates that PostgreSQL-specific syntax correctness checks should be made at runtime.
        ///
        /// > Important: The checks in question are implemented as logging statements with the `.warning` level;
        /// > invalid SQL syntax may still be generated.
        public static var postgreSQLChecks: Self {
            .init(rawValue: 1 << 8)
        }

        /// When ``supportsCondition`` is also set, indicates that the condition must be wrapped by parenthesis.
        public static var conditionRequiresParentheses: Self {
            .init(rawValue: 1 << 9)
        }
    }

    /// Describes specific feature support for `CREATE TRIGGER` syntax.
    public struct Drop: OptionSet, Sendable {
        // See `RawRepresentable.rawValue`.
        public var rawValue = 0
        
        // See `OptionSet.init(rawValue:)`.
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Indicates support for an `OF` clause indicating which table the trigger to be dropped is attached to.
        public static var supportsTableName: Self {
            .init(rawValue: 1 << 0)
        }
        
        /// Indicates support for the `CASCADE` modifier; see ``SQLDropBehavior`` for details.
        public static var supportsCascade: Self {
            .init(rawValue: 1 << 1)
        }
    }

    /// Syntax options for `CREATE TRIGGER`.
    public var create: Create
    
    /// Syntax options for `DROP TRIGGER`.
    public var drop: Drop

    /// Memberwise initializer.
    public init(create: Create = [], drop: Drop = []) {
        self.create = create
        self.drop = drop
    }
}

/// The supported syntax variants which a SQL dialect can use to to specify conflict resolution clauses.
public enum SQLUpsertSyntax: Equatable, CaseIterable, Sendable {
    /// Indicates support for the SQL-standard `ON CONFLICT ...` syntax, including index and update
    /// predicates, the `excluded.` pseudo-table name, and the `DO NOTHING` action for "ignore
    /// conflicts".
    case standard
    
    /// Indicates support for the nonstandard `ON DUPLICATE KEY UPDATE ...` syntax, the `VALUES()`
    /// function, and `INSERT IGNORE` for "ignore conflicts". This syntax does not support
    /// conflict targets or update predicates.
    case mysqlLike

    /// Indicates lack of any support for conflict resolution.
    case unsupported
}

/// A set of feature support flags for `UNION` queries.
///
/// > Note: The `union` and `unionAll` flags are a bit redundant, since every dialect SQLKit
/// > supports at the time of this writing supports them. Still, there are SQL dialects in the
/// > wild that do not, such as mSQL, so the flags are here for completeness' sake.
public struct SQLUnionFeatures: OptionSet, Sendable {
    // See `RawRepresentable.rawValue`.
    public var rawValue = 0
    
    // See `OptionSet.init(rawValue:)`.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Indicates support for `UNION DISTINCT` unions.
    public static var union: Self {
        .init(rawValue: 1 << 0)
    }
    
    /// Indicates support for `UNION ALL` unions.
    public static var unionAll: Self {
        .init(rawValue: 1 << 1)
    }
    
    /// Indicates support for `INTERSECT DISTINCT` unions.
    public static var intersect: Self {
        .init(rawValue: 1 << 2)
    }
    
    /// Indicates support for `INTERSECT ALL` unions.
    public static var intersectAll: Self {
        .init(rawValue: 1 << 3)
    }
    
    /// Indicates support for `EXCEPT DISTINCT` unions.
    public static var except: Self {
        .init(rawValue: 1 << 4)
    }
    
    /// Indicates support for `EXCEPT ALL` unions.
    public static var exceptAll: Self {
        .init(rawValue: 1 << 5)
    }
    
    /// Indicates that the `DISTINCT` modifier must be explicitly specified for the relevant union types.
    public static var explicitDistinct: Self {
        .init(rawValue: 1 << 6)
    }
    
    /// Indicates that the individual `SELECT` queries in a union must be parenthesized.
    public static var parenthesizedSubqueries: Self {
        .init(rawValue: 1 << 7)
    }
}

/// Provides defaults for many of the ``SQLDialect`` properties. The defaults are chosen to
/// reflect a baseline set of syntax and features which are correct for as many dialects
/// as possible, so as to avoid breaking all existing dialects every time a new requirement
/// is added to the protocol and allow gradual adoption of new capabilities.
extension SQLDialect {
    /// Default implementation of ``literalStringQuote-3ur0m``.
    @inlinable
    public var literalStringQuote: any SQLExpression {
        SQLRaw("'")
    }

    /// Default implementation of ``autoIncrementFunction-1ktxy``.
    @inlinable
    public var autoIncrementFunction: (any SQLExpression)? {
        nil
    }

    /// Default implementation of ``literalDefault-7nz7t``.
    @inlinable
    public var literalDefault: any SQLExpression {
        SQLRaw("DEFAULT")
    }

    /// Default implementation of ``supportsIfExists-5dxcu``.
    @inlinable
    public var supportsIfExists: Bool {
        true
    }

    /// Default implementation of ``enumSyntax-7atad``.
    @inlinable
    public var enumSyntax: SQLEnumSyntax {
        .unsupported
    }
    
    /// Default implementation of ``supportsDropBehavior-6vvl0``.
    @inlinable
    public var supportsDropBehavior: Bool {
        false
    }

    /// Default implementation of ``supportsReturning-r61k``.
    @inlinable
    public var supportsReturning: Bool {
        false
    }

    /// Default implementation of ``triggerSyntax-9579a``.
    @inlinable
    public var triggerSyntax: SQLTriggerSyntax {
        .init()
    }

    /// Default implementation of ``alterTableSyntax-9bmcr``.
    @inlinable
    public var alterTableSyntax: SQLAlterTableSyntax {
        .init()
    }

    /// Default implementation of ``customDataType(for:)-2firt``.
    @inlinable
    public func customDataType(for: SQLDataType) -> (any SQLExpression)? {
        nil
    }

    /// Default implementation of ``normalizeSQLConstraint(identifier:)-3vca6``.
    @inlinable
    public func normalizeSQLConstraint(identifier: any SQLExpression) -> any SQLExpression {
        identifier
    }

    /// Default implementation of ``upsertSyntax-snn6``.
    @inlinable
    public var upsertSyntax: SQLUpsertSyntax {
        .unsupported
    }

    /// Default implementation of ``unionFeatures-473tk``.
    @inlinable
    public var unionFeatures: SQLUnionFeatures {
        [.union, .unionAll]
    }

    /// Default implementation of ``sharedSelectLockExpression-6lb8t``.
    @inlinable
    public var sharedSelectLockExpression: (any SQLExpression)? {
        nil
    }

    /// Default implementation of ``exclusiveSelectLockExpression-21gkt``.
    @inlinable
    public var exclusiveSelectLockExpression: (any SQLExpression)? {
        nil
    }

    /// Default implementation of ``nestedSubpathExpression(in:for:)-7d4cw``.
    @inlinable
    public func nestedSubpathExpression(in: any SQLExpression, for: [String]) -> (any SQLExpression)? {
        nil
    }
}

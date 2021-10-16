public protocol SQLDialect {
    var name: String { get }
    var identifierQuote: SQLExpression { get }
    var literalStringQuote: SQLExpression { get }
    var autoIncrementClause: SQLExpression { get }
    func bindPlaceholder(at position: Int) -> SQLExpression
    func literalBoolean(_ value: Bool) -> SQLExpression
    var literalDefault: SQLExpression { get }
    var supportsIfExists: Bool { get }
    var supportsAutoIncrement: Bool { get }
    var autoIncrementFunction: SQLExpression? { get }
    var enumSyntax: SQLEnumSyntax { get }
    var supportsDropBehavior: Bool { get }
    var supportsReturning: Bool { get }
    var triggerSyntax: SQLTriggerSyntax { get }
    var alterTableSyntax: SQLAlterTableSyntax { get }
    func customDataType(for dataType: SQLDataType) -> SQLExpression?
    func normalizeSQLConstraint(identifier: SQLExpression) -> SQLExpression
    var upsertSyntax: SQLUpsertSyntax { get }
}

extension SQLDialect {
    public func customDataType(for dataType: SQLDataType) -> SQLExpression? {
        nil
    }
}

/// Controls `ALTER TABLE` syntax.
public struct SQLAlterTableSyntax {
    /// Expression for altering a column's definition.
    ///
    ///     ALTER TABLE table [alterColumnDefinitionClause] column column_definition
    ///
    /// `nil` indicates lack of support for altering existing column definitions.
    public var alterColumnDefinitionClause: SQLExpression?

    /// Expression for altering a column definition's type.
    ///
    ///     ALTER TABLE table [alterColumnDefinitionClause] column [alterColumnDefinitionTypeClause] dataType
    ///
    /// `nil` indicates that no extra keyword is required.
    public var alterColumnDefinitionTypeKeyword: SQLExpression?

    /// If true, the dialect supports chaining multiple modifications together. If false,
    /// the dialect requires separate statements for each change.
    public var allowsBatch: Bool

    public init(
        alterColumnDefinitionClause: SQLExpression? = nil,
        alterColumnDefinitionTypeKeyword: SQLExpression? = nil,
        allowsBatch: Bool = true
    ) {
        self.alterColumnDefinitionClause = alterColumnDefinitionClause
        self.alterColumnDefinitionTypeKeyword = alterColumnDefinitionTypeKeyword
        self.allowsBatch = allowsBatch
    }
}

extension SQLDialect {
    public var alterTableSyntax: SQLAlterTableSyntax {
        .init()
    }
}

public enum SQLEnumSyntax {
    /// for ex. MySQL, which uses the ENUM literal followed by the options
    case inline

    /// for ex. PostgreSQL, which uses the name of type that must have been
    /// previously created.
    case typeName

    /// for ex. SQL Server, which does not have an enum syntax.
    /// - note: you can likely simulate an enum with a CHECK constraint.
    case unsupported
}

public struct SQLTriggerSyntax {
    public struct Create: OptionSet {
        public var rawValue = 0

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let requiresForEachRow = Create(rawValue: 1 << 0)
        public static let supportsBody = Create(rawValue: 1 << 1)
        public static let supportsCondition = Create(rawValue: 1 << 2)
        public static let supportsDefiner = Create(rawValue: 1 << 3)
        public static let supportsForEach = Create(rawValue: 1 << 4)
        public static let supportsOrder = Create(rawValue: 1 << 5)
        public static let supportsUpdateColumns = Create(rawValue: 1 << 6)
        public static let supportsConstraints = Create(rawValue: 1 << 7)
        public static let postgreSQLChecks = Create(rawValue: 1 << 8)
        public static let conditionRequiresParentheses = Create(rawValue: 1 << 9)
    }

    public struct Drop: OptionSet {
        public var rawValue = 0

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let supportsTableName = Drop(rawValue: 1 << 0)
        public static let supportsCascade = Drop(rawValue: 1 << 1)
    }

    public var create = Create()
    public var drop = Drop()

    public init() {}
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

extension SQLDialect {
    public var literalDefault: SQLExpression {
        return SQLRaw("DEFAULT")
    }

    public var literalStringQuote: SQLExpression {
        return SQLRaw("'")
    }

    public var supportsIfExists: Bool {
        return true
    }

    public var autoIncrementFunction: SQLExpression? {
        return nil
    }

    public var supportsDropBehavior: Bool {
        return false
    }

    public var supportsReturning: Bool {
        return false
    }

    public var triggerSyntax: SQLTriggerSyntax {
        return SQLTriggerSyntax()
    }
    
    public func normalizeSQLConstraint(identifier: SQLExpression) -> SQLExpression {
        return identifier
    }
    
    public var upsertSyntax: SQLUpsertSyntax {
        return .unsupported
    }
}

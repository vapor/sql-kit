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
    var enumSyntax: SQLEnumSyntax { get }
    var dropTriggerSupportsTableName: Bool { get }
    var dropTriggerSupportsCascade: Bool { get }
    var createTriggerRequiresForEachRow: Bool { get }
    var createTriggerSupportsBody: Bool { get }
    var createTriggerSupportsCondition: Bool { get }
    var createTriggerConditionRequiresParens: Bool { get }
    var createTriggerSupportsConstraint: Bool { get }
    var createTriggerSupportsDefiner: Bool { get }
    var createTriggerSupportsForEach: Bool { get }
    var createTriggerSupportsOrder: Bool { get }
    var createTriggerSupportsUpdateColumns: Bool { get }
    var createTriggerPostgreSqlChecks: Bool { get }
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

extension SQLDialect {
    public var literalDefault: SQLExpression {
        return SQLRaw("DEFAULT")
    }

    public var supportsIfExists: Bool {
        return true
    }

    public var createTriggerRequiresForEachRow: Bool {
        return false
    }

    public var createTriggerSupportsConstraint: Bool {
        return false
    }

    public var createTriggerSupportsDefiner: Bool {
        return false
    }

    public var createTriggerSupportsForEach: Bool {
        return false
    }

    public var createTriggerSupportsCondition: Bool {
        return false
    }

    public var createTriggerPostgreSqlChecks: Bool {
        return false
    }

    public var createTriggerSupportsOrder: Bool {
        return false
    }
    
    public var createTriggerSupportsUpdateColumns: Bool {
        return false
    }

    public var createTriggerSupportsBody: Bool {
        return false
    }

    public var createTriggerConditionRequiresParens: Bool {
        return false
    }
    
    public var dropTriggerSupportsTableName: Bool {
        return false
    }

    public var dropTriggerSupportsCascade: Bool {
        return false
    }
}

# ``SQLKit``

@Metadata {
    @TitleHeading(Package)
}

SQLKit is a library for building and serializing SQL queries in Swift.

SQLKit's query construction facilities provide mappings between Swift types and database field types, and a direct interface for executing SQL queries. It attempts to abstract away the many differences between the various dialects of SQL whenever practical, allowing users to construct queries for use with any of the supported database systems. Custom SQL can be directly specified as needed, such as when abstraction of syntax is not possible or unimplemented.

> Note: Having been originally designed as a low-level "construction kit" for the Fluent ORM, the current incarnation of SQLKit is often excessively verbose, and offers relatively few user-friendly APIs. A future major release of Fluent is expected to replace both packages with an API designed around the same concepts as SQLKit, except targeted for both high-level and low-level use.  

SQLKit does _not_ provide facilities for creating or managing database connections; this functionality must be provided by a separate driver package which implements the required SQLKit protocols.

## Topics

### Fundamentals

- ``SQLExpression``
- ``SQLSerializer``
- ``SQLStatement``

### Data Access

- ``SQLDatabase``
- ``SQLRow``
- ``SQLRowDecoder``
- ``SQLQueryEncoder``

### Drivers

- ``SQLDialect``
- ``SQLDatabaseReportedVersion``
- ``SQLAlterTableSyntax``
- ``SQLTriggerSyntax``
- ``SQLUnionFeatures``
- ``SQLEnumSyntax``
- ``SQLUpsertSyntax``

### Builder Protocols

- ``SQLAliasedColumnListBuilder``
- ``SQLColumnUpdateBuilder``
- ``SQLJoinBuilder``
- ``SQLPartialResultBuilder``
- ``SQLPredicateBuilder``
- ``SQLQueryBuilder``
- ``SQLQueryFetcher``
- ``SQLReturningBuilder``
- ``SQLSecondaryPredicateBuilder``
- ``SQLSubqueryClauseBuilder``
- ``SQLUnqualifiedColumnListBuilder``

### Query Builders

- ``SQLAlterEnumBuilder``
- ``SQLAlterTableBuilder``
- ``SQLConflictUpdateBuilder``
- ``SQLCreateEnumBuilder``
- ``SQLCreateIndexBuilder``
- ``SQLCreateTableBuilder``
- ``SQLCreateTriggerBuilder``
- ``SQLDeleteBuilder``
- ``SQLDropEnumBuilder``
- ``SQLDropIndexBuilder``
- ``SQLDropTableBuilder``
- ``SQLDropTriggerBuilder``
- ``SQLInsertBuilder``
- ``SQLPredicateGroupBuilder``
- ``SQLRawBuilder``
- ``SQLReturningResultBuilder``
- ``SQLSecondaryPredicateGroupBuilder``
- ``SQLSelectBuilder``
- ``SQLSubqueryBuilder``
- ``SQLUnionBuilder``
- ``SQLUpdateBuilder``

### Syntactic Expressions

- ``SQLBinaryExpression``
- ``SQLBinaryOperator``
- ``SQLBind``
- ``SQLFunction``
- ``SQLGroupExpression``
- ``SQLIdentifier``
- ``SQLList``
- ``SQLLiteral``
- ``SQLRaw``

### Basic Expressions

- ``SQLAlias``
- ``SQLBetween``
- ``SQLColumn``
- ``SQLConstraint``
- ``SQLDataType``
- ``SQLDirection``
- ``SQLDistinct``
- ``SQLForeignKeyAction``
- ``SQLNestedSubpathExpression``
- ``SQLQualifiedTable``
- ``SQLQueryString``

### Clause Expressions

- ``SQLAlterColumnDefinitionType``
- ``SQLColumnAssignment``
- ``SQLColumnConstraintAlgorithm``
- ``SQLColumnDefinition``
- ``SQLConflictAction``
- ``SQLConflictResolutionStrategy``
- ``SQLDropBehavior``
- ``SQLEnumDataType``
- ``SQLExcludedColumn``
- ``SQLForeignKey``
- ``SQLInsertModifier``
- ``SQLJoin``
- ``SQLJoinMethod``
- ``SQLLockingClause``
- ``SQLOrderBy``
- ``SQLReturning``
- ``SQLSubquery``
- ``SQLTableConstraintAlgorithm``
- ``SQLUnionJoiner``

### Query Expressions

- ``SQLAlterEnum``
- ``SQLAlterTable``
- ``SQLCreateEnum``
- ``SQLCreateIndex``
- ``SQLCreateTable``
- ``SQLCreateTrigger``
- ``SQLDelete``
- ``SQLDropEnum``
- ``SQLDropIndex``
- ``SQLDropTable``
- ``SQLDropTrigger``
- ``SQLInsert``
- ``SQLSelect``
- ``SQLUnion``
- ``SQLUpdate``

### Miscellaneous

- ``SomeCodingKey``

### Deprecated

- ``SQLCreateTableAsSubqueryBuilder``
- ``SQLError``
- ``SQLErrorType``
- ``SQLTriggerEach``
- ``SQLTriggerEvent``
- ``SQLTriggerOrder``
- ``SQLTriggerTiming``
- ``SQLTriggerWhen``

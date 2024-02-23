# ``SQLKit``

@Metadata {
    @TitleHeading(Package)
}

SQLKit is an library for building and serializing SQL queries in Swift.

SQLKit's query construction facilities provide mappings between Swift types and database field types, and a direct interface to executing SQL queries. It attempts to abstract away the many differences between the various dialects of SQL whenever practical, allowing users to construct queries for use with any of the supported database systems. Custom SQL can be directly specified as needed, such as when abstraction of syntax is not possible or unimplemented.

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
- ``SQLConflictUpdateBuilder``
- ``SQLJoinBuilder``
- ``SQLPartialResultBuilder``
- ``SQLPredicateBuilder``
- ``SQLPredicateGroupBuilder``
- ``SQLQueryBuilder``
- ``SQLQueryFetcher``
- ``SQLReturningBuilder``
- ``SQLSecondaryPredicateBuilder``
- ``SQLSecondaryPredicateGroupBuilder``
- ``SQLSubqueryBuilder``
- ``SQLSubqueryClauseBuilder``
- ``SQLUnqualifiedColumnListBuilder``

### Query Builders

- ``SQLAlterEnumBuilder``
- ``SQLAlterTableBuilder``
- ``SQLCreateEnumBuilder``
- ``SQLCreateIndexBuilder``
- ``SQLCreateTableAsSubqueryBuilder``
- ``SQLCreateTableBuilder``
- ``SQLCreateTriggerBuilder``
- ``SQLDeleteBuilder``
- ``SQLDropEnumBuilder``
- ``SQLDropIndexBuilder``
- ``SQLDropTableBuilder``
- ``SQLDropTriggerBuilder``
- ``SQLInsertBuilder``
- ``SQLRawBuilder``
- ``SQLReturningResultBuilder``
- ``SQLSelectBuilder``
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
- ``SQLQueryString``
- ``SQLRaw``

### Basic Expressions

- ``SQLAlias``
- ``SQLBetween``
- ``SQLColumn``
- ``SQLConstraint``
- ``SQLDataType``
- ``SQLDirection``
- ``SQLForeignKeyAction``
- ``SQLNestedSubpathExpression``
- ``SQLQualifiedTable``

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

- ``SQLDistinct``
- ``SQLError``
- ``SQLErrorType``

<!--

## Database

Instances of ``SQLDatabase`` are capable of serializing and executing ``SQLExpression``s:

```swift
let db: any SQLDatabase = // ...
db.execute(sql: db.serialize(db.select().column(SQLLiteral.string("a")).query), onRow: { (row: any SQLRow) in
    // ...
})
```

The ``SQLExpression`` protocol provides a common interface for transforming an arbitrary set of syntactical building blocks into a string of SQL code. A comprehensive set of SQL building blocks for SQL syntax   various syntactical building blocks  which abstracts an arbitrary sequence of that represents a SQL query string and optional bind values. It can represent an entire SQL query or just a fragment.

SQLKit provides `SQLExpression`s for common queries like `SELECT`, `UPDATE`, `INSERT`, `DELETE`, `CREATE TABLE`, and many more.

```swift
var select = SQLSelect()
select.columns = [...]
select.tables = [...]
select.predicate = ...
```

`SQLDatabase` can be used to create fluent query builders for most of these query types.

```swift
struct Planet: Codable { var id: Int, name: String }

let db: some SQLDatabase = ...
try await db.create(table: "planets")
    .column("id", type: .int, .primaryKey(autoIncrement: true), .notNull)
    .column("name", type: .string, .notNull)
    .run()
try await db.insert(into: "planets")
    .columns("id", "name")
    .values(SQLLiteral.default, SQLBind("Earth"))
    .values(SQLLiteral.default, SQLBind("Mars"))
    .run()
let planets = try await db.select()
    .columns("id", "name")
    .from("planets")
    .all(decoding: Planet.self)
print(planets) // [Planet(id: 1, name: "Earth"), Planet(id: 2, name: "Mars")]
```

You can execute a query builder by calling `run()`. 

### Rows

For query builders that support returning results (e.g. any builder conforming to the `SQLQueryFetcher` protocol), there are additional methods for handling the database output:

- `all()`: Returns an array of rows.
- `first()`: Returns an optional row.
- `run(_:)`: Accepts a closure that handles rows as they are returned.

Each of these methods returns `SQLRow`, which has methods for access column values.

```swift
let row: any SQLRow
let name = try row.decode(column: "name", as: String.self)
print(name) // String
```

### Codable

`SQLRow` also supports decoding `Codable` models directly from a row.

```swift
struct Planet: Codable {
    var name: String
}

let planet = try row.decode(model: Planet.self)
```

Query builders that support returning results have convenience methods for automatically decoding models.

```swift
let planets: [Planet] = try await db.select()
    ...
    .all(decoding: Planet.self)
```

## Select

The `SQLDatabase.select()` method creates a `SELECT` query builder:

```swift
let planets: [any SQLRow] = try await db.select()
    .columns("id", "name")
    .from("planets")
    .where("name", .equal, "Earth")
    .all()
```

This code generates the following SQL when used with the PostgresKit driver:

```PLpgsql
SELECT "id", "name" FROM "planets" WHERE "name" = $1 -- bindings: ["Earth"]
```

Notice that `Encodable` values are automatically bound as parameters instead of being serialized directly to the query.

The select builder includes the following methods (typically with several variations):

- `columns()` (specify a list of columns and/or expressions to return)
- `from()` (specify a table to select from)
- `join()` (specify additional tables and how to relate them to others)
- `where()` and `orWhere()` (specify conditions that narrow down the possible results)
- `limit()` and `offset()` (specify a limited and/or offsetted range of results to return)
- `orderBy()` (specify how to sort results before returning them)
- `groupBy()` (specify columns and/or expressions for aggregating results)
- `having()` and `orHaving()` (specify secondary conditions to apply to the results after aggregation)
- `distinct()` (specify coalescing of duplicate results)
- `for()` and `lockingClause()` (specify locking behavior for rows that appear in results)

Conditional expressions provided to `where()` or `having()` are joined with `AND`. Corresponding `orWhere()` and `orHaving()` methods join conditions with `OR` instead.

```swift
builder.where("name", .equal, "Earth").orWhere("name", .equal, "Mars")
```

This code generates the following SQL when used with the MySQL driver:

```mysql
WHERE `name` = ? OR `name` = ? -- bindings: ["Earth", "Mars"]
```

`where()`, `orWhere()`, `having()`, and `orHaving()` also support creating grouped clauses:

```swift
builder.where("name", .notEqual, SQLLiteral.null).where {
    $0.where("name", .equal, SQLBind("Milky Way"))
      .orWhere("name", .equal, SQLBind("Andromeda"))
}
```

This code generates the following SQL when used with the SQLite driver:

```sql
WHERE "name" <> NULL AND ("name" = ?1 OR "name" = ?2) -- bindings: ["Milky Way", "Andromeda"]
```

## Insert

The `insert(into:)` method creates an `INSERT` query builder:

```swift
try await db.insert(into: "galaxies")
    .columns("id", "name")
    .values(SQLLiteral.default, SQLBind("Milky Way"))
    .values(SQLLiteral.default, SQLBind("Andromeda"))
    .run()
```

This code generates the following SQL when used with the PostgreSQL driver:

```PLpgsql
INSERT INTO "galaxies" ("id", "name") VALUES (DEFAULT, $1), (DEFAULT, $2) -- bindings: ["Milky Way", "Andromeda"]
```

The insert builder also has a method for encoding a `Codable` type as a set of values:

```swift
struct Galaxy: Codable {
    var name: String
}

try builder.model(Galaxy(name: "Milky Way"))
```

This code generates the same SQL as would `builder.columns("name").values("Milky Way")`.

## Update

The `update(_:)` method creates an `UPDATE` query builder:

```swift
try await db.update("planets")
    .set("name", to: "Jupiter")
    .where("name", .equal, "Jupiter")
    .run()
```

This code generates the following SQL when used with the MySQL driver:

```mysql
UPDATE `planets` SET `name` = ? WHERE `name` = ? -- bindings: ["Jupiter", "Jupiter"]
```

The update builder supports the same `where()` and `orWhere()` methods as the select builder, via the `SQLPredicateBuilder` protocol.

## Delete

The `delete(from:)` method creates a `DELETE` query builder:

```swift
try await db.delete(from: "planets")
    .where("name", .equal, "Jupiter")
    .run()
```

This code generates the following SQL when used with the SQLite driver:

```sql
DELETE FROM "planets" WHERE "name" = ?1 -- bindings: ["Jupiter"]
```

The delete builder is also an `SQLPredicateBuilder`.

## Raw

The `raw(_:)` method allows passing custom SQL query strings, with support for parameterized bindings and correctly-quoted identifiers:

```swift
let planets = try await db.raw("SELECT \(SQLLiteral.all) FROM \(ident: table) WHERE \(ident: name) = \(bind: "planet")")
    .all()
```

This code generates the following SQL when used with the PostgreSQL driver:

```PLpgsql
SELECT * FROM "planets" WHERE "name" = $1 -- bindings: ["planet"]
```

The `\(bind:)` interpolation should be used for any user input to avoid SQL injection. The `\(ident:)` interpolation is used to safely specify identifiers such as table and column names.

##### ⚠️ **Important!**⚠️

Always prefer a structured query (i.e. one for which a builder or expression type exists) over raw queries. Consider writing your own `SQLExpression`s, and even your own `SQLQueryBuilder`s, rather than using raw queries, and don't hesitate to [open an issue](https://github.com/vapor/sql-kit/issues/new) to ask for additional feature support.

-->

# Basic Usage

Getting started with SQLKit

## Overview

_Query builders_ make up the primary API surface for SQLKit. A query builder is an object associated with a database used to build and execute a query, as shown in the following example:

```swift
/// A simple data model 
struct Planet: Codable {
    let id: Int
    let name: String
}

/// Database connection objects are vended by SQLKit drivers; the details
/// differ from driver to driver.
let database: any SQLDatabase = ...

/// This value can come from user input, such a query parameter.
let planetName: String = ...

let planets = try await database
    .select()
    .columns("id", "name")
    .from("planets")
    .where("name", .equal, planetName)
    .all(decoding: Planet.self)
```

The actual query executed by this example depends on the driver used to get the database object. The [PostgreSQL driver](https://github.com/vapor/postgres-kit) generates this query:

```PLpgsql
SELECT "id", "name" FROM "planets" WHERE "name" = $1
```

... and the [SQLite driver](https://github.com/vapor/sqlite-kit)'s output is very similar:

```sql
SELECT "id", "name" FROM "planets" WHERE "name" = ?1
```

... whereas the [MySQL driver](https://github.com/vapor/mysql-kit)'s output is less so:

```mysql
SELECT `id`, `name` FROM `planets` WHERE `name` = ?
```  

## Databases, Expressions, and Builders

Instances of ``SQLDatabase`` are capable of executing arbitrary ``SQLExpression``s:

```swift
let db: any SQLDatabase = // obtain a database from an SQLKit driver
let query = db
    .select()
    .column(SQLLiteral.string("a"))
    .query 

try await db.execute(
    sql: query,
    onRow: { (row: any SQLRow) in
        // ...
    }
)
```

The ``SQLExpression`` protocol provides a common interface for transforming an arbitrary set of syntactical building blocks into a string of SQL code. A comprehensive set of SQL building blocks for SQL syntax is provided, along with numerous expressions representing composed clauses, and even complete SQL queries. Expressions are serialized to a combination of a raw string of SQL text and an array of zero or more bound parameter values.

Here is an example of constructing a `SELECT` query using the ``SQLSelect`` expression type, along with several syntactical building blocks, directly:

```swift
var select = SQLSelect()

select.columns = [
    SQLColumn("column1"),
    SQLColumn("column2", table: "table2"),
]
select.tables = [
    SQLIdentifier("table1")
]
select.joins = [
    SQLJoin(
        method: SQLJoinMethod.inner,
        table: SQLIdentifier("table2"),
        expression: SQLBinaryExpression(
            SQLColumn("column1", table: "table1"),
            .equal,
            SQLColumn("column2", table: "table2")
        )
    )
]
select.predicate = SQLBinaryExpression(
    SQLBinaryExpression(SQLColumn("column1"), .equal, SQLBind("value")),
    .and,
    SQLBinaryExpression(SQLColumn("column2"), .is, SQLLiteral.null)
)
```

When serialized against a database using the PostgreSQL dialect, the resulting query looks like this (whitespace has been added for readability):

```PLpgsql
SELECT "column1", "table2"."column2"
FROM "table1"
INNER JOIN "table2" ON "table1"."column1" = "table2"."column2"
WHERE "column1" = $1 AND "column2" IS NULL
```

Of course, this is an _awful_ lot of code to achieve such a relatively straightforward result, which is why SQLKit provides query builders.

### Rows

For query builders that support returning results (e.g. any builder conforming to the ``SQLQueryFetcher`` protocol), there are additional methods for handling the database output:

- `all()`: Returns an array of rows.
- `first()`: Returns an optional row.
- `run(_:)`: Accepts a closure that handles rows as they are returned.

Each of these methods provides one or more ``SQLRow``s. ``SQLRow`` is a protocol providing methods for accessing column values:

```swift
let row: any SQLRow
let name = try row.decode(column: "name", as: String.self)
print(name) // String
```

### Codable

``SQLRow`` also supports decoding `Codable` models directly:

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

The ``SQLDatabase/select()`` method creates a `SELECT` query builder:

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

The select builder includes the following methods (most of which have numerous variations):

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

The ``SQLDatabase/insert(into:)-67oqt`` and ``SQLDatabase/insert(into:)-5n3gh`` methods create an `INSERT` query builder:

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

The insert builder also has methods for encoding `Codable` types as sets of values:

```swift
struct Galaxy: Codable {
    var name: String
}

try builder.model(Galaxy(name: "Milky Way"))
```

This code generates the same SQL as would `builder.columns("name").values("Milky Way")`.

## Update

The ``SQLDatabase/update(_:)-2tf1c`` and ``SQLDatabase/update(_:)-80964`` methods create an `UPDATE` query builder:

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

The update builder supports the same `where()` and `orWhere()` methods as the select builder, via the ``SQLPredicateBuilder`` protocol.

## Delete

The ``SQLDatabase/delete(from:)-3tx4f`` and ``SQLDatabase/delete(from:)-4bqlu`` methods create a `DELETE` query builder:

```swift
try await db.delete(from: "planets")
    .where("name", .equal, "Jupiter")
    .run()
```

This code generates the following SQL when used with the SQLite driver:

```sql
DELETE FROM "planets" WHERE "name" = ?1 -- bindings: ["Jupiter"]
```

The delete builder also conforms to ``SQLPredicateBuilder``.

## Raw

The ``SQLDatabase/raw(_:)`` method allows passing custom SQL query strings, with support for parameterized bindings and correctly-quoted identifiers:

```swift
let planets = try await db.raw("SELECT \(SQLLiteral.all) FROM \(ident: table) WHERE \(ident: name) = \(bind: "planet")")
    .all()
```

This code generates the following SQL when used with the PostgreSQL driver:

```PLpgsql
SELECT * FROM "planets" WHERE "name" = $1 -- bindings: ["planet"]
```

The ``SQLQueryString/appendInterpolation(bind:)`` interpolation should be used for any user input to avoid SQL injection. The ``SQLQueryString/appendInterpolation(ident:)`` interpolation is used to safely specify identifiers such as table and column names.

> Important: Always prefer a structured query (i.e. one for which a builder or expression type exists) over raw queries. Consider writing your own ``SQLExpression``s, and even your own ``SQLQueryBuilder``s, rather than using raw queries, and don't hesitate to [open an issue](https://github.com/vapor/sql-kit/issues/new) to ask for additional feature support.

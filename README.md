<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/58835528-3523e400-8624-11e9-8128-4925c7c9cf08.png" height="64" alt="SQLKit">
    <br>
    <br>
    <a href="https://docs.vapor.codes/4.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="https://discord.gg/vapor">
        <img src="https://img.shields.io/discord/431917998102675485.svg" alt="Team Chat">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://github.com/vapor/sql-kit/actions/workflows/test.yml">
        <img src="https://github.com/vapor/sql-kit/actions/workflows/test.yml/badge.svg?event=push" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-5.6-brightgreen.svg" alt="Swift 5.6">
    </a>
</p>

<br>

Build SQL queries in Swift. Extensible, protocol-based design that supports DQL, DML, and DDL.

## Using SQLKit

Use standard SwiftPM syntax to include SQLKit as a dependency in your `Package.swift` file.

```swift
.package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0")
```

SQLKit 3.x requires [SwiftNIO](https://github.com/apple/swift-nio) 2.x or later. Previous major versions are no longer supported.

### Supported Platforms

SQLKit supports the following platforms:

- Ubuntu 20.04+
- macOS 10.15+
- iOS 13+
- tvOS 13+ and watchOS 7+ (experimental)

## Overview

SQLKit is an API for building and serializing SQL queries in Swift. SQLKit attempts to abstract away SQL dialect inconsistencies where possible allowing you to write queries that can run on multiple database flavors. Where abstraction is not possible, SQLKit provides powerful APIs for custom or dynamic behavior.

### Supported Databases

These database packages are drivers for SQLKit:

- [vapor/postgres-kit](https://github.com/vapor/postgres-kit): PostgreSQL
- [vapor/mysql-kit](https://github.com/vapor/mysql-kit): MySQL and MariaDB
- [vapor/sqlite-kit](https://github.com/vapor/sqlite-kit): SQLite

### Configuration

SQLKit does not deal with creating or managing database connections itself. This package is focused entirely around building and serializing SQL queries. To connect to your SQL database, refer to your specific database package's documentation. Once you are connected to your database and have an instance of `SQLDatabase`, you are ready to continue.

### Database

Instances of `SQLDatabase` are capable of serializing and executing `SQLExpression`.

```swift
let db: any SQLDatabase = ...
db.execute(sql: any SQLExpression, onRow: (any SQLRow) -> ())
```

`SQLExpression` is a protocol that represents a SQL query string and optional bind values. It can represent an entire SQL query or just a fragment.

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

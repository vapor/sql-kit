<img src="https://user-images.githubusercontent.com/1342803/58835528-3523e400-8624-11e9-8128-4925c7c9cf08.png" height="64" alt="SQLKit">
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
<a href="https://github.com/vapor/sql-kit/actions">
    <img src="https://github.com/vapor/sql-kit/workflows/test/badge.svg" alt="Continuous Integration">
</a>
<a href="https://swift.org">
    <img src="http://img.shields.io/badge/swift-5.2-brightgreen.svg" alt="Swift 5.2">
</a>
<br>
<br>

Build SQL queries in Swift. Extensible, protocol-based design that supports DQL, DML, and DDL.

### Major Releases

The table below shows a list of SQLKit major releases alongside their compatible NIO and Swift versions. 

|Version|NIO|Swift|SPM|
|-|-|-|-|
|3.0|2.0+|5.2+|`from: "3.0.0"`|
|2.0|1.0+|4.0+|`from: "2.0.0"`|
|1.0|n/a|4.0+|`from: "1.0.0"`|

Use the SPM string to easily include the dependendency in your `Package.swift` file.

```swift
.package(url: "https://github.com/vapor/sql-kit.git", from: ...)
```

### Supported Platforms

PostgresNIO supports the following platforms:

- Ubuntu 16.04+
- macOS 10.15+

## Overview

SQLKit is an API for building and serializing SQL queries in Swift. SQLKit attempts to abstract away SQL dialect inconsistencies where possible allowing you to write queries that can run on multiple database flavors. Where abstraction is not possible, SQLKit provides powerful APIs for custom or dynamic behavior. 

### Supported Databases

These database packages are built on SQLKit:

- [vapor/postgres-kit](https://github.com/vapor/postgres-kit): PostgreSQL
- [vapor/mysql-kit](https://github.com/vapor/mysql-kit): MySQL and MariaDB
- [vapor/sqlite-kit](https://github.com/vapor/sqlite-kit): SQLite

### Configuration

SQLKit does not deal with creating or managing database connections itself. This package is focused entirely around building and serializing SQL queries. To connect to your SQL database, refer to your specific database package's documentation. Once you are connected to your database and have an instance of `SQLDatabase`, you are ready to continue.

### Database

Instances of `SQLDatabase` are capable of serializing and executing `SQLExpression`. 

```swift
let db: SQLDatabase = ...
db.execute(sql: SQLExpression, onRow: (SQLRow) -> ())
```

`SQLExpression` is a protocol that represents a SQL query string and optional bind values. It can represent an entire SQL query or just a fragment. 

SQLKit provides `SQLExpression`s for common queries like `SELECT`, `UPDATE`, `INSERT`, `DELETE`, `CREATE TABLE`, and more. 

```swift
var select = SQLSelect()
select.columns = [...]
select.tables = [...]
select.predicate = ...
```

`SQLDatabase` can be used to create fluent query builders for most of these query types. 

```swift
let planets = try db.select()
    .column("*")
    .from("planets")
    .where("name", .equal, "Earth")
    .all().wait()
```

You can execute a query builder by calling `run()`. 

### Rows

For query builders that support returning results, like `select()`, there are additional methods for handling the database output.

- `all()`: Returns an array of rows.
- `first()`: Returns an optional row.
- `run(_:)`: Accepts a closure that handles rows as they are returned.

Each of these methods returns `SQLRow` which has methods for access column values.

```swift
let row: SQLRow
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
let planets = try db.select()
    ...
    .all(decoding: Planet.self).wait()
```

## Select

The `select()` method creates a `SELECT` query builder. 

```swift
let planets = try db.select()
    .columns("id", "name")
    .from("planets")
    .where("name", .equal, "Earth")
    .all().wait()
```

This code would generate the following SQL:

```sql
SELECT id, name FROM planets WHERE name = ?
```

Notice that `Encodable` values are automatically bound as parameters instead of being serialized directly to the query. 

The select builder has the following methods.

- `columns`
- `from`
- `where` (`orWhere`)
- `limit`
- `offset`
- `groupBy`
- `having` (`orHaving`)
- `distinct`
- `for` (`lockingClause`)
- `join`

By default, query components like `where` will be joined by `AND`. Methods prefixed with `or` exist for joining by `OR`. 

```swift
builder.where("name", .equal, "Earth").orWhere("name", .equal, "Mars")
```

This code would generate the following SQL:

```sql
name = ? OR name = ?
```

`where` also supports creating grouped clauses. 

```swift
builder.where("name", .notEqual, SQLLiteral.null).where {
    $0.where("name", .equal, SQLBind("Milky Way"))
        .orWhere("name", .equal, SQLBind("Andromeda"))
}
```

This code generates the following SQL:

```sql
name != NULL AND (name == ? OR name == ?)
```

## Insert

The `insert(into:)` method creates an `INSERT` query builder. 

```swift
try db.insert(into: "galaxies")
    .columns("id", "name")
    .values(SQLLiteral.default, SQLBind("Milky Way"))
    .values(SQLLiteral.default, SQLBind("Andromeda"))
    .run().wait()
```

This code would generate the following SQL:

```sql
INSERT INTO galaxies (id, name) VALUES (DEFAULT, ?) (DEFAULT, ?)
```

The insert builder also has a method for encoding a `Codable` type as a set of values.

```swift
struct Galaxy: Codable {
    var name: String
}

try builder.model(Galaxy(name: "Milky Way"))
```

## Update

The `update(_:)` method creates an `UPDATE` query builder.

```swift
try db.update("planets")
    .where("name", .equal, "Jpuiter")
    .set("name", to: "Jupiter")
    .run().wait()
```

This code generates the following SQL:

```sql
UPDATE planets SET name = ? WHERE name = ?
```

The update builder supports the same `where` and `orWhere` methods as the select builder.

## Delete

The `delete(from:)` method creates a `DELETE` query builder.

```swift
try db.delete(from: "planets")
    .where("name", .equal, "Jupiter")
    .run().wait()
```

This code generates the following SQL:

```sql
DELETE FROM planets WHERE name = ?
```

The delete builder supports the same `where` and `orWhere` methods as the select builder.

## Raw

The `raw(_:)` method allows for passing custom SQL query strings with support for parameterized binds.

```swift
let table = "planets"
let planets = try db.raw("SELECT * FROM \(table) WHERE name = \(bind: planet)")
    .all().wait()
```

This code generates the following SQL:

```sql
SELECT * FROM planets WHERE name = ?
```

The `\(bind:)` interpolation should be used for any user input to avoid SQL injection.

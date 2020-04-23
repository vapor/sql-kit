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

The table below shows a list of PostgresNIO major releases alongside their compatible NIO and Swift versions. 

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
let planets = try db.select().column("*")
    .from("planets")
    .where("name", .equal, "Earth")
    .all().wait()
```

You can execute a query builder by calling `run()`. 

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

...

# ``SQLKit``

SQLKit is a library for building SQL queries in Swift. It is designed to be database agnostic and officially supports PostgreSQL, MySQL, and SQLite.

SQLKit queries provide type-safety and mapping to Swift types to make it easy to use SQL from Swift. An example query looks like:

```swift
try await db.select().column(table: "planets", column: "*")
    .from("planets")
    .where("name", .equal, SQLBind("Earth"))
    .run()
```

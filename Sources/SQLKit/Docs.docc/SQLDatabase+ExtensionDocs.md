# ``SQLKit/SQLDatabase``

## Topics

### Properties

- ``SQLDatabase/logger``
- ``SQLDatabase/eventLoop``
- ``SQLDatabase/version``
- ``SQLDatabase/dialect``
- ``SQLDatabase/queryLogLevel``

### Query interface

- ``SQLDatabase/execute(sql:_:)-4eg19``
- ``SQLDatabase/withSession(_:)-9b68j``

### DML queries

- ``SQLDatabase/delete(from:)-(String)``
- ``SQLDatabase/delete(from:)-(SQLExpression)``
- ``SQLDatabase/insert(into:)-(String)``
- ``SQLDatabase/insert(into:)-(SQLExpression)``
- ``SQLDatabase/select()``
- ``SQLDatabase/union(_:)``
- ``SQLDatabase/update(_:)-(String)``
- ``SQLDatabase/update(_:)-(SQLExpression)``

### DDL queries

- ``SQLDatabase/alter(table:)-(String)``
- ``SQLDatabase/alter(table:)-(SQLIdentifier)``
- ``SQLDatabase/alter(table:)-(SQLExpression)``
- ``SQLDatabase/create(table:)-(String)``
- ``SQLDatabase/create(table:)-(SQLExpression)``
- ``SQLDatabase/drop(table:)-(String)``
- ``SQLDatabase/drop(table:)-(SQLExpression)``

- ``SQLDatabase/alter(enum:)-(String)``
- ``SQLDatabase/alter(enum:)-(SQLExpression)``
- ``SQLDatabase/create(enum:)-(String)``
- ``SQLDatabase/create(enum:)-(SQLExpression)``
- ``SQLDatabase/drop(enum:)-(String)``
- ``SQLDatabase/drop(enum:)-(SQLExpression)``

- ``SQLDatabase/create(index:)-(String)``
- ``SQLDatabase/create(index:)-(SQLExpression)``
- ``SQLDatabase/drop(index:)-(String)``
- ``SQLDatabase/drop(index:)-(SQLExpression)``

- ``SQLDatabase/create(trigger:table:when:event:)-(String,_,_,_)``
- ``SQLDatabase/create(trigger:table:when:event:)-(SQLExpression,_,_,_)``
- ``SQLDatabase/drop(trigger:)-(String)``
- ``SQLDatabase/drop(trigger:)-(SQLExpression)``

### Raw queries

- ``SQLDatabase/raw(_:)``
- ``SQLDatabase/serialize(_:)``

### Logging

- ``SQLDatabase/logging(to:)``

### Legacy query interface

- ``SQLDatabase/execute(sql:_:)->_``

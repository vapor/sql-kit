# ``SQLKit/SQLDatabase``

The core of an SQLKit driver. This common interface is the access point of both SQLKit itself and
SQLKit clients to all of the information and behaviors necessary to provide and leverage the
package's functionality.

## Topics

### Properties

- ``SQLDatabase/logger``
- ``SQLDatabase/eventLoop``
- ``SQLDatabase/version``
- ``SQLDatabase/dialect``
- ``SQLDatabase/queryLogLevel``

### Concurrency interfaces

- ``SQLDatabase/execute(sql:_:)-7trgm``

### EventLoopFuture interfaces

- ``SQLDatabase/execute(sql:_:)-90wi9``

### DML queries

- ``SQLDatabase/delete(from:)-53p45``
- ``SQLDatabase/delete(from:)-9o76g``
- ``SQLDatabase/insert(into:)-31xhl``
- ``SQLDatabase/insert(into:)-7kcf9``
- ``SQLDatabase/select()``
- ``SQLDatabase/union(_:)``
- ``SQLDatabase/update(_:)-42k7h``
- ``SQLDatabase/update(_:)-2fl0d``

### DDL queries

- ``SQLDatabase/alter(table:)-7ht30``
- ``SQLDatabase/alter(table:)-68pbr``
- ``SQLDatabase/create(table:)-8cj1n``
- ``SQLDatabase/create(table:)-2dnjh``
- ``SQLDatabase/drop(table:)-2aa1b``
- ``SQLDatabase/drop(table:)-77lrz``

- ``SQLDatabase/alter(enum:)-95006``
- ``SQLDatabase/alter(enum:)-7l6tg``
- ``SQLDatabase/create(enum:)-65h8k``
- ``SQLDatabase/create(enum:)-2t6o5``
- ``SQLDatabase/drop(enum:)-5726u``
- ``SQLDatabase/drop(enum:)-6yxi7``

- ``SQLDatabase/create(index:)-9vfh0``
- ``SQLDatabase/create(index:)-40exk``
- ``SQLDatabase/drop(index:)-6vrgx``
- ``SQLDatabase/drop(index:)-5lfmu``

- ``SQLDatabase/create(trigger:table:when:event:)-7gpbq``
- ``SQLDatabase/create(trigger:table:when:event:)-1w9w``
- ``SQLDatabase/drop(trigger:)-9wf4i``
- ``SQLDatabase/drop(trigger:)-2qpz``

### Raw queries

- ``SQLDatabase/raw(_:)``
- ``SQLDatabase/serialize(_:)``

### Logging

- ``SQLDatabase/logging(to:)``

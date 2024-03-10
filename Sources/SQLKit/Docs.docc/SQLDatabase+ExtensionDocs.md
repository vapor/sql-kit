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

### Query interface

- ``SQLDatabase/execute(sql:_:)-7trgm``

### DML queries

- ``SQLDatabase/delete(from:)-3tx4f``
- ``SQLDatabase/delete(from:)-4bqlu``
- ``SQLDatabase/insert(into:)-67oqt``
- ``SQLDatabase/insert(into:)-5n3gh``
- ``SQLDatabase/select()``
- ``SQLDatabase/union(_:)``
- ``SQLDatabase/update(_:)-2tf1c``
- ``SQLDatabase/update(_:)-80964``

### DDL queries

- ``SQLDatabase/alter(table:)-42uao``
- ``SQLDatabase/alter(table:)-68pbr``
- ``SQLDatabase/create(table:)-czz4``
- ``SQLDatabase/create(table:)-2wdmn``
- ``SQLDatabase/drop(table:)-938qt``
- ``SQLDatabase/drop(table:)-7k2ai``

- ``SQLDatabase/alter(enum:)-66oin``
- ``SQLDatabase/alter(enum:)-7nb5b``
- ``SQLDatabase/create(enum:)-81hl4``
- ``SQLDatabase/create(enum:)-70oeh``
- ``SQLDatabase/drop(enum:)-5leu1``
- ``SQLDatabase/drop(enum:)-3jgv``

- ``SQLDatabase/create(index:)-7yh28``
- ``SQLDatabase/create(index:)-1iuey``
- ``SQLDatabase/drop(index:)-62i2j``
- ``SQLDatabase/drop(index:)-19tfk``

- ``SQLDatabase/create(trigger:table:when:event:)-6ntdo``
- ``SQLDatabase/create(trigger:table:when:event:)-9upcb``
- ``SQLDatabase/drop(trigger:)-53mq6``
- ``SQLDatabase/drop(trigger:)-5sfa8``

### Raw queries

- ``SQLDatabase/raw(_:)``
- ``SQLDatabase/serialize(_:)``

### Logging

- ``SQLDatabase/logging(to:)``

### Legacy query interface

- ``SQLDatabase/execute(sql:_:)-90wi9``

# ``SQLKit/SQLQueryFetcher``

## Topics

### Getting Rows

- ``SQLQueryFetcher/run(_:)->()``
- ``SQLQueryFetcher/run(decoding:_:)->()``
- ``SQLQueryFetcher/run(decoding:prefix:keyDecodingStrategy:userInfo:_:)->()``
- ``SQLQueryFetcher/run(decoding:with:_:)->()``

### Getting All Rows

- ``SQLQueryFetcher/all()->[SQLRow]``
- ``SQLQueryFetcher/all(decoding:)->[D]``
- ``SQLQueryFetcher/all(decoding:prefix:keyDecodingStrategy:userInfo:)->[D]``
- ``SQLQueryFetcher/all(decoding:with:)->[D]``
- ``SQLQueryFetcher/all(decodingColumn:as:)->[D]``

### Getting One Row

- ``SQLQueryFetcher/first()->SQLRow?``
- ``SQLQueryFetcher/first(decoding:)->D?``
- ``SQLQueryFetcher/first(decoding:prefix:keyDecodingStrategy:userInfo:)->D?``
- ``SQLQueryFetcher/first(decoding:with:)->D?``
- ``SQLQueryFetcher/first(decodingColumn:as:)->D?``

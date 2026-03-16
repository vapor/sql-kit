# ``SQLKit/SQLQueryFetcher``

## Topics

### Getting Rows

- ``SQLQueryFetcher/run(_:)->()``
- ``SQLQueryFetcher/run(decoding:_:)->()``
- ``SQLQueryFetcher/run(decoding:prefix:keyDecodingStrategy:userInfo:_:)->()``
- ``SQLQueryFetcher/run(decoding:with:_:)->()``

### Getting All Rows

- ``SQLQueryFetcher/all(decoding:with:)->[D]``
- ``SQLQueryFetcher/all(decoding:)->[D]``
- ``SQLQueryFetcher/all(decoding:prefix:keyDecodingStrategy:userInfo:)->[D]``
- ``SQLQueryFetcher/all(decoding:with:)->[D]``
- ``SQLQueryFetcher/all(decodingColumn:as:)->[D]``

### Getting One Row

- ``SQLQueryFetcher/first()->EventLoopFuture<(SQLRow)?>``
- ``SQLQueryFetcher/first(decoding:)->D?``
- ``SQLQueryFetcher/first(decoding:prefix:keyDecodingStrategy:userInfo:)->D?``
- ``SQLQueryFetcher/first(decoding:with:)->D?``
- ``SQLQueryFetcher/first(decodingColumn:as:)->D?``

### Legacy `EventLoopFuture` Interfaces

- ``SQLQueryFetcher/run(_:)->_``
- ``SQLQueryFetcher/run(decoding:_:)->_``
- ``SQLQueryFetcher/run(decoding:prefix:keyDecodingStrategy:userInfo:_:)->_``
- ``SQLQueryFetcher/run(decoding:with:_:)->_``
- ``SQLQueryFetcher/all()->EventLoopFuture<[SQLRow]>``
- ``SQLQueryFetcher/all(decoding:)->EventLoopFuture<[D]>``
- ``SQLQueryFetcher/all(decoding:prefix:keyDecodingStrategy:userInfo:)->EventLoopFuture<[D]>``
- ``SQLQueryFetcher/all(decoding:with:)->EventLoopFuture<[D]>``
- ``SQLQueryFetcher/all(decodingColumn:as:)->EventLoopFuture<[D]>``
- ``SQLQueryFetcher/first()->EventLoopFuture<(SQLRow)?>``
- ``SQLQueryFetcher/first(decoding:)->EventLoopFuture<D?>``
- ``SQLQueryFetcher/first(decoding:prefix:keyDecodingStrategy:userInfo:)->EventLoopFuture<D?>``
- ``SQLQueryFetcher/first(decoding:with:)->EventLoopFuture<D?>``
- ``SQLQueryFetcher/first(decodingColumn:as:)->EventLoopFuture<D?>``

// MARK: KeyPath to Value

public func == <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
    where T: SQLTable, V: Encodable, E: SQLExpression
{
    return .keyPath(lhs) == .bind(rhs)
}

public func != <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
    where T: SQLTable, V: Encodable, E: SQLExpression
{
    return .keyPath(lhs) != .bind(rhs)
}

public func < <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
    where T: SQLTable, V: Encodable, E: SQLExpression
{
    return .keyPath(lhs) < .bind(rhs)
}

public func > <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
    where T: SQLTable, V: Encodable, E: SQLExpression
{
    return .keyPath(lhs) > .bind(rhs)
}

public func <= <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
    where T: SQLTable, V: Encodable, E: SQLExpression
{
    return .keyPath(lhs) <= .bind(rhs)
}

public func >= <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
    where T: SQLTable, V: Encodable, E: SQLExpression
{
    return .keyPath(lhs) >= .bind(rhs)
}

// MARK: KeyPath to KeyPath


public func == <A,B,C,D,E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
{
    return .keyPath(lhs) == .keyPath(rhs)
}

public func != <A,B,C,D,E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
{
    return .keyPath(lhs) != .keyPath(rhs)
}

public func > <A,B,C,D,E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
{
    return .keyPath(lhs) > .keyPath(rhs)
}

public func < <A,B,C,D,E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
{
    return .keyPath(lhs) < .keyPath(rhs)
}

public func <= <A,B,C,D,E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
{
    return .keyPath(lhs) <= .keyPath(rhs)
}

public func >= <A,B,C,D,E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
{
    return .keyPath(lhs) >= .keyPath(rhs)
}

// MARK: Expression to Expression

public func == <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .equal, rhs)
}

public func != <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .notEqual, rhs)
}

public func < <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .lessThan, rhs)
}

public func > <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .greaterThan, rhs)
}

public func <= <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .lessThanOrEqual, rhs)
}

public func >= <E>(_ lhs: E, _ rhs: E) -> E where E: SQLExpression {
    return E.binary(lhs, .greaterThanOrEqual, rhs)
}

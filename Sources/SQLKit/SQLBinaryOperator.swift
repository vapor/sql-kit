/// SQL binary expression operators, i.e., `==`, `!=`, `AND`, `+`, etc.
///
/// See `SQLExpression`.
public protocol SQLBinaryOperator: SQLSerializable {
    /// `=` or `==`
    static var equal: Self { get }
    
    /// `!=` or `<>`
    static var notEqual: Self { get }
    
    /// `>`
    static var greaterThan: Self { get }
    
    /// `<`
    static var lessThan: Self { get }
    
    /// `>=`
    static var greaterThanOrEqual: Self { get }
    
    /// `<=`
    static var lessThanOrEqual: Self { get }
    
    /// `LIKE`
    static var like: Self { get }
    
    /// `NOT LIKE`
    static var notLike: Self { get }
    
    /// `IN`
    static var `in`: Self { get }
    
    /// `NOT IN`
    static var `notIn`: Self { get }
    
    /// `AND`
    static var and: Self { get }
    
    /// `OR`
    static var or: Self { get }
    
    /// `||`
    static var concatenate: Self { get }
    
    /// `*`
    static var multiply: Self { get }
    
    /// `/`
    static var divide: Self { get }
    
    /// `%`
    static var modulo: Self { get }
    
    /// `+`
    static var add: Self { get }
    
    /// `-`
    static var subtract: Self { get }
}


//// MARK: Operator
//
///// See `SQLBinaryOperator`.
//public func == <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
//    where T: SQLTable, V: Encodable, E: SQLExpression
//{
//    if rhs.isNil {
//        return E.binary(.column(.keyPath(lhs)), .equal, .literal(.null))
//    }
//    return E.binary(.column(.keyPath(lhs)), .equal, .bind(.encodable(rhs)))
//}
//
///// See `SQLBinaryOperator`.
//public func != <T,V,E>(_ lhs: KeyPath<T, V>, _ rhs: V) -> E
//    where T: SQLTable, V: Encodable, E: SQLExpression
//{
//    if rhs.isNil {
//        return E.binary(.column(.keyPath(lhs)), .notEqual, .literal(.null))
//    }
//    return E.binary(.column(.keyPath(lhs)), .notEqual, .bind(.encodable(rhs)))
//}
//
///// See `SQLBinaryOperator`.
//public func == <A, B, C, D, E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
//    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
//{
//    return E.binary(.column(.keyPath(lhs)), .equal, .column(.keyPath(rhs)))
//}
//
///// See `SQLBinaryOperator`.
//public func != <A, B, C, D, E>(_ lhs: KeyPath<A, B>, _ rhs: KeyPath<C, D>) -> E
//    where A: SQLTable, B: Encodable, C: SQLTable, D: Encodable, E: SQLExpression
//{
//    return E.binary(.column(.keyPath(lhs)), .notEqual, .column(.keyPath(rhs)))
//}
//
//internal extension Encodable {
//    /// Returns `true` if this `Encodable` is `nil`.
//    var isNil: Bool {
//        guard let optional = self as? AnyOptionalType, optional.anyWrapped == nil else {
//            return false
//        }
//        return true
//    }
//}

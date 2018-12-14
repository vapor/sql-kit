/// SQL binary expression operators, i.e., `==`, `!=`, `AND`, `+`, etc.
///
/// See `SQLExpression`.
public protocol SQLBinaryOperator: SQLSerializable, Equatable, ExpressibleByStringLiteral where
    StringLiteralType == String
{
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

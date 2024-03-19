/// An error from a SQL query or database operation.
/// Constains an additional property detailing what type of SQL error has occurred.
///
/// This protocol is deprecated; it has never been used by SQLKit or any of its drivers or dependents,
/// and serves no useful purpose.
@available(*, deprecated, message: "SQLKit does not support or use this protocol; it will be removed in a future version.")
public protocol SQLError: Error {
    /// SQL-specific error type.
    var sqlErrorType: SQLErrorType { get }
}

/// Types of SQL errors.
///
/// This type is deprecated; it has never been used by SQLKit or any of its drivers or dependents,
/// and serves no useful purpose.
@available(*, deprecated, message: "SQLKit does not support or use this type; it will be removed in a future version.")
public struct SQLErrorType: Equatable, Sendable {
    /// An IO error occured during database query.
    public static var io: SQLErrorType { .init(code: .io) }
    
    /// A constraint violation occurred during database query.
    public static var constraint: SQLErrorType { .init(code: .constraint) }
    
    /// Insufficient permissions to perform database query.
    public static var permission: SQLErrorType { .init(code: .permission) }
    
    /// Invalid syntax encountered in database query.
    public static var syntax: SQLErrorType { .init(code: .syntax) }
    
    /// An unknown error occured while performing database query.
    public static var unknown: SQLErrorType { .init(code: .unknown) }
    
    // MARK: Private
    
    private enum Code: Sendable {
        case io
        case constraint
        case permission
        case syntax
        case unknown
    }
    
    private let code: Code
}

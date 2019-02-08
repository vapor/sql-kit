/// An error from a SQL query or database operation.
/// Constains an additional property detailing what type of SQL error has occurred.
public protocol SQLError: Error {
    /// SQL-specific error type.
    var sqlErrorType: SQLErrorType { get }
}

/// Types of SQL errors.
public struct SQLErrorType: Equatable {
    /// An IO error occured during database query.
    public static var io: SQLErrorType { return .init(code: .io) }
    
    /// A constraint violation occurred during database query.
    public static var constraint: SQLErrorType { return .init(code: .constraint) }
    
    /// Insufficient permissions to perform database query.
    public static var permission: SQLErrorType { return .init(code: .permission) }
    
    /// Invalid syntax encountered in database query.
    public static var syntax: SQLErrorType { return .init(code: .syntax) }
    
    /// An unknown error occured while performing database query.
    public static var unknown: SQLErrorType { return .init(code: .unknown) }
    
    // MARK: Private
    
    private enum Code {
        case io
        case constraint
        case permission
        case syntax
        case unknown
    }
    
    private let code: Code
}

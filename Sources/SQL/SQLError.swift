public protocol SQLError: Debuggable {
  var type: SQLErrorType {get}
  var reason: String {get}
  var sourceLocation: SourceLocation? {get}
  var stackTrace: [String] {get}
  var identifier: String {get}
}

extension SQLError {
  public var identifier: String {
    return "SQLError(\(self.type.description))"
  }
}

public enum SQLErrorType: CustomStringConvertible {
  /// Generic error case, for errors that does not match
  /// any other category
  case unknown
  /// Internal error of the DB server
  case intern
  /// The database cannot be read (the file is not a database,
  /// or the database is corrupted
  case invalidDatabase
  /// Permission to perform the operation was denied
  /// by the server
  case permission
  /// Operation was aborted
  case abort
  /// Another operation performed on another connection is
  /// conflicting with the requested operation
  case busy
  /// The operation alters an entry that has been locked by
  /// another connection
  case locked
  /// The database server could not allocate memory
  case memory
  /// The database is readonly
  case readOnly
  /// The database server could not read or write to disk,
  /// or to open a file
  case ioError
  /// A constraint failed to be applied
  case constraint
  /// A data type does not match with the expected one, or is too
  /// large for its container
  case invalidData
  /// A table of column name was not recognized
  case unknownEntity
  /// The SQL request is invalid
  case invalidRequest
  
  public var description: String {
    switch self {
    case .unknown:
      return "Unknown error"
    case .intern:
      return "Internal error"
    case .permission:
      return "Permission denied"
    case .abort:
      return "Operation aborted"
    case .busy:
      return "Database is busy"
    case .locked:
      return "Trying to access locked resources"
    case .memory:
      return "Datbase could not allocate memory"
    case .readOnly:
      return "Database is read only"
    case .ioError:
      return "Storage error (database failed to read or write data to disk)"
    case .constraint:
      return "Constraint failed"
    case .invalidData:
      return "Type of data does not match expectation"
    case .unknownEntity:
      return "Unknwown entity"
    case .invalidDatabase:
      return "Cannot open database"
    case .invalidRequest:
      return "The SQL request is not valid"
    }
  }
}

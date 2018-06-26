public struct SQLError: Debuggable {
  public let type: SQLErrorType
  public var reason: String
  public var location: SourceLocation?
  public var stackTrace: [String]

  public var identifier: String {
    return "SQLError(\(self.type.description))"
  }

  init(type: SQLErrorType, reason: String, location: SourceLocation) {
    self.type = type
    self.reason = reason
    self.location = location
    self.stackTrace = SQLError.makeStackTrace()
  }
}

public enum SQLErrorType: CustomStringConvertible {
  /// Generic error case, for errors that does not match
  /// any other category
  case unknown
  /// Internal error of the DB server
  case intern
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
  case constraint(name: String)
  /// A data type does not match with the expected one
  case typeMismatch
  /// A table of column name was not recognized
  case unknownEntity(name: String)
  
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
      return "Database failed to read or write data to disk"
    case .constraint(let name):
      return "Constraint \(name) failed"
    case .typeMismatch:
      return "Type of data does not match expectation"
    case .unknownEntity(let name):
      return "Entity \(name) is not known"
    }
  }
}

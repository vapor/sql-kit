/// Represents a value's type in SQL.
///  
/// In practice it is not generally possible to list all of the data types supported by any given database, nor
/// to define a useful set of types with identical behaviors which are available across all databases, despite the
/// attempted influence of ANSI SQL. As such, this type primarily functions as a front end for
/// ``SQLDialect/customDataType(for:)-2firt``.
public enum SQLDataType: SQLExpression {
    /// Translates to `SMALLINT`, unless overriden by dialect. Usually an integer with at least 16-bit range.
    case smallint
    
    /// Translates to `INTEGER`, unless overridden by dialect. Usually an integer with at least 32-bit range.
    case int
    
    /// Translates to `BIGINT`, unless overridden by dialect. Almost always an integer with 64-bit range.
    case bigint
    
    /// Translates to `REAL`, unless overridden by dialect. Usually a decimal value with at least 32-bit precision.
    case real

    /// Translates to `TEXT`, unless overridden by dialect. Represents non-binary textual data (i.e. human-readable
    /// text potentially having an explicit character set and collation).
    case text
    
    /// Translates to `BLOB`, unless overridden by dialect. Represents binary non-textual data (i.e. an arbitrary
    /// byte string admitting of no particular format or representation).
    case blob
    
    /// Translates to `TIMESTAMP`, unless overridden by dialect. Represents a type suitable for storing the encoded
    /// value of a `Date` in a form which can be saved to and reloaded from the database without suffering skew caused
    /// by time zone calculations.
    ///
    /// > Note: Implemented as a static var rather than a new case for now because adding new cases to a public enum
    /// > is a source-breaking change.
    public static var timestamp: Self {
        .custom(SQLRaw("TIMESTAMP"))
    }
    
    /// Translates to the serialization of the given expression, unless overridden by dialect.
    case custom(any SQLExpression)

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        let sql: any SQLExpression
        
        if let dialect = serializer.dialect.customDataType(for: self) {
            sql = dialect
        } else {
            switch self {
            case .smallint:
                sql = SQLRaw("SMALLINT")
            case .int:
                sql = SQLRaw("INTEGER")
            case .bigint:
                sql = SQLRaw("BIGINT")
            case .text:
                sql = SQLRaw("TEXT")
            case .real:
                sql = SQLRaw("REAL")
            case .blob:
                sql = SQLRaw("BLOB")
            case .custom(let exp):
                sql = exp
            }
        }
        sql.serialize(to: &serializer)
    }
}

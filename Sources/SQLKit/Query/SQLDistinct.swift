/// Determines whether duplicate rows are included in `SQLSelect` queries.
public protocol SQLDistinct: SQLSerializable {
    /// `ALL`. Explicitly include all rows. This is the default.
    static var all: Self { get }
    
    /// `DISTINCT`. Exclude duplicate rows. 
    static var distinct: Self { get }
}

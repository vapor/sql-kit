/// Provides a protocol for reporting and comparing database version numbers.
///
/// SQLKit allows databases to report their versions. As any given database implementation
/// may have its own particular format for version numbers, the version is provided to
/// ``SQLDatabase`` as a value of a type conforming to this protocol, which defines an
/// interface for generically handling and comparing versions without needing to be aware
/// of implementation-specific details.
///
/// The most common uses for database version information are disabling or enabling feature
/// support in ``SQLDialect`` by version, tracking usage metrics by version, logging versions,
/// and recording versions for debugging.
///
/// Each type implementing ``SQLDatabaseReportedVersion`` is responsible for providing
/// definitions of equality and ordering semantics between versions which are meaningful
/// in the versioning scheme of the underlying database.
public protocol SQLDatabaseReportedVersion: Comparable, Sendable {
    /// The version represented as a `String`.
    var stringValue: String { get }
    
    /// Returns `true` if the provided version is the same version as `self`.
    ///
    /// Implementations of this method must check that the provided version and `self` represent the same type.
    /// If no implementation is provided, the default is to compare the `type(of:)` and `stringValue` of both
    /// versions for exact equality.
    ///
    /// > Warning: This method has been deprecated for callers, although it remains a protocol requirement for
    /// > drivers. Users should use the `==` operator instead.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against.
    /// - Returns: `true` if both versions are equal, `false` otherwise.
    func isEqual(to otherVersion: any SQLDatabaseReportedVersion) -> Bool
    
    /// Returns `true` if the provided version is newer than the version represented by `self`.
    ///
    /// Implementations of this method must check that the provided version and `self` represent the same type.
    /// If no implementation is provided, the default is to compare the `type(of:)` both versions for equality and
    /// the `stringValue` of both versions for lexocographic ordering.
    ///
    /// > Warning: This method has been deprecated for callers, although it remains a protocol requirement for
    /// > drivers. Users should use the `==` operator instead.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against.
    /// - Returns: `true` if `otherVersion` is equal to or greater than `self`, otherwise `false`.
    func isOlder(than otherVersion: any SQLDatabaseReportedVersion) -> Bool
}

extension SQLDatabaseReportedVersion {
    // See `Equatable.==(_:_:)`
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.isEqual(to: rhs)
    }
    
    // See `Equatable.!=(_:_:)`
    @inlinable
    public static func != (lhs: Self, rhs: Self) -> Bool {
        !lhs.isEqual(to: rhs)
    }
    
    // See `Comparable.<(_:_:)`
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.isOlder(than: rhs)
    }

    // See `Comparable.<=(_:_:)`
    @inlinable
    public static func <= (lhs: Self, rhs: Self) -> Bool {
        lhs == rhs || lhs < rhs
    }

    // See `Comparable.>(_:_:)`
    @inlinable
    public static func > (lhs: Self, rhs: Self) -> Bool {
        !(lhs <= rhs)
    }

    // See `Comparable.>=(_:_:)`
    @inlinable
    public static func >= (lhs: Self, rhs: Self) -> Bool {
        !(lhs < rhs)
    }
}

extension SQLDatabaseReportedVersion {
    /// Default implementation of ``isEqual(to:)-6ybn8``.
    @inlinable
    public func isEqual(to otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? Self).map { $0.stringValue == self.stringValue } ?? false
    }

    /// Default implementation of ``isOlder(than:)-1o58v``.
    @inlinable
    public func isOlder(than otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? Self).map { self.stringValue.lexicographicallyPrecedes($0.stringValue) } ?? false
    }
}

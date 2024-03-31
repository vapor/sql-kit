/// SQLKit allows databases to report their versions. As any given database implementation
/// may have its own particular format for version numbers, the version is provided to
/// ``SQLDatabase`` as a value of a type conforming to this protocol, which defines an
/// interface for generically handling and comparing versions without needing to be aware
/// of implementation-specific details.
///
/// The most common uses for database version information are disabling or enabling feature
/// suport in ``SQLDialect`` by version, tracking usage metrics by version, logging versions,
/// and recording versions for debugging.
///
/// Each type implementing ``SQLDatabaseReportedVersion`` is responsible for providing
/// defintions of equality and ordering semantics between versions which are meaningful
/// in the versioning scheme of the underlying database.
///
/// - Important: Because of limitations of ``SQLDatabase``'s design and the use of
///   existential values before Swift 5.7, this protocol does not require `Equatable`
///   or `Comparable` conformance, despite the obvious utility of both.
public protocol SQLDatabaseReportedVersion {
    /// The version represented as a `String`.
    var stringValue: String { get }
    
    /// Returns `true` if the provided version is the same version as `self`.
    ///
    /// Corresponds to ``Swift/Equatable/==(_:_:)``.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against. `type(of: self)` must be the same as `type(of: otherVersion)`.
    /// - Returns: `true` if both versions are equal, `false` otherwise.
    func isEqual(to otherVersion: SQLDatabaseReportedVersion) -> Bool
    
    /// Check whether the current version (i.e. `self`) is older than the one given.
    ///
    /// Corresponds to ``Swift/Comparable/<(_:_:)``.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against. `type(of: self)` must be the same as `type(of: otherVersion)`.
    /// - Returns: `true` if `otherVersion` is equal to or greater than `self`, otherwise `false`.
    func isOlder(than otherVersion: SQLDatabaseReportedVersion) -> Bool
}

extension SQLDatabaseReportedVersion {
    /// Check whether the current version (i.e. `self`) is older than or equal to the one given.
    ///
    /// Corresponds to ``Swift/Comparable/<=(_:_:)``.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against. `type(of: self)` must be the same as `type(of: otherVersion)`.
    /// - Returns: `true` if `otherVersion` is greater than `self`, otherwise `false`.
    @inlinable
    public func isNotNewer(than otherVersion: SQLDatabaseReportedVersion) -> Bool {
        self.isEqual(to: otherVersion) || self.isOlder(than: otherVersion)
    }

    /// Check whether the current version (i.e. `self`) is newer than the one given.
    ///
    /// Corresponds to ``Swift/Comparable/>(_:_:)``.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against. `type(of: self)` must be the same as `type(of: otherVersion)`.
    /// - Returns: `true` if `otherVersion` is equal to or less than `self`, otherwise `false`.
    @inlinable
    public func isNewer(than otherVersion: SQLDatabaseReportedVersion) -> Bool {
        !self.isNotNewer(than: otherVersion)
    }

    /// Check whether the current version (i.e. `self`) is newer than or equal to the one given.
    ///
    /// Corresponds to ``Swift/Comparable/>=(_:_:)``.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against. `type(of: self)` must be the same as `type(of: otherVersion)`.
    /// - Returns: `true` if `otherVersion` is less than `self`, otherwise `false`.
    @inlinable
    public func isNotOlder(than otherVersion: SQLDatabaseReportedVersion) -> Bool {
        !self.isOlder(than: otherVersion)
    }
}

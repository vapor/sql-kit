extension SQLDatabaseReportedVersion {
    /// Check whether the current version (i.e. `self`) is older than or equal to the one given.
    ///
    /// > Warning: This method has been deprecated; use the `<=` operator instead.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against. `type(of: self)` must be the same as `type(of: otherVersion)`.
    /// - Returns: `true` if `otherVersion` is greater than `self`, otherwise `false`.
    @inlinable
    @available(*, deprecated, renamed: "<=", message: "Use the `<=` operator instead.")
    public func isNotNewer(than otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? Self).map { self.isEqual(to: $0) || self.isOlder(than: $0) } ?? false
    }
    
    /// Check whether the current version (i.e. `self`) is newer than the one given.
    ///
    /// > Warning: This method has been deprecated; use the `>` operator instead.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against. `type(of: self)` must be the same as `type(of: otherVersion)`.
    /// - Returns: `true` if `otherVersion` is equal to or less than `self`, otherwise `false`.
    @inlinable
    @available(*, deprecated, renamed: ">", message: "Use the `>` operator instead.")
    public func isNewer(than otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? Self).map { !self.isNotNewer(than: $0) } ?? false
    }

    /// Check whether the current version (i.e. `self`) is newer than or equal to the one given.
    ///
    /// > Warning: This method has been deprecated; use the `>=` operator instead.
    ///
    /// - Parameters:
    ///   - otherVersion: The version to compare against. `type(of: self)` must be the same as `type(of: otherVersion)`.
    /// - Returns: `true` if `otherVersion` is less than `self`, otherwise `false`.
    @inlinable
    @available(*, deprecated, renamed: ">=", message: "Use the `>=` operator instead.")
    public func isNotOlder(than otherVersion: any SQLDatabaseReportedVersion) -> Bool {
        (otherVersion as? Self).map { !self.isOlder(than: $0) } ?? false
    }
}

extension SQLDatabase {
    @available(*, deprecated, renamed: "unsafeRaw(_:)", message: "SQLDatabase.unsafeRaw(_:) has been renamed to SQLDatabase.unsafeRaw(_:).")
    @inlinable
    public func raw(_ sql: SQLQueryString) -> SQLRawBuilder {
        self.unsafeRaw(sql)
    }
}

extension SQLCreateTrigger.TimingSpecifier {
    /// A legacy specifier. Behaves identically to ``deferrable``, which should be used instead.
    @available(*, deprecated, renamed: "deferrable")
    public static var initiallyImmediate: Self { .deferrable }
    
    /// A legacy specifier. Behaves identically to ``deferredByDefault``, which should be used instead.
    @available(*, deprecated, renamed: "deferredByDefault")
    public static var initiallyDeferred: Self { .deferredByDefault }
}

extension SQLDataType {
    /// An inadvertently public test utility. Do not use.
    @available(*, deprecated, message: "This is a test utility method that was incorrectly made public. Use `.custom()` directly instead.")
    @inlinable
    public static func type(_ string: String) -> Self {
        .custom(SQLIdentifier(string))
    }
}

extension SQLDropEnum {
    /// A legacy alias for toggling ``dropBehavior`` between ``SQLDropBehavior/restrict`` (`false`) and
    /// ``SQLDropBehavior/cascade`` (`true`). Prefer setting ``dropBehavior`` directly instead.
    @available(*, deprecated, renamed: "dropBehavior")
    public var cascade: Bool {
        get { self.dropBehavior == .cascade }
        set { self.dropBehavior = newValue ? .cascade : .restrict }
    }
}

extension SQLDropTrigger {
    /// A legacy alias for toggling ``dropBehavior`` between ``SQLDropBehavior/restrict`` (`false`) and
    /// ``SQLDropBehavior/cascade`` (`true`). Prefer setting ``dropBehavior`` directly instead.
    @available(*, deprecated, renamed: "dropBehavior")
    public var cascade: Bool {
        get { self.dropBehavior == .cascade }
        set { self.dropBehavior = newValue ? .cascade : .restrict }
    }
}

extension SQLQueryString {
    /// [DEPRECATED] Adds an interpolated string of raw SQL.
    ///
    /// > Important: This is a deprecated legacy alias of ``appendInterpolation(unsafeRaw:)``. Update your
    /// > code to use that method, or better yet to not use raw interpolation at all.
    @available(*, deprecated, renamed: "appendInterpolation(unsafeRaw:)", message: """
        This method has been renamed to clarify that raw interpolation is unsafe. Use `\\(unsafeRaw:)` instead.
        """)
    @inlinable
    public mutating func appendInterpolation(raw value: String) {
        self.appendInterpolation(unsafeRaw: value)
    }
    
    /// [EVEN MORE DEPRECATED] Adds an interpolated string of raw SQL.
    ///
    /// This is the deprecated original version of ``appendInterpolation(unsafeRaw:)``; its naming is misleading,
    /// and it has previously been trivially easy to invoke it by accident, with no indication of the potential
    /// risk its use carries. It is now strictly deprecated and will generate a compiler warning if used.  As with
    /// ``appendInterpolation(raw:)``, update calling code to use ``appendInterpolation(unsafeRaw:)``, or,
    /// preferably, don't use raw interpolation at all.
    ///
    /// > Note: The maintainer of this package regrets that there are a total of no less than _three_ copies of
    /// > this method, all of which are identical aside from naming, and of which two of the three are potentially
    /// > unsafe. The next major version of SQLKit will take considerable pleasure in being able to finally address
    /// > such problems for good.
    @available(*, deprecated, renamed: "appendInterpolation(unsafeRaw:)", message: """
        This method is misleading; it does not act on literals in the SQL sense of the term and offers no indication
        that it allows for unsafe direct injection of arbitrary SQL text. Use `\\(unsafeRaw:)` instead.
        """)
    @inlinable
    public mutating func appendInterpolation(_ value: String) {
        self.appendInterpolation(unsafeRaw: value)
    }
}

@available(*, deprecated, renamed: "SQLUnsafeRaw", message: "SQLRaw has been renamed to SQLUnsafeRaw.")
public typealias SQLRaw = SQLUnsafeRaw

extension SQLUnsafeRaw {
    @available(*, deprecated, message: "Binds set in an `SQLUnsafeRaw` are ignored. Use `SQLBind`instead.")
    @inlinable
    public init(_ sql: String, _ binds: [any Encodable & Sendable]) {
        self.sql = sql
        self.binds = binds
    }
}

/// Old name for ``SQLCreateTrigger/WhenSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.WhenSpecifier")
public typealias SQLTriggerWhen = SQLCreateTrigger.WhenSpecifier

/// Old name for ``SQLCreateTrigger/EventSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.EventSpecifier")
public typealias SQLTriggerEvent = SQLCreateTrigger.EventSpecifier

/// Old name for ``SQLCreateTrigger/TimingSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.TimingSpecifier")
public typealias SQLTriggerTiming = SQLCreateTrigger.TimingSpecifier

/// Old name for ``SQLCreateTrigger/EachSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.EachSpecifier")
public typealias SQLTriggerEach = SQLCreateTrigger.EachSpecifier

/// Old name for ``SQLCreateTrigger/OrderSpecifier``.
@available(*, deprecated, renamed: "SQLCreateTrigger.OrderSpecifier")
public typealias SQLTriggerOrder = SQLCreateTrigger.OrderSpecifier

extension SQLUnionJoiner {
    @available(*, deprecated, message: "Use `.type` instead.")
    @inlinable
    public var all: Bool {
        get { [.unionAll, .intersectAll, .exceptAll].contains(self.type) }
        set { switch (self.type, newValue) {
            case (.union, true): self.type = .unionAll
            case (.unionAll, false): self.type = .union
            case (.intersect, true): self.type = .intersectAll
            case (.intersectAll, false): self.type = .intersect
            case (.except, true): self.type = .exceptAll
            case (.exceptAll, false): self.type = .except
            default: break
        } }
    }
    
    @available(*, deprecated, message: "Use `.init(type:)` instead.")
    @inlinable
    public init(all: Bool) {
        self.init(type: all ? .unionAll : .union)
    }
}

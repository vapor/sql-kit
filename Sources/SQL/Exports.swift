@_exported import Async
@_exported import Core
@_exported import DatabaseKit

extension SQLSelectBuilder {
    /// Deprecated.
    @available(*, deprecated, renamed: "column(_:as:)")
    public func column(
        expression: Connection.Query.Expression,
        as alias: Connection.Query.Identifier? = nil
    ) -> Self {
        return column(.expression(expression, alias: alias))
    }
}

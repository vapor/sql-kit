/// The fundamental base type of anything which can be represented as SQL using SQLKit.
///
/// ``SQLExpression``s are not well-enough organized in practice to be considered a proper Abstract Syntax Tree
/// representation, but they nonetheless conceptually act as AST nodes. As such, _anything_ which is executed as
/// SQL by an ``SQLDatabase`` is represented by a value conforming to ``SQLExpression`` - even if that value is an
/// instance of ``SQLUnsafeRaw`` containing arbitrary SQL text.
///
/// The single requirement of ``SQLExpression`` is the ``SQLExpression/serialize(to:)`` method, which must output
/// the appropriate raw text, bindings, and/or subexpressions to the provided ``SQLSerializer`` when invoked. Most
/// interaction with ``SQLDialect`` takes place in the serialization logic of various ``SQLExpression``s - for
/// example, ``SQLIdentifier`` uses the ``SQLDialect/identifierQuote`` of the serializer's dialect when quoting
/// identifiers (naturally enough). Many ``SQLExpression``s - especially those representing entire SQL queries, such
/// as ``SQLSelect`` or ``SQLCreateTable`` - function solely as containers of other expressions which are serialized
/// in an appropriate sequence.
///
/// See ``SQLSerializer`` and ``SQLDatabase/serialize(_:)`` for additional details regarding serialization.
///
/// Here is an example of implementing a trivial (and somewhat pointless) ``SQLExpression``:
///
/// ```swift
/// public struct SQLOptionalExpression<E: SQLExpression>: SQLExpression {
///     public var subexpression: E?
///
///     public init(_ subexpression: E?) {
///         self.subexpression = subexpression
///     }
///
///     public func serialize(to serializer: inout SQLSerializer) {
///         if let subexpression = self.subexpression {
///             subexpression.serialize(to: serializer)
///         }
///     }
/// }
/// ```
///
/// > Note: The example expression above treats the type of the "subexpression" it contains generically; this is
/// > currently considered best practice whenever possible. However, this pattern is unfortunately _not_ adopted
/// > by any of the expressions included in SQLKit itself - instead, the existential type `any SQLExpression` is
/// > used with great abandon. This is, to say the least, not optimal, but as usual with pre-existing public API,
/// > it cannot be changed until the next major version bump. The API in its present form was designed back when
/// > Swift 5.1 was the current release; the language features needed to usefully handle expressions generically
/// > were largely absent before Swift 5.7, and even then it would have been severely limited before the advent of
/// > Swift 5.9 and support for variadic generics.
public protocol SQLExpression: Sendable {
    /// Invoked when a request is made to serialize the expression to raw SQL.
    /// 
    /// Implementations of this requirement should invoke various ``SQLSerializer`` methods as appropriate to
    /// convert its contents to raw SQL form, including inspecting ``SQLSerializer/dialect`` as needed.
    /// 
    /// > Important: Because this method is not throwing, an expression which encounters a serialization
    /// > failure has limited options to report it. Implementations are _STRONGLY_ discouraged from triggering a
    /// > runtime error (such as via `fatalError()`) or from using `print()` to inform the user; instead, the
    /// > recommended behavior for such failures is:
    /// >
    /// > 1. (Optional) Use the ``SQLDatabase/logger`` of the ``SQLSerializer/database`` to log an appropriate
    /// >    message at an appropriate severity level.
    /// > 2. Either output no content at all, or output deliberately syntactically invalid SQL to ensure an attempt
    /// >    to execute a query containing the failing expression will fail in turn.
    ///
    /// - Parameter serializer: The ``SQLSerializer`` to use.
    func serialize(to serializer: inout SQLSerializer)
}

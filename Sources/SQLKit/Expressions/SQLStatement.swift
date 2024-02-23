import struct Logging.Logger

extension SQLSerializer {
    /// Invoke the provided closure with a new ``SQLStatement`` to use for serialization.
    ///
    /// This method is the entry point for the alternate expression serialization API provided by ``SQLStatement``.
    /// The name of the type is somewhat misleading; the serialized result is not required to be a complete SQL
    /// "statement"; as with the usual ``SQLSerializer`` API, the inputs and resultant output can be arbitrary.
    ///
    /// To use the "statement" API, call this method in the implentation of ``SQLExpression/serialize(to:)``, and
    /// provide a closure which contains the serialization logic for the expression. Call methods of the
    /// ``SQLStatement`` passed to the closure to add individual textual and subexpression pieces to the final
    /// result. Do _not_ access the ``SQLSerializer`` from inside the closure.
    ///
    /// For example, consider ``SQLEnumDataType``'s ``SQLEnumDataType/serialize(to:)`` method:
    ///
    /// ```swift
    /// public func serialize(to serializer: inout SQLSerializer) {
    ///     switch serializer.dialect.enumSyntax {
    ///     case .inline:
    ///         SQLRaw("ENUM").serialize(to: &serializer)
    ///         SQLGroupExpression(self.cases).serialize(to: &serializer)
    ///     default:
    ///         SQLDataType.text.serialize(to: &serializer)
    ///         serializer.database.logger.warning("Database does not support inline enums. Storing as TEXT instead.")
    ///     }
    /// }
    /// ```
    ///
    /// Rewritten using ``SQLSerializer/statement(_:)``, the method becomes:
    ///
    /// ```swift
    /// public func serialize(to serializer: inout SQLSerializer) {
    ///     serializer.statement {
    ///         switch $0.dialect.enumSyntax {
    ///         case .inline:
    ///             $0.append("ENUM", SQLGroupExpression(self.cases))
    ///         default:
    ///             $0.append(SQLDataType.text)
    ///             $0.logger.warning("Database does not support inline enums. Storing as TEXT instead.")
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// > Note: While doing so is not especially useful, this method can be called more than once within the same
    /// > context; each invocation immediately serializes the statement upon return from the provided closure.
    @inlinable
    public mutating func statement(_ closure: (inout SQLStatement) -> ()) {
        var sql = SQLStatement(database: self.database)
        closure(&sql)
        sql.serialize(to: &self)
    }
}

/// An alternative API for serialization of ``SQLExpression``s.
///
/// The ``SQLSerializer/statement(_:)`` method provides access to the "statement" serialization API, which offers
/// a more consistent and readable interface for serialization than the repeated calls to ``SQLSerializer/write(_:)``
/// and ``SQLExpression/serialize(to:)`` originally described by ``SQLExpression``. See the documentation of
/// ``SQLSerializer/statement(_:)`` for example usage.
///
/// > Note: Although ``SQLStatement`` itself conforms to ``SQLExpression``, users are not expected to explicitly
/// > include it in the serialization of any other expression; it is serialized automatically by
/// > ``SQLSerializer/statement(_:)`` when appropriate.
public struct SQLStatement: SQLExpression {
    /// The individual expressions collected by the statement, in order.
    ///
    /// The serialization of a given ``SQLStatement`` is that of each element of its ``parts`` array, with a
    /// single space character placed between the SQL text of each element.
    public var parts: [any SQLExpression] = []
    
    /// The ``SQLDatabase`` obtained from the original ``SQLSerializer``.
    @usableFromInline
    let database: any SQLDatabase

    /// Designated initializer.
    ///
    /// External users may not invoke this method; use ``SQLSerializer/statement(_:)``.
    @usableFromInline
    init(database: any SQLDatabase) {
        self.database = database
    }

    /// Convenience accessor for the database's `Logger`.
    ///
    /// > Note: The compiler's exclusive access checking rules prevent statement closures from accessing the
    /// > original serializer directly.
    @inlinable
    public var logger: Logger {
        self.database.logger
    }

    /// Convenience accessor for the database's ``SQLDialect``.
    ///
    /// > Note: The compiler's exclusive access checking rules prevent statement closures from accessing the
    /// > original serializer directly.
    @inlinable
    public var dialect: any SQLDialect {
        self.database.dialect
    }

    /// Add raw text to the statement output.
    ///
    /// - Parameter raw: The text to add.
    @inlinable
    public mutating func append(_ raw: String) {
        self.append(SQLRaw(raw))
    }
    
    /// Add an unserialized ``SQLExpression`` to the statement output.
    ///
    /// > Warning: Unlike the ``SQLSerializer`` API, in which serializing an expression is the only way to include it
    /// > in the output of the overal operation, expressions added to ``SQLStatement``s are retained in their original
    /// > forms until the statement itself is esrialized. This may produce unexpected behavior if an expression is a
    /// > reference type with mutable properties, or if its serialization is dependent on the current overall
    /// > serialization state.
    ///
    /// - Parameter part: The expression to add.
    @inlinable
    public mutating func append(_ part: any SQLExpression) {
        self.parts.append(part)
    }
    
    /// Add an optional unserialized ``SQLExpression`` of any kind to the output.
    ///
    /// This is intended as a convenient shorthand for `if let expr { statement.append(expr) }`.
    ///
    /// See also ``append(_:)-7s7z8``.
    ///
    /// - Parameter maybePart: An expression to add, if not `nil`.
    @inlinable
    public mutating func append(_ maybePart: (any SQLExpression)?) {
        maybePart.map { self.append($0) }
    }

    /// Add raw text and an unserialized ``SQLExpression`` to tbe statement output, in that order.
    ///
    /// See also ``append(_:)-7s7z8`` and ``append(_:_:)-236y3``.
    ///
    /// - Parameters:
    ///   - raw: The raw text to add.
    ///   - part: The expression to add.
    @inlinable
    public mutating func append(_ raw: String, _ part: any SQLExpression) {
        self.append(raw)
        self.append(part)
    }

    /// Add an unserialized ``SQLExpression`` and raw text to tbe statement output, in that order.
    ///
    /// See also ``append(_:)-7s7z8`` and ``append(_:_:)-53s9b``.
    ///
    /// - Parameters:
    ///   - part: The expression to add.
    ///   - raw: The raw text to add.
    @inlinable
    public mutating func append(_ part: any SQLExpression, _ raw: String) {
        self.append(part)
        self.append(raw)
    }

    // See `SQLExpression.serialize(to:)`.
    @inlinable
    public func serialize(to serializer: inout SQLSerializer) {
        /// Although `self.parts.interspersed(with: SQLRaw(" ")).forEach { $0.serialize(to: &serializer) }` would be a
        /// more "elegant" way to write this, it results in the creation of `self.parts.count - 1` identical instances
        /// of ``SQLRaw`` and requires the compiler to dynamically dispatch a call to each one's `serialize(to:)`
        /// method. While the total overhead of this behavior is unlikely to be measurable in practice unless the
        /// statement has a very large number of constitutent parts, saving a couple of extra lines of code with a
        /// "clever trick" is still not at all worth it - especially since it also requires importing the
        /// `swift-algorithms` package, an entire additional dependency which adds insult to injury in the form of
        /// increased overall compile time.
        self.parts.first?.serialize(to: &serializer)
        self.parts.dropFirst().forEach {
            serializer.write(" ")
            $0.serialize(to: &serializer)
        }
    }
}

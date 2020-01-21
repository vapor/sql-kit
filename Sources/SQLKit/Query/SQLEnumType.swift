public struct SQLEnum: SQLExpression {
    /// The possible values of the enum type.
    ///
    /// Commonly implemented as a `SQLGroupExpression`
    var cases: [SQLExpression]

    public init(cases: [String]) {
        self.cases = cases.map { SQLLiteral.string($0) }
    }

    public init(cases: [SQLExpression]) {
        self.cases = cases
    }

    public func serialize(to serializer: inout SQLSerializer) {
        switch serializer.dialect.enumSyntax {
        case .inline:
            // e.g. ENUM('case1', 'case2')
            SQLRaw("ENUM").serialize(to: &serializer)
            SQLGroupExpression(self.cases).serialize(to: &serializer)
        default:
            // NOTE: Consider using a CHECK constraint
            //      with a TEXT type to verify that the
            //      text value for a column is in a list
            //      of possible options.
            SQLDataType.text.serialize(to: &serializer)
        }
    }
}

extension SQLDataType {
    public static func `enum`(_ cases: String...) -> Self {
        self.enum(cases)
    }
    
    public static func `enum`(_ cases: [String]) -> Self {
        self.enum(cases.map { SQLLiteral.string($0) })
    }
    public static func `enum`(_ cases: [SQLExpression]) -> Self {
        self.custom(SQLEnum(cases: cases))
    }
}

// ALTER TYPE enum_type ADD VALUE 'new_value';

public struct SQLAlterType: SQLExpression {
    public var name: SQLExpression
    public var values: [SQLExpression]

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("ALTER TYPE ")
        self.name.serialize(to: &serializer)
        for value in values {
            serializer.write(" ADD VALUE ")
            value.serialize(to: &serializer)
        }
    }
}

public final class SQLAlterTypeBuilder: SQLQueryBuilder {
    public var database: SQLDatabase
    public var alterType: SQLAlterType
    public var query: SQLExpression {
        self.alterType
    }

    init(database: SQLDatabase, name: SQLExpression) {
        self.database = database
        self.alterType = .init(name: name, values: [])
    }

    public func add(value: String) -> Self {
        self.add(value: SQLLiteral.string(value))
    }

    public func add(value: SQLExpression) -> Self {
        self.alterType.values.append(value)
        return self
    }
}

extension SQLDatabase {
    public func alter(type: String) -> SQLAlterTypeBuilder {
        .init(database: self, name: SQLRaw(type))
    }
}


/// The `CREATE TYPE` command is used to create a new types in a database.
///
/// See `PostgresCreateTypeBuilder`.
public struct PostgresCreateType: SQLExpression {
    /// Name of type to create.
    public var name: SQLExpression

    public var definition: Definition

    public enum Definition {
//        case composite /* https://github.com/vapor/postgres-kit/issues/151 */
//        case base      /* https://github.com/vapor/postgres-kit/issues/152 */
        case `enum`([String])
    }

    public init(name: SQLExpression, definition: Definition) {
        self.name = name
        self.definition = definition
    }

    /// Creates a new `PostgresCreateType` query for an `ENUM` type.
    public static func `enum`(name: SQLExpression, cases: String...) -> PostgresCreateType {
        return .enum(name: name, cases: cases)
    }

    /// Creates a new `PostgresCreateType` query for an `ENUM` type.
    public static func `enum`(name: SQLExpression, cases: [String]) -> PostgresCreateType {
        return PostgresCreateType(name: name, definition: .enum(cases))
    }

    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("CREATE ")
        serializer.write("TYPE ")
        self.name.serialize(to: &serializer)
        serializer.write(" ")
        self.definition.serialize(to: &serializer)
    }
}

extension PostgresCreateType.Definition {
    func serialize(to serializer: inout SQLSerializer) {
        switch self {
        case .enum(let cases):
            serializer.write("AS ENUM ")
            SQLGroupExpression(cases.map { SQLLiteral.string($0) })
                .serialize(to: &serializer)
        }
    }
}
/// `DROP TYPE` query.
///
/// See `PostgresDropTypeBuilder`.
public struct PostgresDropType: SQLExpression {
    /// Type to drop.
    public let typeName: SQLExpression

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the type does not exist.
    public var ifExists: Bool

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    public var cascade: Bool

    /// Creates a new `PostgresDropType`.
    public init(typeName: SQLExpression) {
        self.typeName = typeName
        self.ifExists = false
        self.cascade = false
    }

    /// See `SQLExpression`.
    public func serialize(to serializer: inout SQLSerializer) {
        serializer.write("DROP TYPE ")
        if self.ifExists {
            serializer.write("IF EXISTS ")
        }
        self.typeName.serialize(to: &serializer)
        if self.cascade {
            serializer.write(" CASCADE")
        }
    }
}
/// Builds `PostgresCreateType` queries.
///
///    conn.create(enum: "meal", cases: "breakfast", "lunch", "dinner")
///        .run()
///
/// See `SQLColumnBuilder` and `SQLQueryBuilder` for more information.
public final class PostgresCreateTypeBuilder: SQLQueryBuilder {
    /// `CreateType` query being built.
    public var createType: PostgresCreateType

    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase

    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.createType
    }

    /// Creates a new `PostgresCreateTypeBuilder`.
    public init(_ createType: PostgresCreateType, on database: SQLDatabase) {
        self.createType = createType
        self.database = database
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `PostgresCreateTypeBuilder`.
    ///
    ///     conn.create(enum: "meal", cases: "breakfast", "lunch", "dinner")...
    ///
    /// - parameters:
    ///     - name: Name of ENUM type to create.
    ///     - cases: The cases of the ENUM type.
    /// - returns: `PostgresCreateTypeBuilder`.
    public func create(enum name: String, cases: String...) -> PostgresCreateTypeBuilder {
        return self.create(enum: name, cases: cases)
    }

    /// Creates a new `PostgresCreateTypeBuilder`.
    ///
    ///     conn.create(enum: "meal", cases: "breakfast", "lunch", "dinner")...
    ///
    /// - parameters:
    ///     - name: Name of ENUM type to create.
    ///     - cases: The cases of the ENUM type.
    /// - returns: `PostgresCreateTypeBuilder`.
    public func create(enum name: String, cases: [String]) -> PostgresCreateTypeBuilder {
        return self.create(enum: SQLRaw(name), cases: cases)
    }

    /// Creates a new `PostgresCreateTypeBuilder`.
    ///
    ///     conn.create(enum: SQLIdentifier("meal"), cases: "breakfast", "lunch", "dinner")...
    ///
    /// - parameters:
    ///     - name: Name of ENUM type to create.
    ///     - cases: The cases of the ENUM type.
    /// - returns: `PostgresCreateTypeBuilder`.
    public func create(enum name: SQLExpression, cases: String...) -> PostgresCreateTypeBuilder {
        return self.create(enum: name, cases: cases)
    }

    /// Creates a new `PostgresCreateTypeBuilder`.
    ///
    ///     conn.create(enum: SQLIdentifier("meal"), cases: "breakfast", "lunch", "dinner")...
    ///
    /// - parameters:
    ///     - name: Name of ENUM type to create.
    ///     - cases: The cases of the ENUM type.
    /// - returns: `PostgresCreateTypeBuilder`.
    public func create(enum name: SQLExpression, cases: [String]) -> PostgresCreateTypeBuilder {
        return .init(.enum(name: name, cases: cases), on: self)
    }
}
/// Builds `PostgresDropType` queries.
///
///     conn.drop(type: "meal").run()
///
/// See `SQLQueryBuilder` for more information.
public final class PostgresDropTypeBuilder: SQLQueryBuilder {
    /// `DropType` query being built.
    public var dropType: PostgresDropType

    /// See `SQLQueryBuilder`.
    public var database: SQLDatabase

    /// See `SQLQueryBuilder`.
    public var query: SQLExpression {
        return self.dropType
    }

    /// Creates a new `PostgresDropTypeBuilder`.
    public init(_ dropType: PostgresDropType, on database: SQLDatabase) {
        self.dropType = dropType
        self.database = database
    }

    /// The optional `IF EXISTS` clause suppresses the error that would normally
    /// result if the type does not exist.
    public func ifExists() -> Self {
        dropType.ifExists = true
        return self
    }

    /// The optional `CASCADE` clause drops other objects that depend on this type
    /// (such as table columns, functions, and operators), and in turn all objects
    /// that depend on those objects.
    public func cascade() -> Self {
        dropType.cascade = true
        return self
    }
}

// MARK: Connection

extension SQLDatabase {
    /// Creates a new `PostgresDropTypeBuilder`.
    ///
    ///     conn.drop(type: "meal").run()
    ///
    /// - parameters:
    ///     - type: Name of type to drop.
    /// - returns: `PostgresDropTypeBuilder`.
    public func drop(type name: String) -> PostgresDropTypeBuilder {
        return self.drop(type: SQLRaw(name))
    }

    /// Creates a new `PostgresDropTypeBuilder`.
    ///
    ///     conn.drop(type: "meal").run()
    ///
    /// - parameters:
    ///     - type: Name of type to drop.
    /// - returns: `PostgresDropTypeBuilder`.
    public func drop(type name: SQLExpression) -> PostgresDropTypeBuilder {
        return .init(.init(typeName: name), on: self)
    }
}

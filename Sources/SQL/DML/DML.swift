/// SQL data manipulation query (DML)
public struct DML {
    /// A computed SQL column.
    public struct ComputedColumn {
        /// Creates a new SQL `DataComputedColumn`.
        public static func function(_ function: String, _ keys: Key...) -> ComputedColumn {
            return .init(function: function, keys: keys)
        }
        
        /// Creates a new SQL `DataComputedColumn`.
        public static func function(_ function: String) -> ComputedColumn {
            return .init(function: function, keys: [])
        }
        
        /// The SQL function to call.
        public var function: String
        
        /// The SQL data column parameters to the function. Can be none.
        public var keys: [Key]
        
        /// Creates a new SQL `DataComputedColumn`.
        public init(function: String, keys: [Key] = []) {
            self.function = function
            self.keys = keys
        }
    }
    
    /// Represents a SQL join.
    public struct Join {
        /// Supported SQL `DataJoin` methods.
        public enum Method {
            /// (INNER) JOIN: Returns records that have matching values in both tables
            case inner
            /// LEFT (OUTER) JOIN: Return all records from the left table, and the matched records from the right table
            case left
            /// RIGHT (OUTER) JOIN: Return all records from the right table, and the matched records from the left table
            case right
            /// FULL (OUTER) JOIN: Return all records when there is a match in either left or right table
            case outer
        }
        
        /// `INNER`, `OUTER`, etc.
        public let method: Method
        
        /// The left-hand side of the join. References the local column.
        public let local: Column
        
        /// The right-hand side of the join. References the column being joined.
        public let foreign: Column
        
        /// Creates a new SQL `DataJoin`.
        public init(method: Method, local: Column, foreign: Column) {
            self.method = method
            self.local = local
            self.foreign = foreign
        }
    }

    
    /// Supported column types in a `DataQuery`.
    public struct Key: ExpressibleByStringLiteral {
        /// All columns, `*`., or all columns of a table, `foo`.*
        public static func all(table: String?) -> Key {
            return .init(storage: .all(table: table))
        }
        
        /// All columns, `*`., or all columns of a table, `foo`.*
        public static var all: Key {
            return .init(storage: .all(table: nil))
        }
        
        /// A single `DataColumn` with optional key.
        public static func column(_ column: Column, as key: String? = nil) -> Key {
            return .init(storage: .column(column, key: key))
        }
        
        /// A single `DataComputedColumn` with optional key.
        public static func computed(_ computed: ComputedColumn, as key: String? = nil) -> Key {
            return .init(storage: .computed(computed, key: key))
        }
        
        /// Internal storage.
        enum Storage {
            /// All columns, `*`., or all columns of a table, `foo`.*
            case all(table: String?)
            
            /// A single `DataColumn` with optional key.
            case column(Column, key: String?)
            
            /// A single `DataComputedColumn` with optional key.
            case computed(ComputedColumn, key: String?)
        }
        
        /// Internal storage.
        let storage: Storage
        
        /// Creates a new `Key`.
        init(storage: Storage) {
            self.storage = storage
        }
        
        /// See `ExpressibleByStringLiteral`.
        public init(stringLiteral value: String) {
            self = .column(.init(stringLiteral: value))
        }
    }
    
    /// A SQL `ORDER BY` that determines the order of results.
    public struct OrderBy {
        public static func ascending(_ columns: [Column]) -> OrderBy {
            return .init(columns: columns, direction: .ascending)
        }
        
        public static func descending(_ columns: [Column]) -> OrderBy {
            return .init(columns: columns, direction: .descending)
        }
        
        /// Available order by directions for a `DataOrderBy`.
        public enum Direction {
            /// DESC
            case ascending
            
            /// ASC
            case descending
        }
        
        /// The columns to order.
        public var columns: [Column]
        
        /// The direction to order the results.
        public var direction: Direction
        
        /// Creates a new SQL `DataOrderBy`
        public init(columns: [Column], direction: Direction) {
            self.columns = columns
            self.direction = direction
        }
    }
    
    /// Supported SQL data statement types.
    public struct Statement: ExpressibleByStringLiteral {
        /// `SELECT`
        ///
        /// - parameters:
        ///     - distinct: If `true`, only select distinct columns.
        public static var select: Statement {
            return .select(distinct: false)
        }
        
        /// `SELECT`
        ///
        /// - parameters:
        ///     - distinct: If `true`, only select distinct columns.
        public static func select(distinct: Bool) -> Statement {
            return .init(verb: "SELECT", modifiers: distinct ? ["DISTINCT"] : [])
        }
        
        /// `INSERT`
        public static var insert: Statement {
            return "INSERT"
        }
        
        /// `UPDATE`
        public static var update: Statement {
            return "UPDATE"
        }
        
        /// `DELETE`
        public static var delete: Statement {
            return "DELETE"
        }
        
        /// Statement verb, i.e., SELECT, INSERT, etc.
        public var verb: String
        
        /// Statement modifiers, i.e., IGNORE, IF NOT EXISTS
        public var modifiers: [String]
        
        /// Creates a new `DataManipulationStatement`.
        public init(verb: String, modifiers: [String] = []) {
            self.verb = verb.uppercased()
            self.modifiers = modifiers.map { $0.uppercased() }
        }
        
        /// See `ExpressibleByStringLiteral`.
        public init(stringLiteral value: String) {
            self.init(verb: value)
        }
    }

    /// All supported values for a SQL `DataPredicate`.
    public struct Value {
        /// A single placeholder.
        public static func bind(_ encodable: Encodable) -> Value {
            return .binds([encodable])
        }
        
        public static func column(_ column: Column) -> Value {
            return self.init(storage: .column(column))
        }
        
        /// One or more placeholders.
        public static func binds(_ encodables: [Encodable]) -> Value {
            return self.init(storage: .binds(encodables))
        }
        
        public static var null: Value {
            return self.init(storage: .null)
        }
        
        public static func unescaped(_ sql: String) -> Value {
            return self.init(storage: .unescaped(sql))
        }
        
        /// Internal storage enum.
        enum Storage {
            /// One or more placeholders.
            case binds([Encodable])
            /// Compare to another column in the database.
            case column(Column)
            /// Compare to a computed column.
            case computed(ComputedColumn)
            /// Serializes a complete sub-query as this predicate's value.
            case subquery(DML)
            /// NULL value.
            case null
            /// Custom string that will be interpolated into the SQL query.
            /// - warning: Be careful about SQL injection when using this.
            case unescaped(String)
        }
        
        /// Internal storage.
        let storage: Storage
    }
    
    /// The statement type: `INSERT`, `UPDATE`, `DELETE`.
    public var statement: Statement

    /// The table to query.
    public var table: String

    /// List of keys to fetch.
    public var keys: [Key]

    /// List of columns to manipulate.
    public var columns: [Column: Value]

    /// List of joins to execute.
    public var joins: [Join]

    /// List of predicates to filter by.
    public var predicate: Predicate
    
    /// `GROUP BY YEAR(date)`.
    public var groupBys: [GroupBy]

    /// List of columns to order by.
    public var orderBys: [OrderBy]

    /// Optional query limit. If set, result count must be less than the limit provided.
    public var limit: Int?

    /// Optional query offset. If set, results will be offset by the number provided.
    public var offset: Int?

    /// Creates a new `DataManipulationQuery`
    public init(statement: Statement, table: String, keys: [Key], columns: [Column: Value], joins: [Join], predicate: Predicate, groupBys: [GroupBy], orderBys: [OrderBy], limit: Int?, offset: Int?) {
        self.statement = statement
        self.table = table
        self.keys = keys
        self.columns = columns
        self.joins = joins
        self.predicate = predicate
        self.orderBys = orderBys
        self.groupBys = groupBys
        self.limit = limit
        self.offset = offset
    }
}

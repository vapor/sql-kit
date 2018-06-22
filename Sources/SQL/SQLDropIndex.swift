public protocol SQLDropIndex: SQLSerializable { }

// No generic drop index since there is not a standard subset of this query type
// MySQL requires a table name to drop and other SQLs cannot have a table name passed

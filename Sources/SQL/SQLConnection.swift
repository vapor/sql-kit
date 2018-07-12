/// Types conforming to this protocol can be used to build SQL queries. 
public protocol SQLConnection: DatabaseQueryable where Query: SQLQuery {
    /// Decodes a `Decodable` type from this connection's output.
    /// If a table is specified, values should come only from columns in that table.
    func decode<D>(_ type: D.Type, from row: Output, table: Query.Select.TableIdentifier?) throws -> D
        where D: Decodable
}

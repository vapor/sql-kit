import Core

public protocol SQLTable: Codable, Reflectable {
    static var sqlTableIdentifierString: String { get }
}

extension SQLTable {
    public static var sqlTableIdentifierString: String {
        return "\(Self.self)"
    }
}

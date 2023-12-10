public protocol Modelable {
  static var scheme: String { get }
  static var columnNames: [String] { get }
  var values: [any Encodable] { get }
}

public extension Modelable {
  static var scheme: String { String(describing: Self.self) }
}

public protocol Modelable {
  static var scheme: String { get }
  var fields: [(name: String, value: any Encodable)] { get }
}

public extension Modelable {
  static var scheme: String { String(describing: Self.self) }
}

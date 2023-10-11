/// An implementation of `CodingKey` intended to represent arbitrary string and integer coding keys.
///
/// This structure is effectively an inverse complement of the `CodingKeyRepresentable` protocol.
///
/// "_The standard library's version of a protocol whose requirements are trapped in an infinitely
/// recursive personal identity crisis._" - Unknown
public struct SomeCodingKey: CodingKey, Hashable {
    public let stringValue: String
    public let intValue: Int?
  
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }

    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    public var description: String {
        "SomeCodingKey(\"\(self.stringValue)\"\(self.intValue.map { ", int: \($0)" } ?? ""))"
    }
}

@propertyWrapper
public struct ModelableIgnored<Value> {
  public var wrappedValue: Value {
    get { value }
    set { value = newValue }
  }
  
  private var value: Value
  
  public init(wrappedValue: Value) {
    value = wrappedValue
  }
}

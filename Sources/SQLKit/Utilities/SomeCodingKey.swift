/// A straightforward implementation of `CodingKey`, used to represent arbitrary keys.
///
/// This type exists primarily as a helper, compensating for our inability to depend on
/// the presence of [`CodingKeyRepresentable`] (introduced in Swift 5.6 and tagged with a
/// macOS 12.3 availability requirement). Its implementation is largely identical to the
/// standard library's internal [`_DictionaryCodingKey`] type, as it serves the same purpose.
///
/// ![Quotation]
///
/// [`_DictionaryCodingKey`]: https://github.com/apple/swift/blob/swift-5.9-RELEASE/stdlib/public/core/Codable.swift#L5509
/// [`CodingKeyRepresentable`]: https://developer.apple.com/documentation/swift/codingkeyrepresentable
/// [Quotation]: data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iODQiIHdpZHRoPSI3MDAiIHZpZXdCb3g9IjAgMCA1MDAgNzAiPjxzdHlsZT4qe2xldHRlci1zcGFjaW5nOi4yNXB4O2ZvbnQ6aXRhbGljIDMwMCAxNnB4IEdlb3JnaWF9I3EsI3J7Zm9udDo0MDAgNDBweCBHZW9yZ2lhfTwvc3R5bGU+PHJlY3Qgd2lkdGg9IjQiIGhlaWdodD0iNzAiIGZpbGw9IiNkZGQiIHJ4PSIzIi8+PHRleHQgaWQ9InEiIHg9IjE3IiB5PSIzNiI+4oCcPC90ZXh0Pjx0ZXh0IHg9IjM2IiB5PSIxOCI+PHRzcGFuIHN0eWxlPSJmb250Oml0YWxpYyAxNHB4IE1lbmxvIj5Db2RpbmdLZXk8L3RzcGFuPiBpcyB0aGUgc3RhbmRhcmQgbGlicmFyeeKAmXMgYW5zd2VyIHRvIHRoZSBjb25jZXB0IG9mIGE8L3RleHQ+PHRleHQgeD0iMzciIHk9IjM4Ij5wcm90b2NvbCB3aG9zZSByZXF1aXJlbWVudHMgYXJlIGEgcmVjdXJzaXZlIGlkZW50aXR5IGNyaXNpcy48L3RleHQ+PHRleHQgaWQ9InIiIHg9IjQ3OSIgeT0iNTUiPuKAnTwvdGV4dD48dGV4dCBzdHlsZT0ibGV0dGVyLXNwYWNpbmc6MDtmb250Oml0YWxpYyAyMDAgMTZweCBIZWx2ZXRpY2FOZXVlIiB4PSIzNjAiIHk9IjY2Ij7igJPigJPCoFVua25vd248L3RleHQ+PC9zdmc+
public struct SomeCodingKey: CodingKey, Hashable, Sendable {
    // See `CodingKey.stringValue`.
    public let stringValue: String
    
    // See `CodingKey.intValue`.
    public let intValue: Int?

    // See `CodingKey.init(stringValue:)`.
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }

    // See `CodingKey.init(intValue:)`.
    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

extension String {
    /// Provides a version of `String.replacing(_:with:)` which is guaranteed to be available on
    /// pre-Ventura Apple platforms.
    @usableFromInline
    internal /*fileprivate*/ func sqlkit_replacing(_ search: some StringProtocol, with replacement: some StringProtocol) -> Self {
        .init(self[...].sqlkit_replacing(search, with: replacement))
    }
}

extension Substring {
    /// Provides a version of `Substring.replacing(_:with:)` which is guaranteed to be available on
    /// pre-Ventura Apple platforms.
    @usableFromInline
    internal /*fileprivate*/ func sqlkit_replacing(_ search: some StringProtocol, with replacement: some StringProtocol) -> Self {
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            return self.replacing(search, with: replacement)
        } else {
            guard !self.isEmpty, !search.isEmpty, self.count >= search.count else { return self }
            
            var result = self
            var index = result.firstIndex(of: search.first!) ?? result.endIndex
            
            while index < result.index(result.endIndex, offsetBy: -(search.count - 1)) {
                if result[index...].hasPrefix(search) {
                    result.replaceSubrange(index ..< result.index(index, offsetBy: search.count), with: replacement)
                    result.formIndex(&index, offsetBy: replacement.count)
                } else {
                    result.formIndex(after: &index)
                }
                index = result[index...].firstIndex(of: search.first!) ?? result.endIndex
            }
            return result
        }
    }
}

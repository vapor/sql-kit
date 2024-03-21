extension StringProtocol where Self: RangeReplaceableCollection, Self.Element: Equatable {
    /// Provides a version of `StringProtocol.firstRange(of:)` which is guaranteed to be available on
    /// pre-Ventura Apple platforms.
    @inlinable
    func sqlkit_firstRange(of other: some StringProtocol) -> Range<Self.Index>? {
        /// N.B.: This implementation is apparently some 650% faster than `firstRange(of:)`, at least on macOS...
        guard self.count >= other.count, let starter = other.first else { return nil }
        var index = self.startIndex
        let lastIndex = self.index(self.endIndex, offsetBy: -other.count)
        
        while index <= lastIndex, let start = self[index...].firstIndex(of: starter) {
            guard let upperIndex = self.index(start, offsetBy: other.count, limitedBy: self.endIndex) else {
                return nil
            }

            if self[start ..< upperIndex] == other {
                return start ..< upperIndex
            }
            index = self.index(after: start)
        }
        return nil
    }

    /// Provides a version of `StringProtocol.replacing(_:with:)` which is guaranteed to be available on
    /// pre-Ventura Apple platforms.
    @inlinable
    func sqlkit_replacing(_ search: some StringProtocol, with replacement: some StringProtocol) -> String {
        /// N.B.: Even on Ventura/Sonoma, the handwritten implementation is orders of magnitude faster than
        /// `replacing(_:with:)`, at least as of the time of this writing. Thus we use the handwritten version
        /// unconditionally. It's still 4x slower than Foundation's version, but that's a lot better than 25x.
        guard !self.isEmpty, !search.isEmpty, self.count >= search.count else { return .init(self) }
        
        var result = "", prevIndex = self.startIndex
        
        result.reserveCapacity(self.count + replacement.count)
        while let range = self[prevIndex...].sqlkit_firstRange(of: search) {
            result.append(contentsOf: self[prevIndex ..< range.lowerBound])
            result.append(contentsOf: replacement)
            prevIndex = range.upperBound
        }
        result.append(contentsOf: self[prevIndex...])
        return result
    }

    /// Returns the string with its first character lowercased.
    @inlinable
    var decapitalized: String {
        self.isEmpty ? "" : "\(self[self.startIndex].lowercased())\(self.dropFirst())"
    }

    /// Returns the string with its first character uppercased.
    @inlinable
    var encapitalized: String {
        self.isEmpty ? "" : "\(self[self.startIndex].uppercased())\(self.dropFirst())"
    }

    /// Returns the string with any `snake_case` converted to `camelCase`.
    ///
    /// This is a modified version of Foundation's implementation:
    /// https://github.com/apple/swift-foundation/blob/8010dfe6b1c38cdf363c8d3d3b43d7d4f4c9987b/Sources/FoundationEssentials/JSON/JSONDecoder.swift
    ///
    /// > Note: This method is _not_ idempotent with respect to `convertedToSnakeCase` for all inputs.
    var convertedFromSnakeCase: String {
        guard !self.isEmpty, let firstNonUnderscore = self.firstIndex(where: { $0 != "_" }) else {
            return .init(self)
        }
        
        var lastNonUnderscore = self.endIndex
        repeat {
            self.formIndex(before: &lastNonUnderscore)
        } while lastNonUnderscore > firstNonUnderscore && self[lastNonUnderscore] == "_"

        let keyRange = self[firstNonUnderscore...lastNonUnderscore]
        let leading  = self[self.startIndex..<firstNonUnderscore]
        let trailing = self[self.index(after: lastNonUnderscore)..<self.endIndex]
        let words    = keyRange.split(separator: "_")
        
        guard words.count > 1 else {
            return "\(leading)\(keyRange)\(trailing)"
        }
        return "\(leading)\(([words[0].decapitalized] + words[1...].map(\.encapitalized)).joined())\(trailing)"
    }
    
    /// Returns the string with any `camelCase` converted to `snake_case`.
    ///
    /// This is a modified version of Foundation's implementation:
    /// https://github.com/apple/swift-foundation/blob/8010dfe6b1c38cdf363c8d3d3b43d7d4f4c9987b/Sources/FoundationEssentials/JSON/JSONEncoder.swift
    ///
    /// > Note: This method is _not_ idempotent with respect to `convertedFromSnakeCase` for all inputs.
    var convertedToSnakeCase: String {
        guard !self.isEmpty else {
            return .init(self)
        }

        var words: [Range<String.Index>] = []
        var wordStart = self.startIndex, searchIndex = self.index(after: wordStart)

        while let upperCaseIndex = self[searchIndex...].firstIndex(where: \.isUppercase) {
            words.append(wordStart..<upperCaseIndex)
            wordStart = upperCaseIndex
            guard let lowerCaseIndex = self[upperCaseIndex...].firstIndex(where: \.isLowercase) else {
                break
            }
            searchIndex = lowerCaseIndex
            if lowerCaseIndex != self.index(after: upperCaseIndex) {
                let beforeLowerIndex = self.index(before: lowerCaseIndex)
                words.append(upperCaseIndex..<beforeLowerIndex)
                wordStart = beforeLowerIndex
            }
        }
        words.append(wordStart..<self.endIndex)
        return words.map { self[$0].decapitalized }.joined(separator: "_")
    }
    
    /// A necessarily inelegant polyfill for conformance to `CodingKeyRepresentable`, due to availability problems.
    @inlinable
    var codingKeyValue: any CodingKey {
        #if !DEBUG
        if #available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *) {
            return String(self).codingKey
        }
        #endif
        return SomeCodingKey(stringValue: .init(self))
    }
    
    /// Remove the given optional prefix from the string, if present.
    ///
    /// - Parameter prefix: The prefix to remove, if non-`nil`.
    /// - Returns: The string with the prefix removed, if it exists. The string unmodified if not,
    ///   or if `prefix` is `nil`.
    func drop(prefix: (some StringProtocol)?) -> Self.SubSequence {
        #if !DEBUG
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            return prefix.map(self.trimmingPrefix(_:)) ?? self[...]
        }
        #endif
        guard let prefix, self.starts(with: prefix) else {
            return self[self.startIndex ..< self.endIndex]
        }
        return self.dropFirst(prefix.count)
    }
}

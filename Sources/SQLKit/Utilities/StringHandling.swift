extension StringProtocol where Self: RangeReplaceableCollection, Self.Element: Equatable {
    /// Provides a version of `Substring.replacing(_:with:)` which is guaranteed to be available on
    /// pre-Ventura Apple platforms.
    @usableFromInline
    internal func sqlkit_replacing(_ search: some StringProtocol, with replacement: some StringProtocol) -> String {
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            return .init(self.replacing(search, with: replacement))
        } else {
            guard !self.isEmpty, !search.isEmpty, self.count >= search.count else { return .init(self) }
            
            var result = String(self)
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
        if #available(macOS 12.3, iOS 15.4, watchOS 8.5, tvOS 15.4, *) {
            return String(self).codingKey
        } else {
            return SomeCodingKey(stringValue: .init(self))
        }
    }
    
    /// Remove the given optional prefix from the string, if present.
    ///
    /// - Parameter prefix: The prefix to remove, if non-`nil`.
    /// - Returns: The string with the prefix removed, if it exists. The string unmodified if not,
    ///   or if `prefix` is `nil`.
    func drop(prefix: (some StringProtocol)?) -> Self.SubSequence {
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            return prefix.map(self.trimmingPrefix(_:)) ?? self[...]
        } else {
            guard let prefix, self.starts(with: prefix) else {
                return self[...]
            }
            return self.dropFirst(prefix.count)
        }
    }
}

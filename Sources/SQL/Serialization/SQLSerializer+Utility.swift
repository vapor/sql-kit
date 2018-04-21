extension SQLSerializer {
    /// See `SQLSerializer`.
    public func makePlaceholder(name: String) -> String {
        return "?"
    }

    /// See `SQLSerializer`.
    public func makeEscapedString(from string: String) -> String {
        return "`\(string)`"
    }
}

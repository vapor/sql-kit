extension SQLSerializer {
    /// See `SQLSerializer`.
    public func makeEscapedString(from string: String) -> String {
        return "`\(string)`"
    }
}

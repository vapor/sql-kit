import XCTest

// MARK: - Unwrap

func XCTUnwrapAsync<T>(
    _ expression: @autoclosure () async throws -> T?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async throws -> T {
    let result: T?
    
    do {
        result = try await expression()
    } catch {
        return try XCTUnwrap(try { throw error }(), message(), file: file, line: line)
    }
    return try XCTUnwrap(result, message(), file: file, line: line)
}

// MARK: - Equality

func XCTAssertEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Equatable {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertEqual(expr1, expr2, message(), file: file, line: line)
    } catch {
        return XCTAssertEqual(try { () -> Bool in throw error }(), false, message(), file: file, line: line)
    }
}

func XCTAssertNotEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Equatable {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertNotEqual(expr1, expr2, message(), file: file, line: line)
    } catch {
        return XCTAssertNotEqual(try { () -> Bool in throw error }(), true, message(), file: file, line: line)
    }
}

// MARK: - Fuzzy equality

func XCTAssertEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    accuracy: T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Numeric {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertEqual(expr1, expr2, accuracy: accuracy, message(), file: file, line: line)
    } catch {
        return XCTAssertEqual(try { () -> Bool in throw error }(), false, message(), file: file, line: line)
    }
}

func XCTAssertNotEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    accuracy: T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Numeric {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertNotEqual(expr1, expr2, accuracy: accuracy, message(), file: file, line: line)
    } catch {
        return XCTAssertNotEqual(try { () -> Bool in throw error }(), false, message(), file: file, line: line)
    }
}

func XCTAssertEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    accuracy: T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: FloatingPoint {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertEqual(expr1, expr2, accuracy: accuracy, message(), file: file, line: line)
    } catch {
        return XCTAssertEqual(try { () -> Bool in throw error }(), false, message(), file: file, line: line)
    }
}

func XCTAssertNotEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    accuracy: T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: FloatingPoint {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertNotEqual(expr1, expr2, accuracy: accuracy, message(), file: file, line: line)
    } catch {
        return XCTAssertNotEqual(try { () -> Bool in throw error }(), false, message(), file: file, line: line)
    }
}

// MARK: - Comparability

func XCTAssertGreaterThanAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Comparable {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertGreaterThan(expr1, expr2, message(), file: file, line: line)
    } catch {
        return XCTAssertGreaterThan(try { () -> Int in throw error }(), 0, message(), file: file, line: line)
    }
}

func XCTAssertGreaterThanOrEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Comparable {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertGreaterThanOrEqual(expr1, expr2, message(), file: file, line: line)
    } catch {
        return XCTAssertGreaterThanOrEqual(try { () -> Int in throw error }(), 0, message(), file: file, line: line)
    }
}


func XCTAssertLessThanAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Comparable {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertLessThan(expr1, expr2, message(), file: file, line: line)
    } catch {
        return XCTAssertLessThan(try { () -> Int in throw error }(), 0, message(), file: file, line: line)
    }
}

func XCTAssertLessThanOrEqualAsync<T>(
    _ expression1: @autoclosure () async throws -> T,
    _ expression2: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async where T: Comparable {
    do {
        let expr1 = try await expression1(), expr2 = try await expression2()
        return XCTAssertLessThanOrEqual(expr1, expr2, message(), file: file, line: line)
    } catch {
        return XCTAssertLessThanOrEqual(try { () -> Int in throw error }(), 0, message(), file: file, line: line)
    }
}

// MARK: - Truthiness

func XCTAssertAsync(
    _ predicate: @autoclosure () async throws -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async {
    do {
        let result = try await predicate()
        XCTAssert(result, message(), file: file, line: line)
    } catch {
        return XCTAssert(try { throw error }(), message(), file: file, line: line)
    }
}

func XCTAssertTrueAsync(
    _ predicate: @autoclosure () async throws -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async {
    do {
        let result = try await predicate()
        XCTAssertTrue(result, message(), file: file, line: line)
    } catch {
        return XCTAssertTrue(try { throw error }(), message(), file: file, line: line)
    }
}

func XCTAssertFalseAsync(
    _ predicate: @autoclosure () async throws -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async {
    do {
        let result = try await predicate()
        XCTAssertFalse(result, message(), file: file, line: line)
    } catch {
        return XCTAssertFalse(try { throw error }(), message(), file: file, line: line)
    }
}

// MARK: - Existence

func XCTAssertNilAsync(
    _ expression: @autoclosure () async throws -> Any?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async {
    do {
        let result = try await expression()
        return XCTAssertNil(result, message(), file: file, line: line)
    } catch {
        return XCTAssertNil(try { throw error }(), message(), file: file, line: line)
    }
}

func XCTAssertNotNilAsync(
    _ expression: @autoclosure () async throws -> Any?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async {
    do {
        let result = try await expression()
        XCTAssertNotNil(result, message(), file: file, line: line)
    } catch {
        return XCTAssertNotNil(try { throw error }(), message(), file: file, line: line)
    }
}

// MARK: - Exceptionality

func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line,
    _ callback: (any Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTAssertThrowsError({}(), message(), file: file, line: line, callback)
    } catch {
        XCTAssertThrowsError(try { throw error }(), message(), file: file, line: line, callback)
    }
}

func XCTAssertNoThrowAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) async {
    do {
        _ = try await expression()
    } catch {
        XCTAssertNoThrow(try { throw error }(), message(), file: file, line: line)
    }
}

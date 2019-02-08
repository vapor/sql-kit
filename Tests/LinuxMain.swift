import XCTest

@testable import SQLKitTests

// MARK: SQLKitTests

extension SQLKitTests {
	static let __allSQLKitTestsTests = [
        ("testBenchmarker", testBenchmarker),
        ("testLockingClause_forUpdate", testLockingClause_forUpdate),
        ("testLockingClause_lockInShareMode", testLockingClause_lockInShareMode),
	]
}

// MARK: Test Runner

#if !os(macOS)
public func __buildTestEntries() -> [XCTestCaseEntry] {
	return [
		// SQLKitTests
		testCase(SQLKitTests.__allSQLKitTestsTests),
	]
}

let tests = __buildTestEntries()
XCTMain(tests)
#endif


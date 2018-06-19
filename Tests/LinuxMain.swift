#if os(Linux)

import XCTest
@testable import SQLTests

XCTMain([
    // SQL
    testCase(SQLTests.allTests),
])

#endif

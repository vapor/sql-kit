#if os(Linux)

import XCTest
@testable import SQLKitTests

XCTMain([
    // SQL
    testCase(SQLKitTests.allTests),
])

#endif

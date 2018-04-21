#if os(Linux)

import XCTest
@testable import SQLTests

XCTMain([
    // SQL
    testCase(DataTests.allTests),
    testCase(SchemaTests.allTests),
])

#endif

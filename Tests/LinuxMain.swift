#if os(Linux)

import XCTest
@testable import SQLTests

XCTMain([
    // SQL
    testCase(DataQueryTests.allTests),
    testCase(DataManipulationTests.allTests),
    testCase(DataDefinitionTests.allTests),
])

#endif

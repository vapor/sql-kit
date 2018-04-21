import XCTest

import SQLTests

var tests = [XCTestCaseEntry]()
tests += SQLTests.allTests()
XCTMain(tests)
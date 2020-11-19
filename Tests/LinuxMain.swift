import XCTest

import SwaggerFakerTests

var tests = [XCTestCaseEntry]()
tests += SwaggerFakerTests.__allTests()

XCTMain(tests)

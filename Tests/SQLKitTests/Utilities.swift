import Logging
import SQLKit
import XCTest

func XCTAssertNoThrowWithResult<T>(
    _ expression: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath, line: UInt = #line
) -> T? {
    var result: T?
    
    XCTAssertNoThrow(result = try expression(), message(), file: file, line: line)
    return result
}

func XCTAssertSerialization(
    of queryBuilder: @autoclosure () throws -> some SQLQueryBuilder,
    is serialization: @autoclosure() throws -> String,
    message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line
) {
    XCTAssertEqual(try queryBuilder().simpleSerialize(), try serialization(), message(), file: file, line: line)
}

let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        
        handler.logLevel = ProcessInfo.processInfo.environment["LOG_LEVEL"].flatMap(Logger.Level.init(rawValue:)) ?? .info
        return handler
    }
    return true
}()

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

func XCTAssertEncoding(
    _ model: @autoclosure() throws -> any Encodable,
    using encoder: @autoclosure () throws -> SQLQueryEncoder,
    outputs columns: @autoclosure () throws -> [String],
    _ values: @autoclosure () throws -> [any SQLExpression],
    _ message: @autoclosure() -> String = "", file: StaticString = #filePath, line: UInt = #line
) {
    guard let columns = XCTAssertNoThrowWithResult(try columns(), message(), file: file, line: line),
          let values = XCTAssertNoThrowWithResult(try values(), message(), file: file, line: line),
          let model = XCTAssertNoThrowWithResult(try model(), message(), file: file, line: line),
          let encoder = XCTAssertNoThrowWithResult(try encoder(), message(), file: file, line: line),
          let encodedData = XCTAssertNoThrowWithResult(try encoder.encode(model), message(), file: file, line: line)
    else { return }
    let encodedColumns = encodedData.map(\.0), encodedValues = encodedData.map(\.1)
    
    XCTAssertEqual(columns, encodedColumns, message(), file: file, line: line)
    XCTAssertEqual(values.count, encodedValues.count, message(), file: file, line: line)
    for (value, encValue) in zip(values, encodedValues) {
        switch (value, encValue) {
        case (let value as SQLLiteral, let encValue as SQLLiteral): XCTAssertEqual(value, encValue, message(), file: file, line: line)
        case (let value as SQLBind, let encValue as SQLBind):       XCTAssertEqual(value, encValue, message(), file: file, line: line)
        default: XCTFail("Unexpected output (expected \(String(reflecting: value)), got \(String(reflecting: encValue))) \(message())", file: file, line: line)
        }
    }
}

func XCTAssertDecoding<D: Decodable & Sendable & Equatable>(
    _: D.Type,
    from row: @autoclosure () throws -> some SQLRow,
    using decoder: @autoclosure () throws -> SQLRowDecoder,
    outputs model: @autoclosure () throws -> D,
    _ message: @autoclosure() -> String = "", file: StaticString = #filePath, line: UInt = #line
) {
    guard let row = XCTAssertNoThrowWithResult(try row(), message(), file: file, line: line),
          let decoder = XCTAssertNoThrowWithResult(try decoder(), message(), file: file, line: line),
          let model = XCTAssertNoThrowWithResult(try model(), message(), file: file, line: line),
          let decodedModel = XCTAssertNoThrowWithResult(try decoder.decode(D.self, from: row), message(), file: file, line: line)
    else { return }
    
    XCTAssertEqual(model, decodedModel, message(), file: file, line: line)
}

let isLoggingConfigured: Bool = {
    LoggingSystem.bootstrap { label in
        var handler = StreamLogHandler.standardOutput(label: label)
        
        handler.logLevel = ProcessInfo.processInfo.environment["LOG_LEVEL"].flatMap(Logger.Level.init(rawValue:)) ?? .info
        return handler
    }
    return true
}()


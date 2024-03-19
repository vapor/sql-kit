@testable import SQLKit
import XCTest

final class SQLQueryEncoderTests: XCTestCase {
    func testQueryEncoderBasicConfigurations() {
        let model1 = BasicEncModel(
            boolValue: true,  optBoolValue: nil,   stringValue: "hello", optStringValue: "olleh",
            doubleValue: 1.0, optDoubleValue: nil, floatValue: 1.0,      optFloatValue: 0.1,
            int8Value: 1,     optInt8Value: nil,   int16Value: 2,        optInt16Value: 3,
            int32Value: 4,    optInt32Value: nil,  int64Value: 5,        optInt64Value: 6,
            uint8Value: 7,    optUint8Value: nil,  uint16Value: 8,       optUint16Value: 9,
            uint32Value: 10,  optUint32Value: nil, uint64Value: 11,      optUint64Value: 12,
            intValue: 13,     optIntValue: nil,    uintValue: 14,        optUintValue: 15
        )
        let model2 = BasicEncModel(
            boolValue: true,  optBoolValue: false, stringValue: "hello", optStringValue: nil,
            doubleValue: 1.0, optDoubleValue: 0.1, floatValue: 1.0,      optFloatValue: nil,
            int8Value: 1,     optInt8Value: 2,     int16Value: 3,        optInt16Value: nil,
            int32Value: 4,    optInt32Value: 5,    int64Value: 6,        optInt64Value: nil,
            uint8Value: 7,    optUint8Value: 8,    uint16Value: 9,       optUint16Value: nil,
            uint32Value: 10,  optUint32Value: 11,  uint64Value: 12,      optUint64Value: nil,
            intValue: 13,     optIntValue: 14,     uintValue: 15,        optUintValue: nil
        )

        // Model 1 with key strategies
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(keyEncodingStrategy: .useDefaultKeys),
            outputs: model1.plainColumns(nulls: false), model1.valueExpressions(nulls: false)
        )
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase),
            outputs: model1.snakeColumns(nulls: false), model1.valueExpressions(nulls: false)
        )
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(keyEncodingStrategy: .custom({ superCase($0) })),
            outputs: model1.supercaseColumns(nulls: false), model1.valueExpressions(nulls: false)
        )
        
        // Model 1 with key and nil strategies
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(keyEncodingStrategy: .useDefaultKeys, nilEncodingStrategy: .asNil),
            outputs: model1.plainColumns(nulls: true), model1.valueExpressions(nulls: true)
        )
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase, nilEncodingStrategy: .asNil),
            outputs: model1.snakeColumns(nulls: true), model1.valueExpressions(nulls: true)
        )
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(keyEncodingStrategy: .custom({ superCase($0) }), nilEncodingStrategy: .asNil),
            outputs: model1.supercaseColumns(nulls: true), model1.valueExpressions(nulls: true)
        )

        // Model 1 with prefix and key strategies
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .useDefaultKeys),
            outputs: model1.plainColumns(nulls: false).map { "p_\($0)" }, model1.valueExpressions(nulls: false)
        )
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .convertToSnakeCase),
            outputs: model1.snakeColumns(nulls: false).map { "p_\($0)" }, model1.valueExpressions(nulls: false)
        )
        XCTAssertEncoding(
            model1, using: SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .custom({ superCase($0) })),
            outputs: model1.supercaseColumns(nulls: false).map { "p_\($0)" }, model1.valueExpressions(nulls: false)
        )


        // Model 2 with key strategies
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(keyEncodingStrategy: .useDefaultKeys),
            outputs: model2.plainColumns(nulls: false), model2.valueExpressions(nulls: false)
        )
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase),
            outputs: model2.snakeColumns(nulls: false), model2.valueExpressions(nulls: false)
        )
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(keyEncodingStrategy: .custom({ superCase($0) })),
            outputs: model2.supercaseColumns(nulls: false), model2.valueExpressions(nulls: false)
        )

        // Model 2 with key and nil strategies
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(keyEncodingStrategy: .useDefaultKeys, nilEncodingStrategy: .asNil),
            outputs: model2.plainColumns(nulls: true), model2.valueExpressions(nulls: true)
        )
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase, nilEncodingStrategy: .asNil),
            outputs: model2.snakeColumns(nulls: true), model2.valueExpressions(nulls: true)
        )
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(keyEncodingStrategy: .custom({ superCase($0) }), nilEncodingStrategy: .asNil),
            outputs: model2.supercaseColumns(nulls: true), model2.valueExpressions(nulls: true)
        )

        // Model 2 with prefix and key strategies
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .useDefaultKeys),
            outputs: model2.plainColumns(nulls: false).map { "p_\($0)" }, model2.valueExpressions(nulls: false)
        )
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .convertToSnakeCase),
            outputs: model2.snakeColumns(nulls: false).map { "p_\($0)" }, model2.valueExpressions(nulls: false)
        )
        XCTAssertEncoding(
            model2, using: SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .custom({ superCase($0) })),
            outputs: model2.supercaseColumns(nulls: false).map { "p_\($0)" }, model2.valueExpressions(nulls: false)
        )
    }
    
    func testEncodeTopLevelOptional() {
        let model1: BasicEncModel? = .some(BasicEncModel(
            boolValue: true,  optBoolValue: nil,   stringValue: "hello", optStringValue: "olleh",
            doubleValue: 1.0, optDoubleValue: nil, floatValue: 1.0,      optFloatValue: 0.1,
            int8Value: 1,     optInt8Value: nil,   int16Value: 2,        optInt16Value: 3,
            int32Value: 4,    optInt32Value: nil,  int64Value: 5,        optInt64Value: 6,
            uint8Value: 7,    optUint8Value: nil,  uint16Value: 8,       optUint16Value: 9,
            uint32Value: 10,  optUint32Value: nil, uint64Value: 11,      optUint64Value: 12,
            intValue: 13,     optIntValue: nil,    uintValue: 14,        optUintValue: 15
        ))
        let model2: BasicEncModel? = nil
        
        XCTAssertEncoding(model1, using: SQLQueryEncoder(), outputs: model1?.plainColumns(nulls: false) ?? [], model1?.valueExpressions(nulls: false) ?? [])
        XCTAssertThrowsError(try SQLQueryEncoder().encode(model2)) {
            XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))")
        }
    }
    
    func testEncodeUnkeyedValues() {
        XCTAssertThrowsError(try SQLQueryEncoder().encode([true])) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
    }
    
    func testEncodeTopLevelValues() {
        XCTAssertThrowsError(try SQLQueryEncoder().encode(true)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode("hello")) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1.0)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1.0 as Float)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as Int8)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as Int16)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as Int32)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as Int64)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as UInt8)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as UInt16)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as UInt32)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as UInt64)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as Int)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(1 as UInt)) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
    }
    
    func testEncodeNestedKeyedValues() {
        XCTAssertNoThrow(try SQLQueryEncoder().encode(TestEncodableIfPresent(foo: .init())))
        XCTAssertNoThrow(try SQLQueryEncoder().encode(TestEncodableIfPresent(foo: nil)))
        XCTAssertNoThrow(try SQLQueryEncoder(nilEncodingStrategy: .asNil).encode(TestEncodableIfPresent(foo: nil)))
        XCTAssertNoThrow(try SQLQueryEncoder().encode(["a": ["b": "c"]]))
        XCTAssertNoThrow(try SQLQueryEncoder().encode(["a": ["b", "c"]]))
        XCTAssertThrowsError(try SQLQueryEncoder().encode(TestEncNestedKeyedContainers(foo: (1, 1))))  { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(TestEncNestedUnkeyedContainer(foo: true)))  { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLQueryEncoder().encode(TestKeylessSuperEncoder(foo: true)))  { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertNoThrow(try SQLQueryEncoder().encode(TestEncNestedSingleValueContainer(foo: (1, 1))))
        XCTAssertNoThrow(try SQLQueryEncoder().encode(TestEncNestedSingleValueContainer(foo: nil)))
        XCTAssertNoThrow(try SQLQueryEncoder(nilEncodingStrategy: .asNil).encode(TestEncNestedSingleValueContainer(foo: nil)))
        XCTAssertThrowsError(try SQLQueryEncoder().encode(TestEncEnum.foo(bar: true))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
    }
}

enum TestEncEnum: Codable {
    /// N.B.: Compiler autosynthesizes a call to `KeyedEncodingContainer.nestedContainer(keyedBy:forKey:)` for this.
    case foo(bar: Bool)
}

struct TestEncodableIfPresent: Encodable {
    let foo: Date?
}

struct TestKeylessSuperEncoder: Encodable {
    let foo: Bool
    
    func encode(to encoder: any Encoder) throws {
        XCTAssertNil(encoder.userInfo[.init(rawValue: "a")!]) // for completeness of code coverage
        var container = encoder.container(keyedBy: SomeCodingKey.self)
        let superEncoder = container.superEncoder()
        var subcontainer = superEncoder.singleValueContainer()
        try subcontainer.encode(self.foo)
    }
}

struct TestEncNestedUnkeyedContainer: Encodable {
    let foo: Bool
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: SomeCodingKey.self)
        var subcontainer = container.nestedUnkeyedContainer(forKey: .init(stringValue: "foo"))
        try subcontainer.encode(self.foo)
    }
}

struct TestEncNestedKeyedContainers: Encodable {
    let foo: (Int, Int)
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: SomeCodingKey.self)
        let superEncoder = container.superEncoder(forKey: .init(stringValue: "foo"))
        var subcontainer = superEncoder.container(keyedBy: SomeCodingKey.self)
        
        try subcontainer.encode(self.foo.0, forKey: .init(stringValue: "_0"))
        try subcontainer.encode(self.foo.1, forKey: .init(stringValue: "_1"))
    }
}

struct TestEncNestedSingleValueContainer: Encodable {
    let foo: (Int, Int)?
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: SomeCodingKey.self)
        let superEncoder = container.superEncoder(forKey: .init(stringValue: "foo"))
        var subcontainer = superEncoder.singleValueContainer()
        
        if let foo = self.foo {
            try subcontainer.encode(["_0": foo.0, "_1": foo.1])
        } else {
            try subcontainer.encodeNil()
        }
    }
}

struct BasicEncModel: Codable {
    var boolValue: Bool,     optBoolValue: Bool?,       stringValue: String, optStringValue: String?
    var doubleValue: Double, optDoubleValue: Double?,   floatValue: Float,   optFloatValue: Float?
    var int8Value: Int8,     optInt8Value: Int8?,       int16Value: Int16,   optInt16Value: Int16?
    var int32Value: Int32,   optInt32Value: Int32?,     int64Value: Int64,   optInt64Value: Int64?
    var uint8Value: UInt8,   optUint8Value: UInt8?,     uint16Value: UInt16, optUint16Value: UInt16?
    var uint32Value: UInt32, optUint32Value: UInt32?,   uint64Value: UInt64, optUint64Value: UInt64?
    var intValue: Int,       optIntValue: Int?,         uintValue: UInt,     optUintValue: UInt?
    
    func plainColumns(nulls: Bool) -> [String] { [
        "boolValue",   nulls || self.optBoolValue   != nil ? "optBoolValue"   : nil, "stringValue", nulls || self.optStringValue != nil ? "optStringValue" : nil,
        "doubleValue", nulls || self.optDoubleValue != nil ? "optDoubleValue" : nil, "floatValue",  nulls || self.optFloatValue  != nil ? "optFloatValue"  : nil,
        "int8Value",   nulls || self.optInt8Value   != nil ? "optInt8Value"   : nil, "int16Value",  nulls || self.optInt16Value  != nil ? "optInt16Value"  : nil,
        "int32Value",  nulls || self.optInt32Value  != nil ? "optInt32Value"  : nil, "int64Value",  nulls || self.optInt64Value  != nil ? "optInt64Value"  : nil,
        "uint8Value",  nulls || self.optUint8Value  != nil ? "optUint8Value"  : nil, "uint16Value", nulls || self.optUint16Value != nil ? "optUint16Value" : nil,
        "uint32Value", nulls || self.optUint32Value != nil ? "optUint32Value" : nil, "uint64Value", nulls || self.optUint64Value != nil ? "optUint64Value" : nil,
        "intValue",    nulls || self.optIntValue    != nil ? "optIntValue"    : nil, "uintValue",   nulls || self.optUintValue   != nil ? "optUintValue"   : nil,
    ].compactMap { $0 } }

    func snakeColumns(nulls: Bool) -> [String] { [
        "bool_value",   nulls || self.optBoolValue   != nil ? "opt_bool_value"   : nil, "string_value", nulls || self.optStringValue != nil ? "opt_string_value" : nil,
        "double_value", nulls || self.optDoubleValue != nil ? "opt_double_value" : nil, "float_value",  nulls || self.optFloatValue  != nil ? "opt_float_value"  : nil,
        "int8_value",   nulls || self.optInt8Value   != nil ? "opt_int8_value"   : nil, "int16_value",  nulls || self.optInt16Value  != nil ? "opt_int16_value"  : nil,
        "int32_value",  nulls || self.optInt32Value  != nil ? "opt_int32_value"  : nil, "int64_value",  nulls || self.optInt64Value  != nil ? "opt_int64_value"  : nil,
        "uint8_value",  nulls || self.optUint8Value  != nil ? "opt_uint8_value"  : nil, "uint16_value", nulls || self.optUint16Value != nil ? "opt_uint16_value" : nil,
        "uint32_value", nulls || self.optUint32Value != nil ? "opt_uint32_value" : nil, "uint64_value", nulls || self.optUint64Value != nil ? "opt_uint64_value" : nil,
        "int_value",    nulls || self.optIntValue    != nil ? "opt_int_value"    : nil, "uint_value",   nulls || self.optUintValue   != nil ? "opt_uint_value"   : nil,
    ].compactMap { $0 } }
    
    func supercaseColumns(nulls: Bool) -> [String] { [
        "BoolValue",   nulls || self.optBoolValue   != nil ? "OptBoolValue"   : nil, "StringValue", nulls || self.optStringValue != nil ? "OptStringValue" : nil,
        "DoubleValue", nulls || self.optDoubleValue != nil ? "OptDoubleValue" : nil, "FloatValue",  nulls || self.optFloatValue  != nil ? "OptFloatValue"  : nil,
        "Int8Value",   nulls || self.optInt8Value   != nil ? "OptInt8Value"   : nil, "Int16Value",  nulls || self.optInt16Value  != nil ? "OptInt16Value"  : nil,
        "Int32Value",  nulls || self.optInt32Value  != nil ? "OptInt32Value"  : nil, "Int64Value",  nulls || self.optInt64Value  != nil ? "OptInt64Value"  : nil,
        "Uint8Value",  nulls || self.optUint8Value  != nil ? "OptUint8Value"  : nil, "Uint16Value", nulls || self.optUint16Value != nil ? "OptUint16Value" : nil,
        "Uint32Value", nulls || self.optUint32Value != nil ? "OptUint32Value" : nil, "Uint64Value", nulls || self.optUint64Value != nil ? "OptUint64Value" : nil,
        "IntValue",    nulls || self.optIntValue    != nil ? "OptIntValue"    : nil, "UintValue",   nulls || self.optUintValue   != nil ? "OptUintValue"   : nil,
    ].compactMap { $0 } }
    
    func valueExpressions(nulls: Bool) -> [any SQLExpression] { [
        SQLBind(self.boolValue),   (self.optBoolValue.map { SQLBind($0) }   ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.stringValue), (self.optStringValue.map { SQLBind($0) } ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.doubleValue), (self.optDoubleValue.map { SQLBind($0) } ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.floatValue),  (self.optFloatValue.map { SQLBind($0) }  ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.int8Value),   (self.optInt8Value.map { SQLBind($0) }   ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.int16Value),  (self.optInt16Value.map { SQLBind($0) }  ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.int32Value),  (self.optInt32Value.map { SQLBind($0) }  ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.int64Value),  (self.optInt64Value.map { SQLBind($0) }  ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.uint8Value),  (self.optUint8Value.map { SQLBind($0) }  ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.uint16Value), (self.optUint16Value.map { SQLBind($0) } ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.uint32Value), (self.optUint32Value.map { SQLBind($0) } ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.uint64Value), (self.optUint64Value.map { SQLBind($0) } ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.intValue),    (self.optIntValue.map { SQLBind($0) }    ?? SQLLiteral.null) as any SQLExpression,
        SQLBind(self.uintValue),   (self.optUintValue.map { SQLBind($0) }   ?? SQLLiteral.null) as any SQLExpression,
    ].filter { nulls ? true : (($0 as? SQLLiteral).map { $0 != .null } ?? true) } }
}

@testable import SQLKit
import XCTest

final class SQLRowDecoderTests: XCTestCase {
    func testRowDecoderBasicConfigurations() {
        func row1(nulls: Bool, xform: Bool?, prefix: String = "") -> TestRow {
            let raw: [String: (any Codable & Sendable)?] = [
                "boolValue": true,           "optBoolValue": Bool?.none,     "stringValue": "hello",      "optStringValue": "olleh",
                "doubleValue": 1.0,          "optDoubleValue": Double?.none, "floatValue": 1.0 as Float,  "optFloatValue": 0.1 as Float?,
                "int8Value": 1 as Int8,      "optInt8Value": Int8?.none,     "int16Value": 2 as Int16,    "optInt16Value": 3 as Int16?,
                "int32Value": 4 as Int32,    "optInt32Value": Int32?.none,   "int64Value": 5 as Int64,    "optInt64Value": 6 as Int64?,
                "uint8Value": 7 as UInt8,    "optUint8Value": UInt8?.none,   "uint16Value": 8 as UInt16,  "optUint16Value": 9 as UInt16?,
                "uint32Value": 10 as UInt32, "optUint32Value": UInt32?.none, "uint64Value": 11 as UInt64, "optUint64Value": 12 as UInt64?,
                "intValue": 13 as Int,       "optIntValue": Int?.none,       "uintValue": 14 as UInt,     "optUintValue": 15 as UInt?
            ]
            let all = nulls ? raw : raw.compactMapValues { $0 }
            switch xform {
            case .none: return TestRow(data: .init(uniqueKeysWithValues: all.map { ("\(prefix)\($0)", $1) }))
            case .some(false): return TestRow(data: .init(uniqueKeysWithValues: all.map { ("\(prefix)\($0.convertedToSnakeCase)", $1) }))
            case .some(true): return TestRow(data: .init(uniqueKeysWithValues: all.map { ("\(prefix)\(superCase([SomeCodingKey(stringValue: $0)]).stringValue)", $1) }))
            }
        }
        func row2(nulls: Bool, xform: Bool?, prefix: String = "") -> TestRow {
            let raw: [String: (any Codable & Sendable)?] = [
                "boolValue": true,           "optBoolValue": false,           "stringValue": "hello",      "optStringValue": String?.none,
                "doubleValue": 1.0,          "optDoubleValue": 0.1,           "floatValue": 1.0 as Float,  "optFloatValue": Float?.none,
                "int8Value": 1 as Int8,      "optInt8Value": 2 as Int8?,      "int16Value": 3 as Int16,    "optInt16Value": Int16?.none,
                "int32Value": 4 as Int32,    "optInt32Value": 5 as Int32?,    "int64Value": 6 as Int64,    "optInt64Value": Int64?.none,
                "uint8Value": 7 as UInt8,    "optUint8Value": 8 as UInt8?,    "uint16Value": 9 as UInt16,  "optUint16Value": UInt16?.none,
                "uint32Value": 10 as UInt32, "optUint32Value": 11 as UInt32?, "uint64Value": 12 as UInt64, "optUint64Value": UInt64?.none,
                "intValue": 13 as Int,       "optIntValue": 14 as Int?,       "uintValue": 15 as UInt,     "optUintValue": UInt?.none
            ]
            let all = nulls ? raw : raw.compactMapValues { $0 }
            switch xform {
            case .none: return TestRow(data: .init(uniqueKeysWithValues: all.map { ("\(prefix)\($0)", $1) }))
            case .some(false): return TestRow(data: .init(uniqueKeysWithValues: all.map { ("\(prefix)\($0.convertedToSnakeCase)", $1) }))
            case .some(true): return TestRow(data: .init(uniqueKeysWithValues: all.map { ("\(prefix)\(superCase([SomeCodingKey(stringValue: $0)]).stringValue)", $1) }))
            }
        }

        let model1 = BasicDecModel(
            boolValue: true,  optBoolValue: nil,   stringValue: "hello", optStringValue: "olleh",
            doubleValue: 1.0, optDoubleValue: nil, floatValue: 1.0,      optFloatValue: 0.1,
            int8Value: 1,     optInt8Value: nil,   int16Value: 2,        optInt16Value: 3,
            int32Value: 4,    optInt32Value: nil,  int64Value: 5,        optInt64Value: 6,
            uint8Value: 7,    optUint8Value: nil,  uint16Value: 8,       optUint16Value: 9,
            uint32Value: 10,  optUint32Value: nil, uint64Value: 11,      optUint64Value: 12,
            intValue: 13,     optIntValue: nil,    uintValue: 14,        optUintValue: 15
        )
        let model2 = BasicDecModel(
            boolValue: true,  optBoolValue: false, stringValue: "hello", optStringValue: nil,
            doubleValue: 1.0, optDoubleValue: 0.1, floatValue: 1.0,      optFloatValue: nil,
            int8Value: 1,     optInt8Value: 2,     int16Value: 3,        optInt16Value: nil,
            int32Value: 4,    optInt32Value: 5,    int64Value: 6,        optInt64Value: nil,
            uint8Value: 7,    optUint8Value: 8,    uint16Value: 9,       optUint16Value: nil,
            uint32Value: 10,  optUint32Value: 11,  uint64Value: 12,      optUint64Value: nil,
            intValue: 13,     optIntValue: 14,     uintValue: 15,        optUintValue: nil
        )

        // Model 1 with key strategies
        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: false, xform: nil), using: SQLRowDecoder(keyDecodingStrategy: .useDefaultKeys), outputs: model1)
        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: true, xform: nil), using: SQLRowDecoder(keyDecodingStrategy: .useDefaultKeys), outputs: model1)

        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: false, xform: false), using: SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase), outputs: model1)
        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: true, xform: false), using: SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase), outputs: model1)

        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: false, xform: true), using: SQLRowDecoder(keyDecodingStrategy: .custom({ superCase($0) })), outputs: model1)
        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: true, xform: true), using: SQLRowDecoder(keyDecodingStrategy: .custom({ superCase($0) })), outputs: model1)
        
        // Model 1 with prefix and key strategies
        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: false, xform: nil, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .useDefaultKeys), outputs: model1)
        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: true, xform: nil, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .useDefaultKeys), outputs: model1)

        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: false, xform: false, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .convertFromSnakeCase), outputs: model1)
        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: true, xform: false, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .convertFromSnakeCase), outputs: model1)

        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: false, xform: true, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .custom({ superCase($0) })), outputs: model1)
        XCTAssertDecoding(BasicDecModel.self, from: row1(nulls: true, xform: true, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .custom({ superCase($0) })), outputs: model1)

        // Model 2 with key strategies
        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: false, xform: nil), using: SQLRowDecoder(keyDecodingStrategy: .useDefaultKeys), outputs: model2)
        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: true, xform: nil), using: SQLRowDecoder(keyDecodingStrategy: .useDefaultKeys), outputs: model2)

        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: false, xform: false), using: SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase), outputs: model2)
        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: true, xform: false), using: SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase), outputs: model2)

        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: false, xform: true), using: SQLRowDecoder(keyDecodingStrategy: .custom({ superCase($0) })), outputs: model2)
        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: true, xform: true), using: SQLRowDecoder(keyDecodingStrategy: .custom({ superCase($0) })), outputs: model2)
        
        // Model 2 with prefix and key strategies
        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: false, xform: nil, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .useDefaultKeys), outputs: model2)
        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: true, xform: nil, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .useDefaultKeys), outputs: model2)

        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: false, xform: false, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .convertFromSnakeCase), outputs: model2)
        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: true, xform: false, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .convertFromSnakeCase), outputs: model2)

        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: false, xform: true, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .custom({ superCase($0) })), outputs: model2)
        XCTAssertDecoding(BasicDecModel.self, from: row2(nulls: true, xform: true, prefix: "p_"), using: SQLRowDecoder(prefix: "p_", keyDecodingStrategy: .custom({ superCase($0) })), outputs: model2)
    }
    
    func testDecodeUnkeyedValues() {
        XCTAssertThrowsError(try SQLRowDecoder().decode(Array<UInt8>.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
    }
    
    func testDecodeTopLevelValues() {
        XCTAssertThrowsError(try SQLRowDecoder().decode(Bool.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(String.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(Double.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(Float.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(Int8.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(Int16.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(Int32.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(Int64.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(UInt8.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(UInt16.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(UInt32.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(UInt64.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(Int.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(UInt.self, from: TestRow(data: [:]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
    }
    
    func testDecodeNestedKeyedValues() {
        XCTAssertNoThrow(try SQLRowDecoder().decode(TestDecodableIfPresent.self, from: TestRow(data: ["foo": Date()])))
        XCTAssertNoThrow(try SQLRowDecoder().decode(TestDecodableIfPresent.self, from: TestRow(data: ["foo": Date?.none])))
        XCTAssertNoThrow(try SQLRowDecoder().decode(Dictionary<String, Dictionary<String, String>>.self, from: TestRow(data: ["a": ["b": "c"]])))
        XCTAssertNoThrow(try SQLRowDecoder(keyDecodingStrategy: .convertFromSnakeCase).decode(Dictionary<String, Dictionary<String, String>>.self, from: TestRow(data: ["a": ["b": "c"]])))
        XCTAssertNoThrow(try SQLRowDecoder(keyDecodingStrategy: .custom({ superCase($0) })).decode(Dictionary<String, Dictionary<String, String>>.self, from: TestRow(data: ["A": ["b": "c"]])))
        XCTAssertNoThrow(try SQLRowDecoder().decode(Dictionary<String, Array<String>>.self, from: TestRow(data: ["a": ["b", "c"]])))
        XCTAssertThrowsError(try SQLRowDecoder().decode(TestDecNestedKeyedContainers.self, from: TestRow(data: [:])))  { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(TestDecNestedUnkeyedContainer.self, from: TestRow(data: [:])))  { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertThrowsError(try SQLRowDecoder().decode(TestKeylessSuperDecoder.self, from: TestRow(data: [:])))  { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
        XCTAssertNoThrow(try SQLRowDecoder().decode(TestDecNestedSingleValueContainer.self, from: TestRow(data: ["foo": ["_0": 1, "_1": 1]])))
        XCTAssertNoThrow(try SQLRowDecoder().decode(TestDecNestedSingleValueContainer.self, from: TestRow(data: ["foo": Dictionary<String, Int>?.none])))
        XCTAssertThrowsError(try SQLRowDecoder().decode(TestDecEnum.self, from: TestRow(data: ["foo": Dictionary<String, String>()]))) { XCTAssert($0 is SQLCodingError, "Expected SQLCodingError, got \(String(reflecting: $0))") }
    }
    
    func testDecoderMiscErrorHandling() {
        struct ErroringRow: SQLRow {
            let allColumns: [String]
            func contains(column: String) -> Bool { column == "foo" }
            func decodeNil(column: String) throws -> Bool { throw DecodingError.valueNotFound(Optional<Void>.self, .init(codingPath: [], debugDescription: "")) }
            func decode<D: Decodable>(column: String, as: D.Type) throws -> D { throw DecodingError.valueNotFound(Optional<Void>.self, .init(codingPath: [], debugDescription: "")) }
        }
        XCTAssertThrowsError(try SQLRowDecoder().decode(TestDecodableIfPresent.self, from: ErroringRow(allColumns: ["foo"]))) {
            guard case .valueNotFound(_, let context) = $0 as? DecodingError else {
                return XCTFail("Expected DecodingError.valueNotFound(), got \(String(reflecting: $0))")
            }
            XCTAssertEqual(["foo"], context.codingPath.map(\.stringValue))
        }
        XCTAssertThrowsError(try SQLRowDecoder().decode(TestDecNestedSingleValueContainer.self, from: ErroringRow(allColumns: ["foo"]))) {
            guard case .valueNotFound(_, let context) = $0 as? DecodingError else {
                return XCTFail("Expected DecodingError.valueNotFound(), got \(String(reflecting: $0))")
            }
            XCTAssertEqual(["foo", "foo"], context.codingPath.map(\.stringValue))
        }
        XCTAssertThrowsError(try SQLRowDecoder().decode(TestDecNestedSingleValueContainer?.self, from: ErroringRow(allColumns: ["foo"]))) {
            guard case .valueNotFound(_, let context) = $0 as? DecodingError else {
                return XCTFail("Expected DecodingError.valueNotFound(), got \(String(reflecting: $0))")
            }
            XCTAssertEqual(["foo", "foo"], context.codingPath.map(\.stringValue))
        }
        XCTAssertThrowsError(try SQLRowDecoder().decode([String: String].self, from: ErroringRow(allColumns: ["foo"]))) {
            guard case .valueNotFound(_, let context) = $0 as? DecodingError else {
                return XCTFail("Expected DecodingError.valueNotFound(), got \(String(reflecting: $0))")
            }
            XCTAssertEqual([SomeCodingKey(stringValue: "foo")].map(\.stringValue), context.codingPath.map(\.stringValue))
        }
        XCTAssertThrowsError(try SQLRowDecoder().decode([String: String].self, from: ErroringRow(allColumns: ["b"]))) {
            guard case .keyNotFound(_, let context) = $0 as? DecodingError else {
                return XCTFail("Expected DecodingError.keyNotFound(), got \(String(reflecting: $0))")
            }
            XCTAssertEqual(Array<any CodingKey>().map(\.stringValue), context.codingPath.map(\.stringValue))
        }
    }
}

enum TestDecEnum: Codable {
    /// N.B.: Compiler autosynthesizes a call to `KeyedDecodingContainer.nestedContainer(keyedBy:forKey:)` for this.
    case foo(bar: Bool)
}

struct TestDecodableIfPresent: Decodable {
    let foo: Date?
}

struct TestKeylessSuperDecoder: Decodable {
    let foo: Bool
    
    init(from decoder: any Decoder) throws {
        XCTAssertNil(decoder.userInfo[.init(rawValue: "a")!]) // for completeness of code coverage
        let container = try decoder.container(keyedBy: SomeCodingKey.self)
        let superDecoder = try container.superDecoder()
        let subcontainer = try superDecoder.singleValueContainer()
        self.foo = try subcontainer.decode(Bool.self)
    }
}

struct TestDecNestedUnkeyedContainer: Decodable {
    let foo: Bool
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: SomeCodingKey.self)
        var subcontainer = try container.nestedUnkeyedContainer(forKey: .init(stringValue: "foo"))
        self.foo = try subcontainer.decode(Bool.self)
    }
}

struct TestDecNestedKeyedContainers: Decodable {
    let foo: (Int, Int)
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: SomeCodingKey.self)
        let superDecoder = try container.superDecoder(forKey: .init(stringValue: "foo"))
        let subcontainer = try superDecoder.container(keyedBy: SomeCodingKey.self)
        
        self.foo = (
            try subcontainer.decode(Int.self, forKey: .init(stringValue: "_0")),
            try subcontainer.decode(Int.self, forKey: .init(stringValue: "_1"))
        )
    }
}

struct TestDecNestedSingleValueContainer: Decodable {
    let foo: (Int, Int)?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: SomeCodingKey.self)
        let superDecoder = try container.superDecoder(forKey: .init(stringValue: "foo"))
        let subcontainer = try superDecoder.singleValueContainer()
        
        if subcontainer.decodeNil() {
            self.foo = nil
        } else {
            let value = try subcontainer.decode([String: Int].self)
            self.foo = (value["_0"]!, value["_1"]!)
        }
    }
}

struct BasicDecModel: Codable, Equatable {
    var boolValue: Bool,     optBoolValue: Bool?,       stringValue: String, optStringValue: String?
    var doubleValue: Double, optDoubleValue: Double?,   floatValue: Float,   optFloatValue: Float?
    var int8Value: Int8,     optInt8Value: Int8?,       int16Value: Int16,   optInt16Value: Int16?
    var int32Value: Int32,   optInt32Value: Int32?,     int64Value: Int64,   optInt64Value: Int64?
    var uint8Value: UInt8,   optUint8Value: UInt8?,     uint16Value: UInt16, optUint16Value: UInt16?
    var uint32Value: UInt32, optUint32Value: UInt32?,   uint64Value: UInt64, optUint64Value: UInt64?
    var intValue: Int,       optIntValue: Int?,         uintValue: UInt,     optUintValue: UInt?
}

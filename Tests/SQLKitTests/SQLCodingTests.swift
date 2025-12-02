@testable @_spi(CodableUtilities) import SQLKit
import XCTest
import OrderedCollections

final class SQLCodingTests: XCTestCase {
    var db = TestDatabase()
    
    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }

    // MARK: - Query encoder

    func testCodableWithNillableColumnWithSomeValue() {
        let output = XCTAssertNoThrowWithResult(try self.db
            .insert(into: "gasses")
            .model(Gas(name: "iodine", color: "purple"))
            .advancedSerialize()
        )

        XCTAssertEqual(output?.sql, "INSERT INTO ``gasses`` (``name``, ``color``) VALUES (&1, &2)")
        XCTAssertEqual(output?.binds.count, 2)
        XCTAssertEqual(output?.binds[0] as? String, "iodine")
        XCTAssertEqual(output?.binds[1] as? String, "purple")
    }

    func testCodableWithNillableColumnWithNilValueWithoutNilEncodingStrategy() throws {
        let output = XCTAssertNoThrowWithResult(try self.db
            .insert(into: "gasses")
            .model(Gas(name: "oxygen", color: nil))
            .advancedSerialize()
        )

        XCTAssertEqual(output?.sql, "INSERT INTO ``gasses`` (``name``) VALUES (&1)")
        XCTAssertEqual(output?.binds.count, 1)
        XCTAssertEqual(output?.binds[0] as? String, "oxygen")
    }

    func testCodableWithNillableColumnWithNilValueAndNilEncodingStrategy() throws {
        let output = XCTAssertNoThrowWithResult(try self.db
            .insert(into: "gasses")
            .model(Gas(name: "oxygen", color: nil), nilEncodingStrategy: .asNil)
            .advancedSerialize()
        )

        XCTAssertEqual(output?.sql, "INSERT INTO ``gasses`` (``name``, ``color``) VALUES (&1, NULL)")
        XCTAssertEqual(output?.binds.count, 1)
        XCTAssertEqual(output?.binds[0] as? String, "oxygen")
    }
    
    // MARK: - Models
    
    func testInsertWithEncodableModel() {
        struct TestModelPlain: Codable {
            var id: Int?
            var serial_number: UUID
            var star_id: Int
            var last_known_status: String
        }
        struct TestModelSnakeCase: Codable {
            var id: Int?
            var serialNumber: UUID
            var starId: Int
            var lastKnownStatus: String
        }
        struct TestModelSuperCase: Codable {
            var Id: Int?
            var SerialNumber: UUID
            var StarId: Int
            var LastKnownStatus: String
        }
        
        @Sendable
        func handleSuperCase(_ path: [any CodingKey]) -> any CodingKey {
            SomeCodingKey(stringValue: path.last!.stringValue.decapitalized.convertedToSnakeCase)
        }
        
        let snakeEncoder = SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase, nilEncodingStrategy: .asNil)
        let superEncoder = SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .custom({ handleSuperCase($0) }), nilEncodingStrategy: .asNil)
        
        db._dialect.upsertSyntax = .standard

        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3)"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3)"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder),
            is: "INSERT INTO ``jumpgates`` (``p_id``, ``p_serial_number``, ``p_star_id``, ``p_last_known_status``) VALUES (NULL, &1, &2, &3)"
        )

        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO NOTHING"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO NOTHING"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO ``jumpgates`` (``p_id``, ``p_serial_number``, ``p_star_id``, ``p_last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO NOTHING"
        )

        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates")
                .model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil)
                .onConflict(with: ["star_id"]) { try $0
                    .set(excludedContentOf: TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil)
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO UPDATE SET ``id`` = EXCLUDED.``id``, ``serial_number`` = EXCLUDED.``serial_number``, ``star_id`` = EXCLUDED.``star_id``, ``last_known_status`` = EXCLUDED.``last_known_status``"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates")
                .model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder)
                .onConflict(with: ["star_id"]) { try $0
                    .set(excludedContentOf: TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder)
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO UPDATE SET ``id`` = EXCLUDED.``id``, ``serial_number`` = EXCLUDED.``serial_number``, ``star_id`` = EXCLUDED.``star_id``, ``last_known_status`` = EXCLUDED.``last_known_status``"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates")
                .model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder)
                .onConflict(with: ["p_star_id"]) { try $0
                    .set(excludedContentOf: TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder)
                },
            is: "INSERT INTO ``jumpgates`` (``p_id``, ``p_serial_number``, ``p_star_id``, ``p_last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``p_star_id``) DO UPDATE SET ``p_id`` = EXCLUDED.``p_id``, ``p_serial_number`` = EXCLUDED.``p_serial_number``, ``p_star_id`` = EXCLUDED.``p_star_id``, ``p_last_known_status`` = EXCLUDED.``p_last_known_status``"
        )
    }

    func testInsertWithEncodableModels() {
        struct TestModel: Codable, Equatable {
            var id: Int?
            var serial_number: UUID
            var star_id: Int
            var last_known_status: String
        }

        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates")
                .models([
                    TestModel(serial_number: .init(), star_id: 0, last_known_status: ""),
                    TestModel(serial_number: .init(), star_id: 1, last_known_status: ""),
                ]),
            is: "INSERT INTO ``jumpgates`` (``serial_number``, ``star_id``, ``last_known_status``) VALUES (&1, &2, &3), (&4, &5, &6)"
        )
        
        let models = [
            TestModel(id: 0, serial_number: .init(), star_id: 0, last_known_status: ""),
            TestModel(serial_number: .init(), star_id: 1, last_known_status: ""),
        ]
        
        XCTAssertThrowsError(try self.db.insert(into: "jumpgates").models(models)) {
            guard case let .invalidValue(value, context) = $0 as? EncodingError else {
                return XCTFail("Expected EncodingError.invalidValue, but got \(String(reflecting: $0))")
            }
            XCTAssertEqual(value as? TestModel, models[1])
            XCTAssert(context.codingPath.isEmpty)
        }
    }
    
    func testUpdateWithEncodableModel() {
        struct TestModelPlain: Codable {
            var id: Int?
            var serial_number: UUID
            var star_id: Int
            var last_known_status: String
        }
        struct TestModelSnakeCase: Codable {
            var id: Int?
            var serialNumber: UUID
            var starId: Int
            var lastKnownStatus: String
        }
        struct TestModelSuperCase: Codable {
            var Id: Int?
            var SerialNumber: UUID
            var StarId: Int
            var LastKnownStatus: String
        }
        
        @Sendable
        func handleSuperCase(_ path: [any CodingKey]) -> any CodingKey {
            SomeCodingKey(stringValue: path.last!.stringValue.decapitalized.convertedToSnakeCase)
        }
        
        let snakeEncoder = SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase, nilEncodingStrategy: .asNil)
        let superEncoder = SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .custom({ handleSuperCase($0) }), nilEncodingStrategy: .asNil)
        
        XCTAssertSerialization(
            of: try self.db.update("jumpgates").set(model: TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: "")),
            is: "UPDATE ``jumpgates`` SET ``serial_number`` = &1, ``star_id`` = &2, ``last_known_status`` = &3"
        )
        XCTAssertSerialization(
            of: try self.db.update("jumpgates").set(model: TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil),
            is: "UPDATE ``jumpgates`` SET ``id`` = NULL, ``serial_number`` = &1, ``star_id`` = &2, ``last_known_status`` = &3"
        )
        XCTAssertSerialization(
            of: try self.db.update("jumpgates").set(model: TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder),
            is: "UPDATE ``jumpgates`` SET ``id`` = NULL, ``serial_number`` = &1, ``star_id`` = &2, ``last_known_status`` = &3"
        )
        XCTAssertSerialization(
            of: try self.db.update("jumpgates").set(model: TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder),
            is: "UPDATE ``jumpgates`` SET ``p_id`` = NULL, ``p_serial_number`` = &1, ``p_star_id`` = &2, ``p_last_known_status`` = &3"
        )
    }
    
    func testRowModelDecode() {
        struct Foo: Codable, Equatable {
            let a: String
        }
        let row = TestRow(data: ["a": "b"])
        XCTAssertEqual(try row.decode(model: Foo.self, keyDecodingStrategy: .useDefaultKeys), Foo(a: "b"))
    }

    func testHandleCodeCoverageCompleteness() {
        /// There are certain code paths which can never be executed under any meaningful circumstances, but the
        /// compiler cannot determine this statically. This test performs deliberately pointless operations in order
        /// to mark those paths as covered by tests.
        XCTAssertNil(NeverKey.init(stringValue: ""))
        XCTAssertNil(NeverKey.init(intValue: 0))
        XCTAssert(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).codingPath.isEmpty)
        XCTAssert(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).userInfo.isEmpty)
        XCTAssertEqual(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).count, 0)
        XCTAssertThrowsError(try FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).encodeNil())
        XCTAssertThrowsError(try FailureEncoder<SomeCodingKey>(SQLCodingError.unsupportedOperation("", codingPath: [])).encodeNil(forKey: .init(stringValue: "")))
        XCTAssertNotNil(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).superEncoder())
        XCTAssertNotNil(FailureEncoder<SomeCodingKey>(SQLCodingError.unsupportedOperation("", codingPath: [])).superEncoder(forKey: .init(stringValue: "")))
        XCTAssertNotNil(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).unkeyedContainer())
        XCTAssertNotNil(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).nestedUnkeyedContainer())
        XCTAssertNotNil(FailureEncoder<SomeCodingKey>(SQLCodingError.unsupportedOperation("", codingPath: [])).nestedUnkeyedContainer(forKey: .init(stringValue: "")))
        XCTAssertNotNil(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).container(keyedBy: NeverKey.self))
        XCTAssertNotNil(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).nestedContainer(keyedBy: NeverKey.self))
        XCTAssertNotNil(FailureEncoder<SomeCodingKey>(SQLCodingError.unsupportedOperation("", codingPath: [])).nestedContainer(keyedBy: NeverKey.self, forKey: .init(stringValue: "")))
        XCTAssertNotNil(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "")).under(path: []))
        XCTAssertNotNil(DecodingError.typeMismatch(Void.self, .init(codingPath: [], debugDescription: "")).under(path: []))
        XCTAssertNotNil(DecodingError.keyNotFound(SomeCodingKey(stringValue: ""), .init(codingPath: [], debugDescription: "")).under(path: []))
        XCTAssertNoThrow(try JSONDecoder().decode(FakeSendableCodable<Bool>.self, from: JSONEncoder().encode(FakeSendableCodable(true))))
        XCTAssertNotEqual(FakeSendableCodable(true), FakeSendableCodable(false))
        XCTAssertFalse(Set([FakeSendableCodable(true)]).isEmpty)
        XCTAssertEqual(FakeSendableCodable(true).description, true.description)
        XCTAssertEqual(FakeSendableCodable("").debugDescription, "".debugDescription)
        XCTAssertFalse(SQLCodingError.unsupportedOperation("", codingPath: [SomeCodingKey(stringValue: "")]).description.isEmpty)
        XCTAssertEqual(SomeCodingKey(intValue: 0).intValue, 0)
    }
}

struct Gas: Codable {
    let name: String
    let color: String?
}

struct Foo: Codable {
    let id: UUID
    let foo: Int
    let bar: Double?
    let baz: String
    let waldoFredID: Int?
}

func superCase(_ path: [any CodingKey]) -> any CodingKey {
    SomeCodingKey(stringValue: path.last!.stringValue.encapitalized)
}

extension SQLKit.SQLLiteral: Swift.Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.all, .all), (.`default`, .`default`), (.null, .null):          return true
        case (.boolean(let lbool), .boolean(let rbool)) where lbool == rbool: return true
        case (.numeric(let lnum),  .numeric(let rnum))  where lnum == rnum:   return true
        case (.string(let lstr),   .string(let rstr))   where lstr == rstr:   return true
        default: return false
        }
    }
}

extension SQLKit.SQLBind: Swift.Equatable {
    // Don't do this. This is horrible.
    public static func == (lhs: Self, rhs: Self) -> Bool { (try? JSONEncoder().encode(lhs.encodable) == JSONEncoder().encode(rhs.encodable)) ?? false }
}

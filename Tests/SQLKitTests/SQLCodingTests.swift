#if canImport(FoundationEssentials)
import struct FoundationEssentials.UUID
import class FoundationEssentials.JSONDecoder
import class FoundationEssentials.JSONEncoder
#else
import struct Foundation.UUID
import class Foundation.JSONDecoder
import class Foundation.JSONEncoder
#endif
import OrderedCollections
@testable @_spi(CodableUtilities) public import SQLKit
import Testing

@Suite("Codable tests")
struct CodableTests {
    // MARK: - Query encoder

    @Test("Codable with nillable column with some value")
    func codableWithNillableColumnWithSomeValue() {
        let db = TestDatabase()
        #expect(throws: Never.self) {
            let output = try db
                .insert(into: "gasses")
                .model(Gas(name: "iodine", color: "purple"))
                .advancedSerialize()

            #expect(output.sql == "INSERT INTO ``gasses`` (``name``, ``color``) VALUES (&1, &2)")
            #expect(output.binds.count == 2)
            #expect(output.binds[0] as? String == "iodine")
            #expect(output.binds[1] as? String == "purple")
        }
    }

    @Test("Codable with nillable column with nil value without NilEncodingStrategy")
    func codableWithNillableColumnWithNilValueWithoutNilEncodingStrategy() throws {
        let db = TestDatabase()
        #expect(throws: Never.self) {
            let output = try db
                .insert(into: "gasses")
                .model(Gas(name: "oxygen", color: nil))
                .advancedSerialize()

            #expect(output.sql == "INSERT INTO ``gasses`` (``name``) VALUES (&1)")
            #expect(output.binds.count == 1)
            #expect(output.binds[0] as? String == "oxygen")
        }
    }

    @Test("Codable with nillable column with nil value and NilEncodingStrategy")
    func codableWithNillableColumnWithNilValueAndNilEncodingStrategy() throws {
        let db = TestDatabase()
        #expect(throws: Never.self) {
            let output = try db
                .insert(into: "gasses")
                .model(Gas(name: "oxygen", color: nil), nilEncodingStrategy: .asNil)
                .advancedSerialize()

            #expect(output.sql == "INSERT INTO ``gasses`` (``name``, ``color``) VALUES (&1, NULL)")
            #expect(output.binds.count == 1)
            #expect(output.binds[0] as? String == "oxygen")
        }
    }

    // MARK: - Models

    @Test("INSERT with Encodable model")
    func insertWithEncodableModel() throws {
        let db = TestDatabase()

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

        try expectSerialization(
            of: try db.insert(into: "jumpgates").model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3)"
        )
        try expectSerialization(
            of: try db.insert(into: "jumpgates").model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3)"
        )
        try expectSerialization(
            of: try db.insert(into: "jumpgates").model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder),
            is: "INSERT INTO ``jumpgates`` (``p_id``, ``p_serial_number``, ``p_star_id``, ``p_last_known_status``) VALUES (NULL, &1, &2, &3)"
        )

        try expectSerialization(
            of: try db.insert(into: "jumpgates").model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO NOTHING"
        )
        try expectSerialization(
            of: try db.insert(into: "jumpgates").model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO NOTHING"
        )
        try expectSerialization(
            of: try db.insert(into: "jumpgates").model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO ``jumpgates`` (``p_id``, ``p_serial_number``, ``p_star_id``, ``p_last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO NOTHING"
        )

        try expectSerialization(
            of: try db.insert(into: "jumpgates")
                .model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil)
                .onConflict(with: ["star_id"]) { try $0
                    .set(excludedContentOf: TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil)
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO UPDATE SET ``id`` = EXCLUDED.``id``, ``serial_number`` = EXCLUDED.``serial_number``, ``star_id`` = EXCLUDED.``star_id``, ``last_known_status`` = EXCLUDED.``last_known_status``"
        )
        try expectSerialization(
            of: try db.insert(into: "jumpgates")
                .model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder)
                .onConflict(with: ["star_id"]) { try $0
                    .set(excludedContentOf: TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder)
                },
            is: "INSERT INTO ``jumpgates`` (``id``, ``serial_number``, ``star_id``, ``last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``star_id``) DO UPDATE SET ``id`` = EXCLUDED.``id``, ``serial_number`` = EXCLUDED.``serial_number``, ``star_id`` = EXCLUDED.``star_id``, ``last_known_status`` = EXCLUDED.``last_known_status``"
        )
        try expectSerialization(
            of: try db.insert(into: "jumpgates")
                .model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder)
                .onConflict(with: ["p_star_id"]) { try $0
                    .set(excludedContentOf: TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder)
                },
            is: "INSERT INTO ``jumpgates`` (``p_id``, ``p_serial_number``, ``p_star_id``, ``p_last_known_status``) VALUES (NULL, &1, &2, &3) ON CONFLICT (``p_star_id``) DO UPDATE SET ``p_id`` = EXCLUDED.``p_id``, ``p_serial_number`` = EXCLUDED.``p_serial_number``, ``p_star_id`` = EXCLUDED.``p_star_id``, ``p_last_known_status`` = EXCLUDED.``p_last_known_status``"
        )
    }

    @Test("INSERT with Encodable models")
    func insertWithEncodableModels() throws {
        let db = TestDatabase()

        struct TestModel: Codable, Equatable {
            var id: Int?
            var serial_number: UUID
            var star_id: Int
            var last_known_status: String
        }

        try expectSerialization(
            of: try db.insert(into: "jumpgates")
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

        let error = #expect(throws: EncodingError.self) { try db.insert(into: "jumpgates").models(models) }
        guard case let .invalidValue(value, context) = error else {
            Issue.record("Expected EncodingError.invalidValue, but got \(String(reflecting: error))")
            return
        }
        #expect(value as? TestModel == models[1])
        #expect(context.codingPath.isEmpty)
    }

    @Test("UPDATE with Encodable model")
    func updateWithEncodableModel() throws {
        let db = TestDatabase()

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

        try expectSerialization(
            of: try db.update("jumpgates").set(model: TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: "")),
            is: "UPDATE ``jumpgates`` SET ``serial_number`` = &1, ``star_id`` = &2, ``last_known_status`` = &3"
        )
        try expectSerialization(
            of: try db.update("jumpgates").set(model: TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil),
            is: "UPDATE ``jumpgates`` SET ``id`` = NULL, ``serial_number`` = &1, ``star_id`` = &2, ``last_known_status`` = &3"
        )
        try expectSerialization(
            of: try db.update("jumpgates").set(model: TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder),
            is: "UPDATE ``jumpgates`` SET ``id`` = NULL, ``serial_number`` = &1, ``star_id`` = &2, ``last_known_status`` = &3"
        )
        try expectSerialization(
            of: try db.update("jumpgates").set(model: TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder),
            is: "UPDATE ``jumpgates`` SET ``p_id`` = NULL, ``p_serial_number`` = &1, ``p_star_id`` = &2, ``p_last_known_status`` = &3"
        )
    }

    @Test("per-row model decode")
    func rowModelDecode() throws {
        struct Foo: Codable, Equatable {
            let a: String
        }
        let row = TestRow(data: ["a": "b"])
        #expect(try row.decode(model: Foo.self, keyDecodingStrategy: .useDefaultKeys) == Foo(a: "b"))
    }

    @Test("code coverage completeness")
    func handleCodeCoverageCompleteness() {
        /// There are certain code paths which can never be executed under any meaningful circumstances, but the
        /// compiler cannot determine this statically. This test performs deliberately pointless operations in order
        /// to mark those paths as covered by tests.
        #expect(NeverKey.init(stringValue: "") == nil)
        #expect(NeverKey.init(intValue: 0) == nil)
        #expect(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).codingPath.isEmpty)
        #expect(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).userInfo.isEmpty)
        #expect(FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).count == 0)
        #expect(throws: (any Error).self) { try FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).encodeNil() }
        #expect(throws: (any Error).self) { try FailureEncoder<SomeCodingKey>(SQLCodingError.unsupportedOperation("", codingPath: [])).encodeNil(forKey: .init(stringValue: "")) }
        #expect(throws: Never.self) { FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).superEncoder() }
        #expect(throws: Never.self) { FailureEncoder<SomeCodingKey>(SQLCodingError.unsupportedOperation("", codingPath: [])).superEncoder(forKey: .init(stringValue: "")) }
        #expect(throws: Never.self) { FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).unkeyedContainer() }
        #expect(throws: Never.self) { FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).nestedUnkeyedContainer() }
        #expect(throws: Never.self) { FailureEncoder<SomeCodingKey>(SQLCodingError.unsupportedOperation("", codingPath: [])).nestedUnkeyedContainer(forKey: .init(stringValue: "")) }
        #expect(throws: Never.self) { FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).container(keyedBy: NeverKey.self) }
        #expect(throws: Never.self) { FailureEncoder(SQLCodingError.unsupportedOperation("", codingPath: [])).nestedContainer(keyedBy: NeverKey.self) }
        #expect(throws: Never.self) { FailureEncoder<SomeCodingKey>(SQLCodingError.unsupportedOperation("", codingPath: [])).nestedContainer(keyedBy: NeverKey.self, forKey: .init(stringValue: "")) }
        #expect(throws: Never.self) { DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "")).under(path: []) }
        #expect(throws: Never.self) { DecodingError.typeMismatch(Void.self, .init(codingPath: [], debugDescription: "")).under(path: []) }
        #expect(throws: Never.self) { DecodingError.keyNotFound(SomeCodingKey(stringValue: ""), .init(codingPath: [], debugDescription: "")).under(path: []) }
        #expect(throws: Never.self) { try JSONDecoder().decode(FakeSendableCodable<Bool>.self, from: JSONEncoder().encode(FakeSendableCodable(true))) }
        #expect(FakeSendableCodable(true) != FakeSendableCodable(false))
        #expect(!Set([FakeSendableCodable(true)]).isEmpty)
        #expect(FakeSendableCodable(true).description == true.description)
        #expect(FakeSendableCodable("").debugDescription == "".debugDescription)
        #expect(!SQLCodingError.unsupportedOperation("", codingPath: [SomeCodingKey(stringValue: "")]).description.isEmpty)
        #expect(SomeCodingKey(intValue: 0).intValue == 0)
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

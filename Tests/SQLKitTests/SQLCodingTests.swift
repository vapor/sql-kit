@testable import SQLKit
import XCTest

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

    // MARK: - Row Decoder
    
    func testSQLRowDecoderPlain() {
        let row = TestRow(data: [
            "id": UUID(),
            "foo": 42,
            "bar": Double?.none,
            "baz": "vapor",
            "waldoFredID": 2015,
        ])
        
        if let foo = XCTAssertNoThrowWithResult(try row.decode(model: Foo.self)) {
            XCTAssertEqual(foo.id,          row.data["id"] as? UUID)
            XCTAssertEqual(foo.foo,         row.data["foo"] as? Int)
            XCTAssertEqual(foo.bar,         row.data["bar"] as? Double?)
            XCTAssertEqual(foo.baz,         row.data["baz"] as? String)
            XCTAssertEqual(foo.waldoFredID, row.data["waldoFredID"] as? Int)
        }
    }
    
    func testSQLRowDecoderPrefixed() {
        let row = TestRow(data: [
            "foos_id": UUID(),
            "foos_foo": 42,
            "foos_bar": Double?.none,
            "foos_baz": "vapor",
            "foos_waldoFredID": 2015,
        ])

        if let foo = XCTAssertNoThrowWithResult(try row.decode(model: Foo.self, prefix: "foos_")) {
            XCTAssertEqual(foo.id,          row.data["foos_id"] as? UUID)
            XCTAssertEqual(foo.foo,         row.data["foos_foo"] as? Int)
            XCTAssertEqual(foo.bar,         row.data["foos_bar"] as? Double?)
            XCTAssertEqual(foo.baz,         row.data["foos_baz"] as? String)
            XCTAssertEqual(foo.waldoFredID, row.data["foos_waldoFredID"] as? Int)
        }
    }
    
    func testSQLRowDecoderSnakeCase() {
        let row = TestRow(data: [
            "id": UUID(),
            "foo": 42,
            "bar": Double?.none,
            "baz": "vapor",
            "waldo_fred_iD": 2015,
        ])

        if let foo = XCTAssertNoThrowWithResult(try row.decode(model: Foo.self, keyDecodingStrategy: .convertFromSnakeCase)) {
            XCTAssertEqual(foo.id,          row.data["id"] as? UUID)
            XCTAssertEqual(foo.foo,         row.data["foo"] as? Int)
            XCTAssertEqual(foo.bar,         row.data["bar"] as? Double?)
            XCTAssertEqual(foo.baz,         row.data["baz"] as? String)
            XCTAssertEqual(foo.waldoFredID, row.data["waldo_fred_iD"] as? Int)
        }
    }
    
    func testSQLRowDecoderCustomKeyDecoding() {
        let row = TestRow(data: [
            "id": UUID(),
            "foo": 42,
            "bar": Double?.none,
            "baz": "vapor",
            "waldoFred_Id": 2015,
        ])

        @Sendable
        func decodeIDTo_Id(_ keys: [any CodingKey]) -> any CodingKey {
            let keyString = keys.last!.stringValue

            return keyString.hasSuffix("ID") ? SomeCodingKey(stringValue: keyString.dropLast("ID".count) + "_Id") : keys.last!
        }
        
        if let foo = XCTAssertNoThrowWithResult(try row.decode(model: Foo.self, keyDecodingStrategy: .custom(decodeIDTo_Id))) {
            XCTAssertEqual(foo.id,          row.data["id"] as? UUID)
            XCTAssertEqual(foo.foo,         row.data["foo"] as? Int)
            XCTAssertEqual(foo.bar,         row.data["bar"] as? Double?)
            XCTAssertEqual(foo.baz,         row.data["baz"] as? String)
            XCTAssertEqual(foo.waldoFredID, row.data["waldoFred_Id"] as? Int)
        }
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

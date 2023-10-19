import SQLKit
import XCTest

final class SQLCodingTests: XCTestCase {
    var db: TestDatabase!
    
    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    override func setUp() {
        super.setUp()
        self.db = .init()
    }

    // MARK: Query encoder

    func testCodableWithNillableColumnWithSomeValue() {
        let output = XCTAssertNoThrowWithResult(try self.db
            .insert(into: "gasses")
            .model(Gas(name: "iodine", color: "purple"))
            .advancedSerialize()
        )

        XCTAssertEqual(output?.sql, "INSERT INTO `gasses` (`name`, `color`) VALUES (?, ?)")
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

        XCTAssertEqual(output?.sql, "INSERT INTO `gasses` (`name`) VALUES (?)")
        XCTAssertEqual(output?.binds.count, 1)
        XCTAssertEqual(output?.binds[0] as? String, "oxygen")
    }

    func testCodableWithNillableColumnWithNilValueAndNilEncodingStrategy() throws {
        let output = XCTAssertNoThrowWithResult(try self.db
            .insert(into: "gasses")
            .model(Gas(name: "oxygen", color: nil), nilEncodingStrategy: .asNil)
            .advancedSerialize()
        )

        XCTAssertEqual(output?.sql, "INSERT INTO `gasses` (`name`, `color`) VALUES (?, NULL)")
        XCTAssertEqual(output?.binds.count, 1)
        XCTAssertEqual(output?.binds[0] as? String, "oxygen")
    }

    // MARK: Row Decoder
    
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
            "waldo_fred_ID": 2015,
        ])

        if let foo = XCTAssertNoThrowWithResult(try row.decode(model: Foo.self, keyDecodingStrategy: .convertFromSnakeCase)) {
            XCTAssertEqual(foo.id,          row.data["id"] as? UUID)
            XCTAssertEqual(foo.foo,         row.data["foo"] as? Int)
            XCTAssertEqual(foo.bar,         row.data["bar"] as? Double?)
            XCTAssertEqual(foo.baz,         row.data["baz"] as? String)
            XCTAssertEqual(foo.waldoFredID, row.data["waldo_fred_ID"] as? Int)
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
        func decode_IdToID(_ keys: [any CodingKey]) -> any CodingKey {
            let keyString = keys.last!.stringValue

            return keyString.hasSuffix("_Id") ? SomeCodingKey(stringValue: keyString.dropLast("_Id".count) + "ID") : keys.last!
        }
        
        if let foo = XCTAssertNoThrowWithResult(try row.decode(model: Foo.self, keyDecodingStrategy: .custom(decode_IdToID))) {
            XCTAssertEqual(foo.id,          row.data["id"] as? UUID)
            XCTAssertEqual(foo.foo,         row.data["foo"] as? Int)
            XCTAssertEqual(foo.bar,         row.data["bar"] as? Double?)
            XCTAssertEqual(foo.baz,         row.data["baz"] as? String)
            XCTAssertEqual(foo.waldoFredID, row.data["waldoFred_Id"] as? Int)
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

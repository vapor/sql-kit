import SQL
import XCTest

final class SerializationTests: XCTestCase {
    func testDMLPredicateNull() {
        assert(
            query: .select([.all], from: "users", where: "name" == .null),
            equal: "SELECT * FROM `users` WHERE `name` IS NULL"
        )
    }
    
    func testDMLPredicateAnd() {
        assert(
            query: .select([.all], from: "users", where: "name" == .null && "id" == .null),
            equal: "SELECT * FROM `users` WHERE (`name` IS NULL AND `id` IS NULL)"
        )
    }
    
    func testDDLCreate() {
        assert(
            query: .create("users", columns: [
                .column("ID", .dataType("INTEGER", attributes: ["PRIMARY KEY"])),
                .column("name", .dataType("TEXT")),
            ]),
            equal: "CREATE TABLE `users` (`ID` INTEGER PRIMARY KEY, `name` TEXT)"
        )
    }
    func testDDLCreateConstraints() {
        assert(
            query: .create("users", columns: [
                .column("id", .dataType("INTEGER", attributes: ["PRIMARY KEY"])),
                .column("name", .dataType("TEXT")),
            ], constraints: [
                .foreignKey(from: "id", to: .init(table: "orgs", name: "userID"))
            ]),
            equal: "CREATE TABLE `users` (`id` INTEGER PRIMARY KEY, `name` TEXT, CONSTRAINT `fk:id+orgs.userID` FOREIGN KEY (`id`) REFERENCES `orgs` (`userID`))"
        )
    }

    static let allTests = [
        ("testDMLPredicateNull", testDMLPredicateNull),
        ("testDMLPredicateAnd", testDMLPredicateAnd),
        ("testDDLCreate", testDDLCreate),
        ("testDDLCreateConstraints", testDDLCreateConstraints),
    ]
}

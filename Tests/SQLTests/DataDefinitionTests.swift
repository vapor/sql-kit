import SQL
import XCTest

final class DataDefinitionTests: XCTestCase {
    func testCreate() {
        var columns: [DataDefinitionColumn] = []

        let id = DataDefinitionColumn(name: "id", dataType: "UUID", attributes: ["PRIMARY KEY"])
        columns.append(id)

        let name = DataDefinitionColumn(name: "name", dataType: "STRING", attributes: ["NOT NULL"])
        columns.append(name)

        let age = DataDefinitionColumn(name: "age", dataType: "INT", attributes: ["NOT NULL"])
        columns.append(age)

        let create = DataDefinitionQuery(statement: .create, table: "users", addColumns: columns)
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: create),
            "CREATE TABLE `users` (`id` UUID PRIMARY KEY, `name` STRING NOT NULL, `age` INT NOT NULL)"
        )
    }

    func testDrop() {
        let drop = DataDefinitionQuery(statement: .drop, table: "users")
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: drop),
            "DROP TABLE `users`"
        )

    }

    func testForeignKeys() {
        var create = DataDefinitionQuery(statement: .create, table: "users")
        create.addColumns.append(.init(name: "id", dataType: "INT"))
        create.addColumns.append(.init(name: "name", dataType: "TEXT"))
        let fk = DataDefinitionForeignKey(
            name: "_id_fk",
            local: DataColumn(table: "users", name: "id"),
            foreign: DataColumn(table: "pets", name: "user_id"),
            onUpdate: .cascade,
            onDelete: .restrict
        )
        create.addForeignKeys.append(fk)

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: create),
            "CREATE TABLE `users` (`id` INT, `name` TEXT, FOREIGN KEY `users` (`id`) REFERENCES `pets` (`user_id`) ON UPDATE CASCADE ON DELETE RESTRICT)"
        )
    }

    static let allTests = [
        ("testCreate", testCreate),
        ("testDrop", testDrop),
        ("testForeignKeys", testForeignKeys),
    ]
}


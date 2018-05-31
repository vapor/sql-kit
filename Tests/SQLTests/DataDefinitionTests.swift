import SQL
import XCTest

final class DataDefinitionTests: XCTestCase {
    func testCreate() {
        var columns: [DataDefinitionColumn] = []

        let id = DataDefinitionColumn(name: "id", dataType: .init(name: "UUID", attributes: ["PRIMARY KEY"]))
        columns.append(id)

        let name = DataDefinitionColumn(name: "name", dataType:  .init(name: "STRING", attributes: ["NOT NULL"]))
        columns.append(name)

        let age = DataDefinitionColumn(name: "age", dataType:  .init(name: "INT", attributes: ["NOT NULL"]))
        columns.append(age)

        let create = DataDefinitionQuery(statement: .create, table: "users", createColumns: columns)
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
        create.createColumns.append(.init(name: "id", dataType: .init(name: "INT")))
        create.createColumns.append(.init(name: "name", dataType: .init(name: "TEXT")))
        let fk = DataDefinitionForeignKey(
            local: .init(table: "users", name: "id"),
            foreign: .init(table: "pets", name: "user_id"),
            onUpdate: .cascade,
            onDelete: .restrict
        )
        create.createConstraints.append(.foreignKey(fk))

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: create),
            "CREATE TABLE `users` (`id` INT, `name` TEXT, CONSTRAINT `fk:users.id+pets.user_id` FOREIGN KEY `users` (`id`) REFERENCES `pets` (`user_id`) ON UPDATE CASCADE ON DELETE RESTRICT)"
        )
    }

    static let allTests = [
        ("testCreate", testCreate),
        ("testDrop", testDrop),
        ("testForeignKeys", testForeignKeys),
    ]
}


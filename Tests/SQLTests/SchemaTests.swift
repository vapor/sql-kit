import SQL
import XCTest

final class SchemaTests: XCTestCase {
    func testCreate() {
        var columns: [SchemaColumn] = []

        let id = SchemaColumn(name: "id", dataType: "UUID PRIMARY KEY")
        columns.append(id)

        let name = SchemaColumn(name: "name", dataType: "STRING NOT NULL")
        columns.append(name)

        let age = SchemaColumn(name: "age", dataType: "INT NOT NULL")
        columns.append(age)

        let create = SchemaQuery(statement: .create, table: "users", addColumns: columns)
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(schema: create),
            "CREATE TABLE `users` (`id` UUID PRIMARY KEY, `name` STRING NOT NULL, `age` INT NOT NULL)"
        )
    }

    func testDrop() {
        let drop = SchemaQuery(statement: .drop, table: "users")
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(schema: drop),
            "DROP TABLE `users`"
        )

    }

    func testForeignKeys() {
        var create = SchemaQuery(statement: .create, table: "users")
        create.addColumns.append(.init(name: "id", dataType: "INT"))
        create.addColumns.append(.init(name: "name", dataType: "TEXT"))
        let fk = SchemaForeignKey(
            name: "_id_fk",
            local: DataColumn(table: "users", name: "id"),
            foreign: DataColumn(table: "pets", name: "user_id"),
            onUpdate: .cascade,
            onDelete: .restrict
        )
        create.addForeignKeys.append(fk)

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(schema: create),
            "CREATE TABLE `users` (`id` INT, `name` TEXT, FOREIGN KEY `users` (`id`) REFERENCES `pets` (`user_id`) ON UPDATE CASCADE ON DELETE RESTRICT)"
        )
    }

    static let allTests = [
        ("testCreate", testCreate),
        ("testDrop", testDrop),
        ("testForeignKeys", testForeignKeys),
    ]
}


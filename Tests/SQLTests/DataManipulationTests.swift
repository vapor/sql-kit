import SQL
import XCTest

final class DataManipulationTests: XCTestCase {
    func testInsert() {
        var insert = DataManipulationQuery(statement: .insert, table: "foo")
        insert.columns.append("name")
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: insert),
            "INSERT INTO `foo` (`name`) VALUES (?)"
        )
    }

    func testUpdate() {
        var insert = DataManipulationQuery(statement: .update, table: "foo")
        insert.columns.append("name")
        insert.columns.append(.init(column: "bar", value: .column("baz")))
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: insert),
            "UPDATE `foo` SET `name` = ?, `bar` = `baz`"
        )
    }

    func testDelete() {
        var insert = DataManipulationQuery(statement: .delete, table: "foo")
        insert.predicates.append(.predicate(.init(column: "name", comparison: .equal)))
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: insert),
            "DELETE FROM `foo` WHERE (`name` = ?)"
        )
    }

    static let allTests = [
        ("testInsert", testInsert),
        ("testUpdate", testUpdate),
        ("testDelete", testDelete),
    ]
}

import SQL
import XCTest

final class DataManipulationTests: XCTestCase {
    func testInsert() {
        var insert = DataManipulationQuery(statement: .insert(), table: "foo")
        insert.columns.append(.init(column: "name", value: .bind("vapor")))
        let (sql, _) = GeneralSQLSerializer.shared.serialize(query: insert)
        XCTAssertEqual(sql, "INSERT INTO `foo` (`name`) VALUES (?)")
    }

    func testUpdate() {
        var insert = DataManipulationQuery(statement: .update(), table: "foo")
        insert.columns.append(.init(column: "name", value: .bind("vapor")))
        insert.columns.append(.init(column: "bar", value: .column("baz")))
        let (sql, _) = GeneralSQLSerializer.shared.serialize(query: insert)
        XCTAssertEqual(sql, "UPDATE `foo` SET `name` = ?, `bar` = `baz`")
    }

    func testDelete() {
        var insert = DataManipulationQuery(statement: .delete(), table: "foo")
        insert.predicates.append(.predicate(.init(column: "name", comparison: .equal, value: .bind("vapor"))))
        let (sql, _) = GeneralSQLSerializer.shared.serialize(query: insert)
        XCTAssertEqual(sql, "DELETE FROM `foo` WHERE (`name` = ?)")
    }

    static let allTests = [
        ("testInsert", testInsert),
        ("testUpdate", testUpdate),
        ("testDelete", testDelete),
    ]
}

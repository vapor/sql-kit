import SQL
import XCTest

final class DataQueryTests: XCTestCase {
    func testBasicSelectStar() {
        let select = DataQuery(table: "foo")
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT * FROM `foo`"
        )
    }

    func testCustomColumnSelect() {
        let select = DataQuery(table: "foo", columns: [
            .column(DataColumn(table: "foo", name: "d"), key: nil),
            .column(DataColumn(table: "foo", name: "l"), key: nil)
            ]
        )

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT `foo`.`d`, `foo`.`l` FROM `foo`"
        )
    }
    
    func testCustomColumnSelectAll() {
        let select = DataQuery(table: "foo", columns: [
            .tableAll(table: "foo")
            ]
        )
        
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT `foo`.* FROM `foo`"
        )
    }

    func testSelectWithPredicates() {
        var select = DataQuery(table: "foo")

        let predicateA = DataPredicate(
            column: DataColumn(name: "id"),
            comparison: .equal,
            value: .placeholder
        )
        select.predicates.append(.predicate(predicateA))

        let predicateB = DataPredicate(
            column: DataColumn(table: "foo", name: "name"),
            comparison: .equal,
            value: .placeholder
        )
        select.predicates.append(.predicate(predicateB))

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT * FROM `foo` WHERE (`id` = ? AND `foo`.`name` = ?)"
        )
    }

    func testSelectWithGroupByColumn() {
        var select = DataQuery(table: "foo")

        select.groupBys = [DataGroupBy.column(DataColumn(table: "foo", name: "name"))]

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT * FROM `foo` GROUP BY `foo`.`name`"
        )
    }

    func testSelectWithCustomGroupBy() {
        var select = DataQuery(table: "foo")

        let column = DataComputedColumn(function: "YEAR", columns: [.init(table: "foo", name: "date")])
        select.groupBys = [.computed(column)]

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT * FROM `foo` GROUP BY YEAR(`foo`.`date`)"
        )
    }

    func testSelectWithMultipleGroupBy() {
        var select = DataQuery(table: "foo")

        let column = DataComputedColumn(function: "YEAR", columns: [.init(table: "foo", name: "date")])
        select.groupBys = [
            .computed(column),
            .column(DataColumn(table: "foo", name: "name"))
        ]

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT * FROM `foo` GROUP BY YEAR(`foo`.`date`), `foo`.`name`"
        )
    }

    func testSelectWithJoins() {
        var select = DataQuery(table: "foo")

        let joinA = DataJoin(
            method: .inner,
            local: DataColumn(table: "foo", name: "id"),
            foreign: DataColumn(table: "bar", name: "foo_id")
        )
        select.joins.append(joinA)

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT * FROM `foo` JOIN `bar` ON `foo`.`id` = `bar`.`foo_id`"
        )
    }

    func testSubsetEdgecases() {
        var select = DataQuery(table: "foo")
        select.predicates.append(.predicate(.init(column: "a", comparison: .notIn, value: .placeholders(count: 0))))
        select.predicates.append(.predicate(.init(column: "b", comparison: .in, value: .placeholders(count: 0))))
        select.predicates.append(.predicate(.init(column: "c", comparison: .notIn, value: .placeholders(count: 1))))
        select.predicates.append(.predicate(.init(column: "d", comparison: .in, value: .placeholders(count: 1))))
        select.predicates.append(.predicate(.init(column: "e", comparison: .notIn, value: .placeholders(count: 2))))
        select.predicates.append(.predicate(.init(column: "f", comparison: .in, value: .placeholders(count: 2))))

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(query: select),
            "SELECT * FROM `foo` WHERE (1 AND 0 AND `c` != ? AND `d` = ? AND `e` NOT IN (?, ?) AND `f` IN (?, ?))"
        )
    }

    func testDocs() {
        do {
            var users = DataQuery(table: "users")
            let name = DataPredicate(column: "name", comparison: .equal, value: .placeholder)
            users.predicates.append(.predicate(name))
            XCTAssertEqual(
                GeneralSQLSerializer.shared.serialize(query: users),
                "SELECT * FROM `users` WHERE (`name` = ?)"
            )
        }
        do {
            var users = DataManipulationQuery(statement: .insert, table: "users")

            let name = DataManipulationColumn(column: "name", value: .placeholder)
            users.columns.append(name)

            XCTAssertEqual(
                GeneralSQLSerializer.shared.serialize(query: users),
                "INSERT INTO `users` (`name`) VALUES (?)"
            )

            users.statement = .update

            XCTAssertEqual(
                GeneralSQLSerializer.shared.serialize(query: users),
                "UPDATE `users` SET `name` = ?"
            )
        }

        do {
            var users = DataDefinitionQuery(statement: .create, table: "users")

            let id = DataDefinitionColumn(name: "id", dataType: "INTEGER", attributes: ["PRIMARY KEY"])
            users.addColumns.append(id)

            let name = DataDefinitionColumn(name: "name", dataType: "TEXT")
            users.addColumns.append(name)

            XCTAssertEqual(
                GeneralSQLSerializer.shared.serialize(query: users),
                "CREATE TABLE `users` (`id` INTEGER PRIMARY KEY, `name` TEXT)"
            )
        }

        final class PostgreSQLSerializer: SQLSerializer {
            var count: Int
            init() {
                self.count = 1
            }
            func makePlaceholder() -> String {
                defer { count += 1 }
                return "$\(count)"
            }
        }
        do {

            var users = DataQuery(table: "users")
            let name = DataPredicate(column: "name", comparison: .equal, value: .placeholder)
            users.predicates.append(.predicate(name))
            XCTAssertEqual(
                PostgreSQLSerializer().serialize(query: users),
                "SELECT * FROM `users` WHERE (`name` = $1)"
            )
        }
    }

    static let allTests = [
        ("testBasicSelectStar", testBasicSelectStar),
        ("testSelectWithPredicates", testSelectWithPredicates),
        ("testSelectWithJoins", testSelectWithJoins),
        ("testSubsetEdgecases", testSubsetEdgecases),
    ]
}

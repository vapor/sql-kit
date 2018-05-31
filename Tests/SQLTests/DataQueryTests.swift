import SQL
import XCTest

@discardableResult
func assert(query: Query, equal sql: String, file: StaticString = #file, line: UInt = #line) -> Binds {
    var binds: Binds = .init()
    XCTAssertEqual(GeneralSQLSerializer.shared.serialize(query: query, binds: &binds), sql, file: file, line: line)
    return binds
}

final class DataQueryTests: XCTestCase {
    func testPredicateNull() {
        assert(
            query: .select(.all, from: "users", where: "name" == .null),
            equal: "SELECT * FROM `users` WHERE `name` IS NULL"
        )
    }
    
    func testPredicateAnd() {
        assert(
            query: .select(.all, from: "users", where: "name" == .null && "id" == .null),
            equal: "SELECT * FROM `users` WHERE (`name` IS NULL AND `id` IS NULL)"
        )
    }
//    func testBasicSelectStar() {
//        let select = DataManipulationQuery(table: "foo")
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql,  "SELECT * FROM `foo`")
//    }
//
//    func testCustomColumnSelect() {
//        let select = DataManipulationQuery(table: "foo", keys: [
//            .column(DataColumn(table: "foo", name: "d"), key: nil),
//            .column(DataColumn(table: "foo", name: "l"), key: nil)
//        ])
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql, "SELECT `foo`.`d`, `foo`.`l` FROM `foo`")
//    }
//
//    func testCustomColumnSelectAll() {
//        let select = DataManipulationQuery(table: "foo", keys: [.all(table: "foo")])
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql, "SELECT `foo`.* FROM `foo`")
//    }
//
//    func testSelectWithPredicates() {
//        var select = DataManipulationQuery(table: "foo")
//
//        let predicateA = DataPredicate(
//            column: DataColumn(name: "id"),
//            comparison: .equal,
//            value: .bind("1")
//        )
//        select.predicates.append(.predicate(predicateA))
//
//        let predicateB = DataPredicate(
//            column: DataColumn(table: "foo", name: "name"),
//            comparison: .equal,
//            value: .bind("2")
//        )
//        select.predicates.append(.predicate(predicateB))
//
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql, "SELECT * FROM `foo` WHERE (`id` = ? AND `foo`.`name` = ?)")
//    }
//
//    func testSelectWithGroupByColumn() {
//        var select = DataManipulationQuery(table: "foo")
//        select.groupBys.append(.column(DataColumn(table: "foo", name: "name")))
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql, "SELECT * FROM `foo` GROUP BY `foo`.`name`")
//    }
//
//    func testSelectWithCustomGroupBy() {
//        var select = DataManipulationQuery(table: "foo")
//        let column = DataComputedColumn(
//            function: "YEAR",
//            keys: [.column(.init(table: "foo", name: "date"), key: nil)]
//        )
//        select.groupBys.append(.computed(column))
//        select.orderBys.append(.init(columns: [DataColumn(table: "foo", name: "name")], direction: .descending))
//
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql, "SELECT * FROM `foo` GROUP BY YEAR(`foo`.`date`) ORDER BY `foo`.`name` DESC")
//    }
//
//    func testSelectWithMultipleGroupBy() {
//        var select = DataManipulationQuery(table: "foo")
//
//        let column = DataComputedColumn(
//            function: "YEAR",
//            keys: [.column(.init(table: "foo", name: "date"), key: nil)]
//        )
//        select.groupBys = [
//            .computed(column),
//            .column(DataColumn(table: "foo", name: "name"))
//        ]
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql, "SELECT * FROM `foo` GROUP BY YEAR(`foo`.`date`), `foo`.`name`")
//    }
//
//    func testSelectWithJoins() {
//        var select = DataManipulationQuery(table: "foo")
//
//        let joinA = DataJoin(
//            method: .inner,
//            local: DataColumn(table: "foo", name: "id"),
//            foreign: DataColumn(table: "bar", name: "foo_id")
//        )
//        select.joins.append(joinA)
//
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql, "SELECT * FROM `foo` JOIN `bar` ON `foo`.`id` = `bar`.`foo_id`")
//    }
//
//    func testSubsetEdgecases() {
//        var select = DataManipulationQuery(table: "foo")
//        select.predicates.append(.predicate(.init(column: "a", comparison: .notIn, value: .binds([]))))
//        select.predicates.append(.predicate(.init(column: "b", comparison: .in, value: .binds([]))))
//        select.predicates.append(.predicate(.init(column: "c", comparison: .notIn, value: .bind("a"))))
//        select.predicates.append(.predicate(.init(column: "d", comparison: .in, value: .bind("a"))))
//        select.predicates.append(.predicate(.init(column: "e", comparison: .notIn, value:.binds(["a", "b"]))))
//        select.predicates.append(.predicate(.init(column: "f", comparison: .in, value: .binds(["a", "b"]))))
//        var binds = Binds()
//        let sql = GeneralSQLSerializer.shared.serialize(query: select, binds: &binds)
//        XCTAssertEqual(sql, "SELECT * FROM `foo` WHERE (1 AND 0 AND `c` != ? AND `d` = ? AND `e` NOT IN (?, ?) AND `f` IN (?, ?))")
//    }
//
//    func testDocs() {
//        do {
//            var users = DataManipulationQuery(table: "users")
//            let name = DataPredicate(column: "name", comparison: .equal, value: .bind("a"))
//            users.predicates.append(.predicate(name))
//            var binds = Binds()
//            let sql = GeneralSQLSerializer.shared.serialize(query: users, binds: &binds)
//            XCTAssertEqual(sql, "SELECT * FROM `users` WHERE (`name` = ?)")
//        }
//        do {
//            var users = DataManipulationQuery(statement: .insert(), table: "users")
//            let name = DataManipulationColumn(column: "name", value: .bind("a"))
//            users.columns.append(name)
//
//            do {
//                var binds = Binds()
//                let sql = GeneralSQLSerializer.shared.serialize(query: users, binds: &binds)
//                XCTAssertEqual(sql, "INSERT INTO `users` (`name`) VALUES (?)")
//            }
//            users.statement = .update()
//            do {
//                var binds = Binds()
//                let sql = GeneralSQLSerializer.shared.serialize(query: users, binds: &binds)
//                XCTAssertEqual(sql, "UPDATE `users` SET `name` = ?")
//            }
//        }
//
//        do {
//            var users = DataDefinitionQuery(statement: .create, table: "users")
//
//            let id = DataDefinitionColumn(name: "id", dataType: .init(name: "INTEGER", attributes: ["PRIMARY KEY"]))
//            users.createColumns.append(id)
//
//            let name = DataDefinitionColumn(name: "name", dataType: "TEXT")
//            users.createColumns.append(name)
//
//            let sql = GeneralSQLSerializer.shared.serialize(query: users)
//            XCTAssertEqual(sql, "CREATE TABLE `users` (`id` INTEGER PRIMARY KEY, `name` TEXT)")
//        }
//
//        final class PostgreSQLSerializer: SQLSerializer {
//            var count: Int
//            init() {
//                self.count = 1
//            }
//            func makePlaceholder() -> String {
//                defer { count += 1 }
//                return "$\(count)"
//            }
//        }
//        do {
//            var users = DataManipulationQuery(table: "users")
//            let name = DataPredicate(column: "name", comparison: .equal, value: .bind("a"))
//            users.predicates.append(.predicate(name))
//            var binds = Binds()
//            let sql = PostgreSQLSerializer().serialize(query: users, binds: &binds)
//            XCTAssertEqual(sql, "SELECT * FROM `users` WHERE (`name` = $1)")
//        }
//    }
//
//    static let allTests = [
//        ("testBasicSelectStar", testBasicSelectStar),
//        ("testSelectWithPredicates", testSelectWithPredicates),
//        ("testSelectWithJoins", testSelectWithJoins),
//        ("testSubsetEdgecases", testSubsetEdgecases),
//        ("testDocs", testDocs),
//    ]
}

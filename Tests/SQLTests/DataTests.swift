import SQL
import XCTest

final class DataTests: XCTestCase {
    func testBasicSelectStar() {
        let select = DataQuery(statement: .select, table: "foo")
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(data: select),
            "SELECT * FROM `foo`"
        )
    }

    func testCustomColumnSelect() {
        let select = DataQuery(statement: .select, table: "foo", columns: [
            DataColumn(table: "foo", name: "d"),
            DataColumn(table: "foo", name: "l")
            ]
        )
        
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(data: select),
            "SELECT `foo`.`d`, `foo`.`l` FROM `foo`"
        )
    }
    
    func testSelectWithPredicates() {
        var select = DataQuery(statement: .select, table: "foo")

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
            GeneralSQLSerializer.shared.serialize(data: select),
            "SELECT * FROM `foo` WHERE (`id` = ? AND `foo`.`name` = ?)"
        )
    }

    func testSelectWithGroupByColumn() {
        var select = DataQuery(statement: .select, table: "foo")
        
        select.groupBys = [DataGroupBy.column(DataColumn(table: "foo", name: "name"))]
        
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(data: select),
            "SELECT * FROM `foo` GROUP BY `foo`.`name`"
        )
    }
    
    func testSelectWithCustomGroupBy() {
        var select = DataQuery(statement: .select, table: "foo")
        
        select.groupBys = [DataGroupBy.custom("YEAR(`foo`.`date`)")]
        
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(data: select),
            "SELECT * FROM `foo` GROUP BY YEAR(`foo`.`date`)"
        )
    }
    
    func testSelectWithMultipleGroupBy() {
        var select = DataQuery(statement: .select, table: "foo")
        
        select.groupBys = [DataGroupBy.custom("YEAR(`foo`.`date`)"), DataGroupBy.column(DataColumn(table: "foo", name: "name"))]
        
        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(data: select),
            "SELECT * FROM `foo` GROUP BY YEAR(`foo`.`date`), `foo`.`name`"
        )
    }
    
    func testSelectWithJoins() {
        var select = DataQuery(statement: .select, table: "foo")

        let joinA = DataJoin(
            method: .inner,
            local: DataColumn(table: "foo", name: "id"),
            foreign: DataColumn(table: "bar", name: "foo_id")
        )
        select.joins.append(joinA)

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(data: select),
            "SELECT * FROM `foo` JOIN `bar` ON `foo`.`id` = `bar`.`foo_id`"
        )
    }

    func testSubsetEdgecases() {
        var select = DataQuery(statement: .select, table: "foo")
        select.predicates.append(.predicate(.init(column: "a", comparison: .notIn, value: .placeholders(count: 0))))
        select.predicates.append(.predicate(.init(column: "b", comparison: .in, value: .placeholders(count: 0))))
        select.predicates.append(.predicate(.init(column: "c", comparison: .notIn, value: .placeholders(count: 1))))
        select.predicates.append(.predicate(.init(column: "d", comparison: .in, value: .placeholders(count: 1))))
        select.predicates.append(.predicate(.init(column: "e", comparison: .notIn, value: .placeholders(count: 2))))
        select.predicates.append(.predicate(.init(column: "f", comparison: .in, value: .placeholders(count: 2))))

        XCTAssertEqual(
            GeneralSQLSerializer.shared.serialize(data: select),
            "SELECT * FROM `foo` WHERE (1 AND 0 AND `c` != ? AND `d` = ? AND `e` NOT IN (?, ?) AND `f` IN (?, ?))"
        )
    }

    static let allTests = [
        ("testBasicSelectStar", testBasicSelectStar),
        ("testSelectWithPredicates", testSelectWithPredicates),
        ("testSelectWithJoins", testSelectWithJoins),
        ("testSubsetEdgecases", testSubsetEdgecases),
    ]
}

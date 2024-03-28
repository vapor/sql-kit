import SQLKit
import XCTest

final class SQLBetweenTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    func testBetween() {
        XCTAssertSerialization(of: self.db.select().where(SQLBetween("a", between: "a", and: "b")), is: "SELECT WHERE &1 BETWEEN &2 AND &3")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween("a", between: SQLIdentifier("a"), and: "b")), is: "SELECT WHERE &1 BETWEEN ``a`` AND &2")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween("a", between: "a", and: SQLIdentifier("b"))), is: "SELECT WHERE &1 BETWEEN &2 AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween("a", between: SQLIdentifier("a"), and: SQLIdentifier("b"))), is: "SELECT WHERE &1 BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween(SQLIdentifier("a"), between: "a", and: "b")), is: "SELECT WHERE ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween(SQLIdentifier("a"), between: SQLIdentifier("a"), and: "b")), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween(SQLIdentifier("a"), between: "a", and: SQLIdentifier("b"))), is: "SELECT WHERE ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween(operand: SQLIdentifier("a"), lowerBound: SQLIdentifier("a"), upperBound: SQLIdentifier("b"))), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween(column: "a", between: "a", and: "b")), is: "SELECT WHERE ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween(column: "a", between: SQLIdentifier("a"), and: "b")), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween(column: "a", between: "a", and: SQLIdentifier("b"))), is: "SELECT WHERE ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(SQLBetween(column: "a", between: SQLIdentifier("a"), and: SQLIdentifier("b"))), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND ``b``")

        XCTAssertSerialization(of: self.db.select().where("a", between: "a", and: "b"), is: "SELECT WHERE &1 BETWEEN &2 AND &3")
        XCTAssertSerialization(of: self.db.select().where("a", between: SQLIdentifier("a"), and: "b"), is: "SELECT WHERE &1 BETWEEN ``a`` AND &2")
        XCTAssertSerialization(of: self.db.select().where("a", between: "a", and: SQLIdentifier("b")), is: "SELECT WHERE &1 BETWEEN &2 AND ``b``")
        XCTAssertSerialization(of: self.db.select().where("a", between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT WHERE &1 BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(SQLIdentifier("a"), between: "a", and: "b"), is: "SELECT WHERE ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().where(SQLIdentifier("a"), between: SQLIdentifier("a"), and: "b"), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().where(SQLIdentifier("a"), between: "a", and: SQLIdentifier("b")), is: "SELECT WHERE ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(SQLIdentifier("a"), between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(column: "a", between: "a", and: "b"), is: "SELECT WHERE ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().where(column: "a", between: SQLIdentifier("a"), and: "b"), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().where(column: "a", between: "a", and: SQLIdentifier("b")), is: "SELECT WHERE ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().where(column: "a", between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND ``b``")

        XCTAssertSerialization(of: self.db.select().orWhere("a", between: "a", and: "b"), is: "SELECT WHERE &1 BETWEEN &2 AND &3")
        XCTAssertSerialization(of: self.db.select().orWhere("a", between: SQLIdentifier("a"), and: "b"), is: "SELECT WHERE &1 BETWEEN ``a`` AND &2")
        XCTAssertSerialization(of: self.db.select().orWhere("a", between: "a", and: SQLIdentifier("b")), is: "SELECT WHERE &1 BETWEEN &2 AND ``b``")
        XCTAssertSerialization(of: self.db.select().orWhere("a", between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT WHERE &1 BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().orWhere(SQLIdentifier("a"), between: "a", and: "b"), is: "SELECT WHERE ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().orWhere(SQLIdentifier("a"), between: SQLIdentifier("a"), and: "b"), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().orWhere(SQLIdentifier("a"), between: "a", and: SQLIdentifier("b")), is: "SELECT WHERE ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().orWhere(SQLIdentifier("a"), between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().orWhere(column: "a", between: "a", and: "b"), is: "SELECT WHERE ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().orWhere(column: "a", between: SQLIdentifier("a"), and: "b"), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().orWhere(column: "a", between: "a", and: SQLIdentifier("b")), is: "SELECT WHERE ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().orWhere(column: "a", between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT WHERE ``a`` BETWEEN ``a`` AND ``b``")

        XCTAssertSerialization(of: self.db.select().having("a", between: "a", and: "b"), is: "SELECT HAVING &1 BETWEEN &2 AND &3")
        XCTAssertSerialization(of: self.db.select().having("a", between: SQLIdentifier("a"), and: "b"), is: "SELECT HAVING &1 BETWEEN ``a`` AND &2")
        XCTAssertSerialization(of: self.db.select().having("a", between: "a", and: SQLIdentifier("b")), is: "SELECT HAVING &1 BETWEEN &2 AND ``b``")
        XCTAssertSerialization(of: self.db.select().having("a", between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT HAVING &1 BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().having(SQLIdentifier("a"), between: "a", and: "b"), is: "SELECT HAVING ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().having(SQLIdentifier("a"), between: SQLIdentifier("a"), and: "b"), is: "SELECT HAVING ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().having(SQLIdentifier("a"), between: "a", and: SQLIdentifier("b")), is: "SELECT HAVING ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().having(SQLIdentifier("a"), between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT HAVING ``a`` BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().having(column: "a", between: "a", and: "b"), is: "SELECT HAVING ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().having(column: "a", between: SQLIdentifier("a"), and: "b"), is: "SELECT HAVING ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().having(column: "a", between: "a", and: SQLIdentifier("b")), is: "SELECT HAVING ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().having(column: "a", between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT HAVING ``a`` BETWEEN ``a`` AND ``b``")

        XCTAssertSerialization(of: self.db.select().orHaving("a", between: "a", and: "b"), is: "SELECT HAVING &1 BETWEEN &2 AND &3")
        XCTAssertSerialization(of: self.db.select().orHaving("a", between: SQLIdentifier("a"), and: "b"), is: "SELECT HAVING &1 BETWEEN ``a`` AND &2")
        XCTAssertSerialization(of: self.db.select().orHaving("a", between: "a", and: SQLIdentifier("b")), is: "SELECT HAVING &1 BETWEEN &2 AND ``b``")
        XCTAssertSerialization(of: self.db.select().orHaving("a", between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT HAVING &1 BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().orHaving(SQLIdentifier("a"), between: "a", and: "b"), is: "SELECT HAVING ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().orHaving(SQLIdentifier("a"), between: SQLIdentifier("a"), and: "b"), is: "SELECT HAVING ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().orHaving(SQLIdentifier("a"), between: "a", and: SQLIdentifier("b")), is: "SELECT HAVING ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().orHaving(SQLIdentifier("a"), between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT HAVING ``a`` BETWEEN ``a`` AND ``b``")
        XCTAssertSerialization(of: self.db.select().orHaving(column: "a", between: "a", and: "b"), is: "SELECT HAVING ``a`` BETWEEN &1 AND &2")
        XCTAssertSerialization(of: self.db.select().orHaving(column: "a", between: SQLIdentifier("a"), and: "b"), is: "SELECT HAVING ``a`` BETWEEN ``a`` AND &1")
        XCTAssertSerialization(of: self.db.select().orHaving(column: "a", between: "a", and: SQLIdentifier("b")), is: "SELECT HAVING ``a`` BETWEEN &1 AND ``b``")
        XCTAssertSerialization(of: self.db.select().orHaving(column: "a", between: SQLIdentifier("a"), and: SQLIdentifier("b")), is: "SELECT HAVING ``a`` BETWEEN ``a`` AND ``b``")
    }
}

@testable import SQLKit
import XCTest

final class SQLUpsertTests: XCTestCase {
    var db = TestDatabase()

    override class func setUp() {
        XCTAssert(isLoggingConfigured)
    }
    
    // MARK: Upsert
    
    func testMySQLLikeUpsert() {
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [any SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }
        
        // Test the thoroughly underpowered and inconvenient MySQL syntax
        db._dialect.upsertSyntax = .mysqlLike
        
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates").columns(cols).values(vals("calibration")),
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application")).ignoringConflicts(),
            is: "INSERT IGNORE INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("planet-size snake oil jar purchasing"))
                .onConflict() { $0
                    .set("last_known_status", to: "Hooloovoo engineer refraction")
                    .set(excludedValueOf: "serial_number")
                },
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON DUPLICATE KEY UPDATE `last_known_status` = ?, `serial_number` = VALUES(`serial_number`)"
        )
    }
    
    func testStandardUpsert() {
        let cols = ["id", "serial_number", "star_id", "last_known_status"]
        let vals = { (s: String) -> [any SQLExpression] in [SQLLiteral.default, SQLBind(UUID()), SQLBind(1), SQLBind(s)] }

        // Test the standard SQL syntax
        db._dialect.upsertSyntax = .standard
        
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates").columns(cols).values(vals("calibration")),
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?)"
        )
        
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates").columns(cols).values(vals("unicorn dust application")).ignoringConflicts(),
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT DO NOTHING"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("Vorlon pinching"))
                .ignoringConflicts(with: ["serial_number", "star_id"]),
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`serial_number`, `star_id`) DO NOTHING"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("planet-size snake oil jar purchasing"))
                .onConflict() { $0
                    .set("last_known_status", to: "Hooloovoo engineer refraction").set(excludedValueOf: "serial_number")
                },
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT DO UPDATE SET `last_known_status` = ?, `serial_number` = EXCLUDED.`serial_number`"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("slashfic writing"))
                .onConflict(with: ["serial_number"]) { $0
                    .set("last_known_status", to: "tachyon antitelephone dialing the").set(excludedValueOf: "star_id")
                },
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`serial_number`) DO UPDATE SET `last_known_status` = ?, `star_id` = EXCLUDED.`star_id`"
        )
        XCTAssertSerialization(
            of: self.db.insert(into: "jumpgates")
                .columns(cols).values(vals("protection racket payoff"))
                .onConflict(with: ["id"]) { $0
                    .set("last_known_status", to: "insurance fraud planning")
                    .where("last_known_status", .notEqual, "evidence disposal")
                },
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (DEFAULT, ?, ?, ?) ON CONFLICT (`id`) DO UPDATE SET `last_known_status` = ? WHERE `last_known_status` <> ?"
        )
    }
    
    func testUpsertWithEncodableModels() {
        struct TestModelPlain: Codable {
            var id: Int?
            var serial_number: UUID
            var star_id: Int
            var last_known_status: String
        }
        struct TestModelSnakeCase: Codable {
            var id: Int?
            var serialNumber: UUID
            var starId: Int
            var lastKnownStatus: String
        }
        struct TestModelSuperCase: Codable {
            var Id: Int?
            var SerialNumber: UUID
            var StarId: Int
            var LastKnownStatus: String
        }
        @Sendable
        func handleSuperCase(_ path: [any CodingKey]) -> any CodingKey {
            SomeCodingKey(stringValue: path.last!.stringValue.decapitalized.convertedToSnakeCase)
        }
        let snakeEncoder = SQLQueryEncoder(keyEncodingStrategy: .convertToSnakeCase, nilEncodingStrategy: .asNil)
        let superEncoder = SQLQueryEncoder(prefix: "p_", keyEncodingStrategy: .custom({ handleSuperCase($0) }), nilEncodingStrategy: .asNil)
        
        db._dialect.upsertSyntax = .standard

        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil),
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (NULL, ?, ?, ?)"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder),
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (NULL, ?, ?, ?)"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder),
            is: "INSERT INTO `jumpgates` (`p_id`, `p_serial_number`, `p_star_id`, `p_last_known_status`) VALUES (NULL, ?, ?, ?)"
        )

        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (NULL, ?, ?, ?) ON CONFLICT (`star_id`) DO NOTHING"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (NULL, ?, ?, ?) ON CONFLICT (`star_id`) DO NOTHING"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates").model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder).ignoringConflicts(with: "star_id"),
            is: "INSERT INTO `jumpgates` (`p_id`, `p_serial_number`, `p_star_id`, `p_last_known_status`) VALUES (NULL, ?, ?, ?) ON CONFLICT (`star_id`) DO NOTHING"
        )

        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates")
                .model(TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil)
                .onConflict(with: ["star_id"]) { try $0
                    .set(excludedContentOf: TestModelPlain(serial_number: .init(), star_id: 0, last_known_status: ""), nilEncodingStrategy: .asNil)
                },
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (NULL, ?, ?, ?) ON CONFLICT (`star_id`) DO UPDATE SET `id` = EXCLUDED.`id`, `serial_number` = EXCLUDED.`serial_number`, `star_id` = EXCLUDED.`star_id`, `last_known_status` = EXCLUDED.`last_known_status`"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates")
                .model(TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder)
                .onConflict(with: ["star_id"]) { try $0
                    .set(excludedContentOf: TestModelSnakeCase(serialNumber: .init(), starId: 0, lastKnownStatus: ""), with: snakeEncoder)
                },
            is: "INSERT INTO `jumpgates` (`id`, `serial_number`, `star_id`, `last_known_status`) VALUES (NULL, ?, ?, ?) ON CONFLICT (`star_id`) DO UPDATE SET `id` = EXCLUDED.`id`, `serial_number` = EXCLUDED.`serial_number`, `star_id` = EXCLUDED.`star_id`, `last_known_status` = EXCLUDED.`last_known_status`"
        )
        XCTAssertSerialization(
            of: try self.db.insert(into: "jumpgates")
                .model(TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder)
                .onConflict(with: ["p_star_id"]) { try $0
                    .set(excludedContentOf: TestModelSuperCase(SerialNumber: .init(), StarId: 0, LastKnownStatus: ""), with: superEncoder)
                },
            is: "INSERT INTO `jumpgates` (`p_id`, `p_serial_number`, `p_star_id`, `p_last_known_status`) VALUES (NULL, ?, ?, ?) ON CONFLICT (`p_star_id`) DO UPDATE SET `p_id` = EXCLUDED.`p_id`, `p_serial_number` = EXCLUDED.`p_serial_number`, `p_star_id` = EXCLUDED.`p_star_id`, `p_last_known_status` = EXCLUDED.`p_last_known_status`"
        )
    }
}

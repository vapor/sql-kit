import SQLKit

extension SQLBenchmarker {
    public func testEnum() throws {
        try self.runTest {
            try $0.drop(table: "planets")
                .ifExists()
                .run().wait()
            try $0.drop(table: "galaxies")
                .ifExists()
                .run().wait()

            // setup sql data type for enum
            let planetType: SQLDataType
            switch $0.dialect.enumSyntax {
            case .typeName:
                planetType = .custom(SQLIdentifier("planet_type"))
                try $0.create(enum: "planet_type")
                    .value("smallRocky")
                    .value("gasGiant")
                    .run().wait()
            case .inline:
                planetType = .enum("smallRocky", "gasGiant")
            case .unsupported:
                planetType = .text
            }

            try $0.create(table: "planets")
                .column("id", type: .bigint, .primaryKey)
                .column("name", type: .text, .notNull)
                .column("type", type: planetType, .notNull)
                .run().wait()

            let earth = Planet(name: "Earth", type: .smallRocky)
            let jupiter = Planet(name: "Jupiter", type: .gasGiant)
            try $0.insert(into: "planets")
                .model(earth)
                .model(jupiter)
                .run().wait()

            // add dwarf type
            switch $0.dialect.enumSyntax {
            case .typeName:
                try $0.alter(enum: "planet_type")
                    .add(value: "dwarf")
                    .run().wait()
            case .inline:
                try $0.alter(table: "planets")
                    .update(column: "type", type: .enum("smallRocky", "gasGiant", "dwarf"))
                    .run().wait()
            case .unsupported:
                // do nothing
                break
            }

            // add new planet using dwarf type
            let pluto = Planet(name: "Pluto", type: .dwarf)
            try $0.insert(into: "planets")
                .model(pluto)
                .run().wait()

            // delete all gas giants
            try $0
                .delete(from: "planets")
                .where("type", .equal, PlanetType.gasGiant as any SQLExpression)
                .run().wait()

            // drop gas giant enum value
            switch $0.dialect.enumSyntax {
            case .typeName:
                // cannot be removed
                break
            case .inline:
                try $0.alter(table: "planets")
                    .update(column: "type", type: .enum("smallRocky", "dwarf"))
                    .run().wait()
            case .unsupported:
                // do nothing
                break
            }

            // drop table
            try $0.drop(table: "planets")
                .run().wait()

            // drop custom type
            switch $0.dialect.enumSyntax {
            case .typeName:
                try $0.drop(enum: "planet_type")
                    .run().wait()
            case .inline, .unsupported:
                // do nothing
                break
            }
        }
    }
}


private struct Planet: Encodable {
    let id: Int? = nil
    let name: String
    let type: PlanetType
}

private enum PlanetType: String, Codable, SQLExpression {
    case smallRocky, gasGiant, dwarf

    func serialize(to serializer: inout SQLSerializer) {
        SQLLiteral.string(self.rawValue)
            .serialize(to: &serializer)
    }
}

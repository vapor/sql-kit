import SQLKit

extension SQLBenchmarker {
    public func testEnum() async throws {
        try await self.runTest {
            try await $0.drop(table: "planets")
                .ifExists()
                .run()
            try await $0.drop(table: "galaxies")
                .ifExists()
                .run()

            // setup sql data type for enum
            let planetType: SQLDataType
            switch $0.dialect.enumSyntax {
            case .typeName:
                planetType = .custom(SQLIdentifier("planet_type"))
                try await $0.create(enum: "planet_type")
                    .value("smallRocky")
                    .value("gasGiant")
                    .run()
            case .inline:
                planetType = .enum("smallRocky", "gasGiant")
            case .unsupported:
                planetType = .text
            }

            try await $0.create(table: "planets")
                .column("id", type: .bigint, .primaryKey)
                .column("name", type: .text, .notNull)
                .column("type", type: planetType, .notNull)
                .run()

            let earth = Planet(name: "Earth", type: .smallRocky)
            let jupiter = Planet(name: "Jupiter", type: .gasGiant)
            try await $0.insert(into: "planets")
                .model(earth)
                .model(jupiter)
                .run()

            // add dwarf type
            switch $0.dialect.enumSyntax {
            case .typeName:
                try await $0.alter(enum: "planet_type")
                    .add(value: "dwarf")
                    .run()
            case .inline:
                try await $0.alter(table: "planets")
                    .update(column: "type", type: .enum("smallRocky", "gasGiant", "dwarf"))
                    .run()
            case .unsupported:
                // do nothing
                break
            }

            // add new planet using dwarf type
            let pluto = Planet(name: "Pluto", type: .dwarf)
            try await $0.insert(into: "planets")
                .model(pluto)
                .run()

            // delete all gas giants
            try await $0
                .delete(from: "planets")
                .where("type", .equal, PlanetType.gasGiant as any SQLExpression)
                .run()

            // drop gas giant enum value
            switch $0.dialect.enumSyntax {
            case .typeName:
                // cannot be removed
                break
            case .inline:
                try await $0.alter(table: "planets")
                    .update(column: "type", type: .enum("smallRocky", "dwarf"))
                    .run()
            case .unsupported:
                // do nothing
                break
            }

            // drop table
            try await $0.drop(table: "planets")
                .run()

            // drop custom type
            switch $0.dialect.enumSyntax {
            case .typeName:
                try await $0.drop(enum: "planet_type")
                    .run()
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

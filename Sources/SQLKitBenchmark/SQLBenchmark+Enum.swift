import SQLKit

extension SQLBenchmarker {
    public func testEnum() throws {
        // setup sql data type for enum
        let planetType: SQLDataType
        switch self.db.dialect.enumSyntax {
        case .typeName:
            planetType = .type("planet_type")
            try self.db.create(enum: "planet_type")
                .value("smallRocky")
                .value("gasGiant")
                .run().wait()
        case .inline:
            planetType = .enum("smallRocky", "gasGiant")
        case .unsupported:
            planetType = .text
        }

        try self.db.create(table: "planets")
            .column("id", type: .bigint, .primaryKey)
            .column("name", type: .text, .notNull)
            .column("type", type: planetType, .notNull)
            .run().wait()

        let earth = Planet(name: "Earth", type: .smallRocky)
        let jupiter = Planet(name: "Jupiter", type: .gasGiant)
        try self.db.insert(into: "planets")
            .model(earth)
            .model(jupiter)
            .run().wait()

        // add dwarf type
        switch self.db.dialect.enumSyntax {
        case .typeName:
            try self.db.alter(enum: "planet_type")
                .add(value: "dwarf")
                .run().wait()
        case .inline:
            try self.db.alter(table: "planets")
                .update(column: "type", type: .enum("smallRocky", "gasGiant", "dwarf"))
                .run().wait()
        case .unsupported:
            // do nothing
            break
        }

        // add new planet using dwarf type
        let pluto = Planet(name: "Pluto", type: .dwarf)
        try self.db.insert(into: "planets")
            .model(pluto)
            .run().wait()

        // delete all gas giants
        try self.db
            .delete(from: "planets")
            .where("type", .equal, PlanetType.gasGiant as SQLExpression)
            .run().wait()

        // drop gas giant enum value
        switch self.db.dialect.enumSyntax {
        case .typeName:
            // cannot be removed
            break
        case .inline:
            try self.db.alter(table: "planets")
                .update(column: "type", type: .enum("smallRocky", "dwarf"))
                .run().wait()
        case .unsupported:
            // do nothing
            break
        }

        // drop table
        try self.db.drop(table: "planets")
            .run().wait()

        // drop custom type
        switch self.db.dialect.enumSyntax {
        case .typeName:
            try self.db.drop(enum: "planet_type")
                .run().wait()
        case .inline, .unsupported:
            // do nothing
            break
        }
    }
}


private struct Planet: Codable {
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

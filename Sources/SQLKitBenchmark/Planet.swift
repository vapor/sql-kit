import SQLKit

struct Planet: Codable {
    var id: Int?
    var name: String
    // var type: PlanetType
    var galaxyID: Int
    init(id: Int? = nil, name: String, galaxyID: Int) {
        self.id = id
        self.name = name
        self.galaxyID = galaxyID
    }
}

enum PlanetType: String, Codable {
    case smallRocky
    case gasGiant
    case dwarf
}

struct Planet: SQLTable {
    var id: Int?
    var name: String
    var galaxyID: Int
    init(id: Int? = nil, name: String, galaxyID: Int) {
        self.id = id
        self.name = name
        self.galaxyID = galaxyID
    }
}

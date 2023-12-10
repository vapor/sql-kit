import SQLModelMacro

@attached(member, names: named(columnNames), named(values))
@attached(extension, conformances: Modelable, Decodable)
public macro Model() = #externalMacro(
  module: "SQLModelMacro",
  type: "SQLModelMacro"
)

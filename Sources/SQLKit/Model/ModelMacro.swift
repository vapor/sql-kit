import SQLModelMacro

@attached(member, names: named(columnNames), named(values))
@attached(extension, conformances: Modelable)
public macro Model() = #externalMacro(
  module: "SQLModelMacro",
  type: "SQLModelMacro"
)

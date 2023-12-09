import SQLModelMacro

@attached(member, names: named(fields))
@attached(extension, conformances: Modelable)
public macro Model() = #externalMacro(
  module: "SQLModelMacro",
  type: "SQLModelMacro"
)

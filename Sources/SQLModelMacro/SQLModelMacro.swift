import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

public struct SQLModelMacro {
}

extension SQLModelMacro: ExtensionMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
    conformingTo protocols: [SwiftSyntax.TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
    guard let attachedTypeNameSyntax = declaration.as(StructDeclSyntax.self)?.name ??
            declaration.as(ClassDeclSyntax.self)?.name ??
            declaration.as(ActorDeclSyntax.self)?.name else {
      throw Diagnostics.appliedTypeFail
    }
    if let inheritanceClause = declaration.inheritanceClause,
       inheritanceClause.inheritedTypes.contains(where: { $0.type.as(IdentifierTypeSyntax.self)?.name.text == "Modelable"})        {
      return []
    }
    return [
      ExtensionDeclSyntax(
        extendedType: IdentifierTypeSyntax(name: attachedTypeNameSyntax),
        inheritanceClause: InheritanceClauseSyntax(inheritedTypes: InheritedTypeListSyntax {
          InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Modelable")))
        }),
        memberBlockBuilder: {}
      )
    ]
  }
}
extension SQLModelMacro: MemberMacro {
  public static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.DeclSyntax] {
    guard declaration.is(StructDeclSyntax.self)
            || declaration.is(ClassDeclSyntax.self)
            || declaration.is(ActorDeclSyntax.self)
    else {
      throw Diagnostics.appliedTypeFail
    }

    let variableDeclarations = declaration.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }

    let syntax = VariableDeclSyntax(
      modifiers: DeclModifierListSyntax {
        DeclModifierSyntax(name: .keyword(.public))
      },
      bindingSpecifier: .keyword(.var)
    ) {
      PatternBindingSyntax(
        pattern: PatternSyntax("fields"),
        typeAnnotation: TypeAnnotationSyntax(
          type: ArrayTypeSyntax(
            element: TupleTypeSyntax(
              elements: TupleTypeElementListSyntax {
                TupleTypeElementSyntax(
                  firstName: .identifier("name"),
                  colon: .colonToken(),
                  type: IdentifierTypeSyntax(name: .identifier("String"))
                )
                TupleTypeElementSyntax(
                  firstName: .identifier("value"),
                  colon: .colonToken(),
                  type: SomeOrAnyTypeSyntax(
                    someOrAnySpecifier: .keyword(.any),
                    constraint: IdentifierTypeSyntax(name: .identifier("Encodable"))
                  )
                )
              }
            )
          )
        ),
        accessorBlock: AccessorBlockSyntax(
          accessors: .getter(CodeBlockItemListSyntax {
            ArrayExprSyntax(elements: ArrayElementListSyntax{
              for propertyName in variableDeclarations
                .filter({ Self.validStoredPeoperty(member: $0 )})
                .flatMap(\.bindings)
                .map({ $0.pattern.as(IdentifierPatternSyntax.self)!.identifier.text }) {
                ArrayElementSyntax(expression: TupleExprSyntax(elements: LabeledExprListSyntax {
                  LabeledExprSyntax(expression: StringLiteralExprSyntax(content: propertyName))
                  LabeledExprSyntax(expression: MemberAccessExprSyntax(
                    base: DeclReferenceExprSyntax(baseName: .keyword(.self)),
                    declName: DeclReferenceExprSyntax(baseName: .identifier(propertyName))
                  ))
                }))
              }
            })
          })
        )
      )
    }
    
    return [
      DeclSyntax(syntax),
    ]
  }
}

extension SQLModelMacro {
  private static func validStoredPeoperty(member: VariableDeclSyntax) -> Bool {
    // Ignore ComputerProperty
    guard member.bindings.allSatisfy({ $0.accessorBlock == nil }) else { return false }
    guard !member.modifiers.compactMap({ $0.as(DeclModifierSyntax.self)?.name.text }).contains("static") else { return false }
    // Get All Attribute Name
    // If member has ModelIgnored or Field Attribute, return false
    let containsModelIgnoredAttribute = member.attributes
      .compactMap({ if case .attribute(let attributeSyntax) = $0 { attributeSyntax } else { nil }})
      .compactMap({ $0.attributeName.as(IdentifierTypeSyntax.self) })
      .map { $0.name.text }
      .contains("ModelableIgnored")
    
    if containsModelIgnoredAttribute {
      return false
    }

    return true
  }
}

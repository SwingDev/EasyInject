import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct NeedsMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(ClassDeclSyntax.self) != nil else {
            throw InjectGrailError(message: "@Needs only works on class declaration")
        }

        guard
            let generics = node.attributeName.as(IdentifierTypeSyntax.self)?.genericArgumentClause?.arguments.first?.argument,
            let protocolType = generics.as(IdentifierTypeSyntax.self)?.name.text
        else {
            throw InjectGrailError(message: "@Needs requires Injector protocol")
        }

        let noLet = declaration.memberBlock.members.first(where: { $0.decl.as(VariableDeclSyntax.self)?.bindings.first(where: { "\($0.pattern)"  == "injector" }) != nil}) != nil
        let noConstructor = declaration.memberBlock.members.first(where: { $0.decl.as(InitializerDeclSyntax.self) != nil})?.decl.as(InitializerDeclSyntax.self)!.signature.parameterClause.parameters.first?.firstName.text == "injector"


        return [
            noLet ? nil : DeclSyntax(stringLiteral: "let injector: \(protocolType)Impl"),
            noConstructor ? nil :  DeclSyntax(stringLiteral: "init(injector: \(protocolType)Impl){ self.injector = injector}")
        ].compactMap({$0})
    }
}

public struct NeedsInjectorMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDeclaration = declaration.as(ClassDeclSyntax.self) else {
            throw InjectGrailError(message: "@NeedsInjector only works on class declaration")
        }

        let className = classDeclaration.name.text
        let injectorProtocolType = className.replacingOccurrences(of: "Impl", with: "Injector")

        let noLet = declaration.memberBlock.members.first(where: { $0.decl.as(VariableDeclSyntax.self)?.bindings.first(where: { "\($0.pattern)"  == "injector" }) != nil}) != nil
        let noConstructor = declaration.memberBlock.members.first(where: { $0.decl.as(InitializerDeclSyntax.self) != nil})?.decl.as(InitializerDeclSyntax.self)!.signature.parameterClause.parameters.first?.firstName.text == "injector"

        return [
            noLet ? nil : DeclSyntax(stringLiteral: "let injector: \(injectorProtocolType)Impl"),
            noConstructor ? nil :  DeclSyntax(stringLiteral: "init(injector: \(injectorProtocolType)Impl){ self.injector = injector}")
        ].compactMap({$0})
    }
}

public struct InjectsMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.as(ClassDeclSyntax.self) != nil else {
            throw InjectGrailError(message: "@Injects only works on class declaration")
        }

        guard
            node.attributeName.as(IdentifierTypeSyntax.self)?.genericArgumentClause?.arguments.allSatisfy({ argument -> Bool in
                argument.as(GenericArgumentSyntax.self)?.argument.as(IdentifierTypeSyntax.self) != nil
            }) ?? false
        else {
            throw InjectGrailError(message: "@Injects requires Injected classes")
        }


        return []
    }
}

@main
struct InjectGrailMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        NeedsMacro.self,
        NeedsInjectorMacro.self,
        InjectsMacro.self
    ]
}

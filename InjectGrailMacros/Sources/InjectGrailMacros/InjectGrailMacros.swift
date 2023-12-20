// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.

@attached(member, names: named(`injector`), named(init(injector:)))
public macro Needs<T>(noConstructor: Bool = false, noLet: Bool = false) = #externalMacro(module: "InjectGrailMacrosMacros", type: "NeedsMacro")

@attached(member, names: named(`injector`), named(init(injector:)))
public macro NeedsInjector() = #externalMacro(module: "InjectGrailMacrosMacros", type: "NeedsInjectorMacro")

@attached(member)
public macro Injects<each T>() = #externalMacro(module: "InjectGrailMacrosMacros", type: "InjectsMacro")

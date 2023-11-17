import SourceryRuntime

func log(_ text: String) {
    // Log.error(text)
}

public struct Property {
  let name: String
  let type: String
  let forceManual: Bool
  let isSelfProperty: Bool
}

extension Property {
  func notSelf() -> Property {
    return Property(name: name, type: type, forceManual: forceManual, isSelfProperty: false)
  }
}

public struct InjectData {
  let rootInjector: Type
  let injectables: [Type]
  let injectors: [Protocol]
  let injectsToInjectors: [String: String]
  let injectorsToInjectables: [String: [String]]
  let injectablesToInjectors: [String: String]
  let injectablesToInjects: [String: [String]]
  let injectorProperties: [String: [Property]]
}

// Properties sorting function
func sorted(_ properties: [Property]) -> [Property] {
  return properties.enumerated()
  .sorted(by: {a, b -> Bool in 
  //Self properties go before inherited properties
  if a.element.isSelfProperty && !b.element.isSelfProperty {
    return true
  } else if !a.element.isSelfProperty && b.element.isSelfProperty {
    return false
  }

  if a.element.isSelfProperty {
    //Self properties are sorted in order they were defined
    return a.offset < b.offset
  } else {
    // Inherited properties are sorted alphabetically
     return a.element.name < b.element.name
  }
  } )
  .map { $0.element }
}

// Try to find source of the property in the list of properties available in parent
func resolvePropertyFromSource(property: Property, allProperties: [Property], sourceProperties: [Property]) -> Property? {
  if (property.forceManual) {
      return nil
    }
    
  if property.type == "Int" || property.type == "String" {
    return nil
  }

  let sourcePropertiesOfSameType = sourceProperties.filter({$0.type == property.type})
  let allPropertiesOfSameType = allProperties.filter({$0.type == property.type})
  let hasMoreThanOneSameTypeProperty = sourcePropertiesOfSameType.count > 1 || allPropertiesOfSameType.count > 1

  if hasMoreThanOneSameTypeProperty {
    let sourcePropertiesWithSameName = sourcePropertiesOfSameType.filter({$0.name == property.name})
    return sourcePropertiesWithSameName.first
  } else {
      return sourcePropertiesOfSameType.first
  }
}

func resolvePropertyFromInjectingRecursively(
    resolvedProperty: Property,
    resolvedInjector: String,
    allProperties: [Property],
    sourceInjector: String,
    sourceProperties: [String: [Property]],
    injectorsToInjectorsThatInject: [String: [String]],
    rootProperties: [Property]
) -> Property? {

    // Try to get property from direct parent
    let properties = sourceProperties[sourceInjector] ?? []
    if let matched = resolvePropertyFromSource(
        property: resolvedProperty,
        allProperties: allProperties,
        sourceProperties:properties
    ) {
      log("RESOLVED FROM PARENT | \(sourceInjector)")
      return matched
    }

    // Try to get property from root injector
    if let matched = resolvePropertyFromSource(
        property: resolvedProperty,
        allProperties: allProperties,
        sourceProperties: rootProperties
    ) {
      log("RESOLVED FROM ROOT | ")
      return matched
    }

   // Traverse hierarchy
    for parent in (injectorsToInjectorsThatInject[sourceInjector] ?? []) {
      if let matched = resolvePropertyFromInjectingRecursively(
            resolvedProperty: resolvedProperty,
            resolvedInjector: resolvedInjector,
            allProperties: allProperties,
            sourceInjector: parent,
            sourceProperties: sourceProperties,
            injectorsToInjectorsThatInject: injectorsToInjectorsThatInject,
            rootProperties: rootProperties
      ) {
        log("RESOLVED FROM GRAND PARENT | \(parent)")
        return matched
      }
    }
    
    log("NOT FOUND | ")
    return nil
}

func resolveDependencyTree(injectorProperties: [String: [Property]],  injectsToInjectors: [String: String], injectablesToInjectors: [String: String], injectablesToInjects: [String: [String]]) -> [String: [Property]] {
    var injectorsToInjectedInjectors: [String: [String]] = [:]
    var injectorsToInjectorsThatInject: [String: [String]] = [:]

    var injectorProperties = injectorProperties

    guard let rootInjectorProperties = injectorProperties["RootInjector"] else { fatalError("Implementation of RootInjector not found") }
    let rootPropertiesTypes = rootInjectorProperties.map {$0.type}.joined(separator: ", ")
    log("Root Injector Properties: \(rootPropertiesTypes)\n")

    // Build injection tree
    injectablesToInjects.keys.forEach({injectable in 
        guard let injector = injectablesToInjectors[injectable] else { fatalError("\(injectable) is not Injectable") }
        guard let injects = injectablesToInjects[injectable] else { fatalError("Inject not found for \(injectable)") }
        let injectedInjectors: [String] = injects.map({
            guard let injector = injectsToInjectors[$0] else {
                fatalError("Injector for \($0) not found")
            }
            return injector
        })
        injectorsToInjectedInjectors[injector] = (injectorsToInjectedInjectors[injector] ?? []) + injectedInjectors
        for injected in injectedInjectors {
          injectorsToInjectorsThatInject[injected] = (injectorsToInjectorsThatInject[injected] ?? []) + [injector]
        }        
    })

    log("--------------------------\n")
    for injector in injectorsToInjectedInjectors {
        log("\(injector.key) injects:\n")
        for injected in injector.value {
          log("\t- \(injected)\n")
        }
    }
    log("--------------------------\n")

    // Find all injectors which injects doesn't inject any other injectors
    let leafInjectors = injectorProperties.keys.filter({(injectorsToInjectedInjectors[$0] == nil || injectorsToInjectedInjectors[$0]!.count == 0) && $0 != "RootInjector"})

    var injectorsToProcess: [String] = leafInjectors
    var processedInjectors: Set<String> = Set()

    // Travers injection tree from leaves upwards
    while injectorsToProcess.count > 0 {
      let injector = injectorsToProcess[0]
      injectorsToProcess.remove(at: 0)

      let  currentInjectorProperties = injectorProperties[injector] ?? []

      log("\n---\tChecking \(injector)\t---\n")

      // Starting from the leaf injectors (injectors that don't inject other injectors)
      // iterate over all injectors that inject already processed injectors to find if we need to add properties to their implementation
      let injectorsThatInjectCurrentOne = injectorsToInjectorsThatInject[injector] ?? []
      for injectorThatInjects in injectorsThatInjectCurrentOne {
        log("Injected by \(injectorThatInjects)\n")
        for property in currentInjectorProperties {
          log("\(injector):\(property.type) \t\t")
            if let matched = resolvePropertyFromInjectingRecursively(
                resolvedProperty: property,
                resolvedInjector: injector,
                allProperties: currentInjectorProperties,
                sourceInjector: injectorThatInjects,
                sourceProperties: injectorProperties,
                injectorsToInjectorsThatInject: injectorsToInjectorsThatInject,
                rootProperties: rootInjectorProperties
            ) {
              if resolvePropertyFromSource(
                    property: matched,
                    allProperties: currentInjectorProperties,
                    sourceProperties: injectorProperties[injectorThatInjects] ?? []
              ) == nil {
                //Append properties need by curren injector if not present in this injector, but found in parent or in the root
                injectorProperties[injectorThatInjects] = (injectorProperties[injectorThatInjects] ?? []) + [matched.notSelf()]
              }
              log("\n")
            } else {
              log("--\n")
            }
        }
        // Make sure to append children only once
        if !processedInjectors.contains(injector) {
          injectorsToProcess.append(injectorThatInjects)
        }
      }
      processedInjectors.insert(injector)
    }

    log("------------------------------------------------------\n")
    for properties in processedInjectors {
      let list = injectorProperties[properties]?.map { $0.type }.joined(separator: ", ") ?? ""
      log("\(properties) -> \(list)\n")
    }

    return injectorProperties
}

func extractNeededName(_ type: Type) -> String? {
    guard 
       let attribute = type.attributes["Needs"]?.first
       else { return nil }

    let name = String(describing: attribute)

    let injector = String(name[name.index(after: name.firstIndex(of: "<")!)...name.index(name.firstIndex(of: ">")!, offsetBy: -1)])
    // Log.error("Needs: \(type.name) -> \(injector)\n")
    return injector
}

func extractInjects(_ type: Type, _ injectablesToInjectors: [String: String]) -> [String] {
    guard 
       let attribute = type.attributes["Injects"]?.first
       else { return [] }

    let name = String(describing: attribute)

    return String(name[name.index(after: name.firstIndex(of: "<")!)...name.index(name.endIndex, offsetBy: -2)]).components(separatedBy:",").compactMap{
        let trimmed = $0.trimmingCharacters(in: .whitespacesAndNewlines)
        if let injectedInjector = injectablesToInjectors[trimmed] {
            return "Injects\(injectedInjector)"
        } else {
            Log.error("Failed to find Injector for Injected class \($0) while checking \(type.name).\n")
            return nil
        }
        }
}

public func calculateInjectData() -> InjectData {
  let injectables = types.all.filter({ $0.inheritedTypes.contains("Injectable") || $0.attributes["Needs"] != nil})
  let needed = Set(types.all.flatMap { extractNeededName($0) })
  
  let injectors = types.protocols.filter({$0.inheritedTypes.contains("Injector") || needed.contains($0.name) }) 
  var injectsToInjectors: [String: String] = [:]
  var injectorsToInjects: [String: [String]] = [:]
  var injectorsToInjectables: [String: [String]] = [:]
  var injectablesToInjectors: [String: String] = [:]
  var injectablesToInjects: [String: [String]] = [:]
  var injectorProperties: [String: [Property]] = [:]

  //Find root injector properties
  guard let rootInjector = types.all.first(where: {$0.inheritedTypes.contains("RootInjector")})  else { fatalError("RootInjector not found.") }
  var rootInjectorProperties = rootInjector.storedVariables.map({Property(name: $0.name, type: "\($0.typeName)", forceManual: $0.annotations["forceManual"] != nil, isSelfProperty: false)}) ?? []

  //Find injector self properties
  injectors.forEach { injector in
    injectsToInjectors["Injects\(injector.name)"] = injector.name
    injector.instanceVariables.forEach { variable in
        log("\(variable.name): \(variable.typeName)\n")
    }
    injectorProperties[injector.name] = injector.instanceVariables.map({ return Property(name: $0.name, type: "\($0.typeName)", forceManual: $0.annotations["forceManual"] != nil, isSelfProperty: true)})
  }
  
  // Build injection relation by 
  // finding which Injectors are used to init which Injectables and which Injectables inject any other Injectors
  injectables.forEach({injectable in 
    if let injectorForInjectable = injectable.storedVariables.first(where: {$0.name == "injector"})?.typeName {
        let injectableName = String("\(injectorForInjectable)".dropLast(4))
        injectablesToInjectors[injectable.name] = injectableName
        injectorsToInjectables[injectableName] = (injectorsToInjectables[injectableName] ?? []) + [injectable.name]
    } else if let injectorForInjectable = extractNeededName(injectable) {
        injectablesToInjectors[injectable.name] = injectorForInjectable
        injectorsToInjectables[injectorForInjectable] = (injectorsToInjectables[injectorForInjectable] ?? []) + [injectable.name]
    }
  
    injectablesToInjects[injectable.name] = injectable.inheritedTypes.filter({$0.hasPrefix("Injects")})
  })

  //Add dependencies from @Injects macro
  injectables.forEach({injectable in 
    injectablesToInjects[injectable.name] = (injectablesToInjects[injectable.name] ?? []) + extractInjects(injectable, injectablesToInjectors)
  })

  //Find properties required by all injectors (including ones required by their children and found in root injector)
  injectorProperties["RootInjector"] = rootInjectorProperties
  injectorProperties = resolveDependencyTree(injectorProperties: injectorProperties, injectsToInjectors: injectsToInjectors, injectablesToInjectors: injectablesToInjectors, injectablesToInjects: injectablesToInjects)
  
  return InjectData(
    rootInjector: rootInjector,
    injectables: injectables,
    injectors: injectors, 
    injectsToInjectors: injectsToInjectors,
    injectorsToInjectables: injectorsToInjectables,
    injectablesToInjectors: injectablesToInjectors,
    injectablesToInjects: injectablesToInjects,
    injectorProperties: injectorProperties)
}


# InjectGrail

[![Version](https://img.shields.io/cocoapods/v/InjectGrail.svg?style=flat)](https://cocoapods.org/pods/InjectGrail)
[![License](https://img.shields.io/cocoapods/l/InjectGrail.svg?style=flat)](https://cocoapods.org/pods/InjectGrail)
[![Platform](https://img.shields.io/cocoapods/p/InjectGrail.svg?style=flat)](https://cocoapods.org/pods/InjectGrail)


This project is fully functional, but it requires a lot of attention in several areas:
 - Documentation,
 - Example,
 - Tests
 - Other process related stuff,
 - Comments and other readability improvements in generated code,
 - Readability improvements in Sourcery Template,
 - Basic framework info. Why, Inspirations, etc...
 
 If you're willing to help then by all means chime in! We are open for PRs.

 # TL;DR
 This
 ```swift
 class MessagesViewController: UIViewController {
     private let networkProvider: NetworkProvider
     private let authProvider: AuthProvider
     private let localStorage: LocalStorage
     private let viewModel: MessagesViewModel

     init(networkProvider: NetworkProvider, authProvider: AuthProvider,  localStorage: LocalStorage, ...) {
        self.networkProvider = networkProvider
        self.authProvider = authProvider
        self.localStorage = localStorage
        self.viewModel = MessagesViewModel(networkProvider: networkProvider, authProvider: authProvider, localStorage: localStorage, ...)
     }
 }
// ------------------------------------------------------------------
 class MessagesViewModel {
      let networkProvider: NetworkProvider
      let authProvider: AuthProvider
      let localStorage: LocalStorage

     init(networkProvider: NetworkProvider, authProvider: AuthProvider,  localStorage: LocalStorage, ...) {
        self.networkProvider = networkProvider
        self.authProvider = authProvider
        self.localStorage = localStorage
        self.authProvider.checkifLoggedIn()
     }
 }
 ```
 becomes
 ```swift
 protocol MessagesViewControllerInjector: Injector {
 }

  class MessagesViewController: UIViewController, Injectable, InjectsMessagesViewModelInjector {
     let injector: MessagesViewControllerInjectorImpl
     init(injector: MessagesViewControllerInjectorImpl) {
        self.injector = injector
        self.viewModel = MessagesViewModel(inject())
     }
 }
// ------------------------------------------------------------------
  protocol MessagesViewModelInjector: Injector {
     var networkProvider: NetworkProvider {get}
     var authProvider: AuthProvider {get}
     var localStorage: LocalStorage {get}
  }

 class MessagesViewModel: Injectable {
     let injector: MessagesViewModelInjectorImpl
     init(injector: MessagesViewModelInjectorImpl) {
        self.injector = injector
        self.authProvider.checkifLoggedIn()
     }
 }
 ```

  - For each class you declare only dependencies needed by it. Not it's children.
  - You don't get big bag of dependencies that you have to carry to all classes in your project.
  - Dependencies are automatically pushed through hierarchy without touching parent classes definitions,
  - `init` of each class contains only those dependencies that are trully needed by it or it's children (wrapped in a simple struct),
  - Your classes can still be constructed manually,
  - `inject` functions take as arguments dependencies that have not been found in current class, but are required by children.
  - Not a single line of magic. You can Cmd+Click to see exact definitions. To achieve DI only protocols, structs and extensions are used.
  - Command Completion for everything.

## Summary of terms:
 - `Injector` - specification of dependencies of a class
 - `Injectable` - Class that needs its dependencies to be injected (via `Injector` in init)
 - `InjectsXXX` - Must be implemented by parent class that wants to inject `XXX` injector.
 -  `RootInjector` - Class or struct that implements this protocol will be automatically able to injects all `Injectors`. This is a top of injection tree. There must be exactly one class implementing this protocol.

## Requirements

## Installation

InjectGrail is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'InjectGrail'
```

## Usage
1.  `import InjectGrail`
2. For every class that needs to be `Injectable` instead o passing arguments directly to `init` create a protocol that will specify them and let it conform to `Injector` protocol.
    
    For example, let's say we have a `MessagesViewModel` which we want to be injectable.
     ```swift
     class MessagesViewModel {
        let networkManager: NetworkManager
        
        init(networkManager: NetworkManager) {
            self.networkManager = networkManager
        }
    }
    ```
    We need to create `MessagesViewModelInjector` - name doesn't matter. By convention we use `<InjectableClassName>Injector` and we let it conform to `Injector`
    ```swift
        protocol MessagesViewModelInjector: Injector {
            var networkManager: NetworkManager {get}
        }
     ```
3.   Add a new build script (before compilation):
     ```bash
     "$PODS_ROOT/InjectGrail/Scripts/inject.sh"
     ```
4.   Add a class or struct that implements `RootInjector`. This will be your top most injector capable for injecting all other `Injectables`. 
    Injectables can be created manually as well.
     ```swift
     struct RootInjectorImpl: RootInjector {
            let networkManager: NetworkManager
            let messagesRepository: MessagesRepository
            let authenticationManager: AuthenticationManager
     }
     ```
5. Compile. Injecting script will generate file `/Generated/Inject.generated.swift` in your project folder. Add it to project.
6. For every class that needs to be `Injectable`  let it implement `Injectable` and satisfy protocol requirements by creating field `injector` and `init(injector:...)`. Actual structs that can be used are created by the injection framework based on your `Injector`s  definitions. For example for our  `MessagesViewModel` we created protocol `MessagesViewModelInjector`, so injection framework created implementation in struct `MessagesViewModelInjectorImpl` (added `Impl`). We should use that.
    ```swift
    class MessagesViewModel: Injectable {
        let injector: MessagesViewModelInjectorImpl
        
        init(injector: MessagesViewModelInjectorImpl) {
            self.injector = injector
        }
    }
    ```
     All properties from `MessagesViewModelInjector` can be used directly in `MessagesViewModel` via extension that was automatically created by `InjectGrail`.  So in this case we can use `networkManager` directly.
     ```swift
     class MessagesViewModel: Injectable {
        let injector: MessagesViewModelInjectorImpl
        
        init(injector: MessagesViewModelInjectorImpl) {
            self.injector = injector
        }
        
        func doSomeAction() {
            self.networkManager.callBackend()
        }
     }
     ```
7. For each `Injector` `InjectGrail` also creates protocol `Injects<InjectorName>` so in our case this would be `InjectsMessagesViewModelInjector`. Classes that are `Injectable` themselves and want to be able to inject to other `Injectables` can conform that protocol to create helper function `inject(...)`, that doesn injecting. `InjectGrail` automatically resolves dependencies between current class' `Injector` and  target `Injector` and adds arguments to function `inject` for all that has not been found. Conforming to `Injects<InjectorName>` also adds all dependencies of the target to current injector `Impl`. 

    If we were to create `MessageRowViewModel` from `MessagesViewModel`. We would need to create `MessageRowViewModelInjector` and `let MessageRowViewModel implement Injectable`, like so:
    ```swift
    protocol MessageRowViewModelInjector: Injector {
        var messagesRepository: MessagesRepository {get}
        var messageIndex: Int {get}
    }
    
    class MessageRowViewModel: Injectable {
       let injector: MessageRowViewModelInjectorImpl
       
       init(injector: MessageRowViewModelInjectorImpl) {
           self.injector = injector
       }
    }
    ```
    After running injection script we can make `MessagesViewModel` implement `InjectsMessageRowViewModelInjector` and after next run of script  `MessagesViewModelInjectorImpl` would automatically get additional property `messagesRepository` - because it's provided by `RootInjector`, and  `MessagesViewModel` would be extended with function `func inject(messageIndex: Int) -> MessageRowViewModelInjector`, which it could use to create `MessageRowViewModel` like so:
    ```swift
    class MessagesViewModel: Injectable {
       let injector: MessagesViewModelInjectorImpl
       
       init(injector: MessagesViewModelInjectorImpl) {
           self.injector = injector
       }
       
       func createRowViewModel() {
         let rowViewModel = MessageRowViewModel(inject(messageIndex: 0))
       }
    }
    ```
    `Int`s and `String`s are never resolved during injection. Even if Injecting class also has it in its `Injector`. 
    Resolving migh be also disabled manually for field in Injector by adding Sourcery annotation:
    ```swift
    protocol MessageRowViewModelInjector: Injector {
        var messagesRepository: MessagesRepository {get}
        // sourcery: forceManual
        var authenticationManager: AuthenticationManager {get}
        var messageIndex: Int {get}
    }
    ```
    In the example above `authenticationManager` will be always come from arguments to `inject` function of injecting classes.
    
### Resolving logic
When resolving dependency against parent Injector `InjectGrail` searches via type definition. If there are multiple properties of the same type, then it additionally matches by name. As mentioned above `Int`s and `String`s are never resolved.   

## Author

Łukasz Kwoska, lukasz.kwoska@swing.dev

## License

InjectGrail is available under the MIT license. See the LICENSE file for more info.

## Acknowledgement
- This project couldn't exist without [Sourcery](https://github.com/krzysztofzablocki/Sourcery). It's the main component behind the scences. 
- [Annotation Inject](https://github.com/akane/AnnotationInject) - Thanks for showing me how easy it is to use sourcery from pod.
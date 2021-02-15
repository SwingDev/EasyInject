//
//  Protocols.swift
//  InjectGrail
//
//  Created by Łukasz Kwoska on 13/02/2021.
//

import Foundation

// Defines properties that can be injected to certain class
public protocol Injector {}

// Defines root properties that can be injected into other classes. There can be only one type conforming to this
public protocol RootInjector {}

public protocol Injectable {
    associatedtype ActualInjector: Injector

    var injector: ActualInjector {get}

    init (injector: ActualInjector)
}

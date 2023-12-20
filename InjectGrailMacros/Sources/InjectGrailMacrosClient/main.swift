import InjectGrailMacros

protocol TestProtocol {
}
struct TestProtocolImpl: TestProtocol {

}

@Needs<TestProtocol>
class Test {

}

@Needs<TestProtocol>(noConstructor: true)
class TestNoConstructor {
    init(injector: TestProtocolImpl) {
        self.injector = injector
    }
}


@Needs<TestProtocol>
class TestNoLet {

}

@Needs<TestProtocol>
@Injects<TestNoConstructor,
         TestNoLet,
         TestNoLet,
         TestNoLet,
         TestNoLet,
         TestNoLet,
         TestNoLet,
         TestNoLet,
         TestNoLet,TestNoLet,TestNoLet,TestNoLet,TestNoLet>
class TestNothing {
    let injector: TestProtocolImpl

    init(injector: TestProtocolImpl) {
        self.injector = injector
    }
}

let _ = Test(injector: TestProtocolImpl())
let _ = TestNoConstructor(injector: TestProtocolImpl())
let _ = TestNoLet(injector: TestProtocolImpl())
let _ = TestNothing(injector: TestProtocolImpl())

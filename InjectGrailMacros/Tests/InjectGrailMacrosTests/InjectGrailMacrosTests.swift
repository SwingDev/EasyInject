import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(InjectGrailMacrosMacros)
import InjectGrailMacrosMacros

let testMacros: [String: Macro.Type] = [
    "@Needs": NeedsMacro.self,
]
#endif

final class InjectGrailMacrosTests: XCTestCase {
    func testMacro() throws {
        #if canImport(InjectGrailMacrosMacros)
        assertMacroExpansion(
            """
            protocol TestProtocol {
            }
            @Needs<TestProtocol>
            class Test {
            }
            """,
            expandedSource: """
            protocol TestProtocol {
            }
            @Needs<TestProtocol>
            class Test {
                let injector:TestProtocolImpl

                init(injector: TestProtocolImpl) {
                    self.injector = injector
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(InjectGrailMacrosMacros)
        assertMacroExpansion(
            #"""
                protocol TestProtocol {
                }
                @Needs(TestProtocol)
                protocol Test {

                }
            """#,
            expandedSource: #"""

            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}

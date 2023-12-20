// swift-tools-version:5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "InjectGrail",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "InjectGrail", targets: ["InjectGrail"]),
        .library(name: "InjectGrailMacros", targets: ["InjectGrailMacros"]),
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .target(name: "InjectGrail", path: "InjectGrail/Classes"),
        .target(
            name: "InjectGrailMacros",
            dependencies: ["InjectGrailMacrosMacros"],
            path: "InjectGrailMacros/Sources/InjectGrailMacros"
        ),
        .macro(
            name: "InjectGrailMacrosMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "InjectGrailMacros/Sources/InjectGrailMacrosMacros"
        ),
        .testTarget(
            name: "InjectGrailMacrosTests",
            dependencies: [
                "InjectGrailMacrosMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            path: "InjectGrailMacros/Tests/InjectGrailMacrosTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)

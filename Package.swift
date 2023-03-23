// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "InjectGrail",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "InjectGrail", targets: ["InjectGrail"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", branch: "master")
    ],
    targets: [
        .target(name: "InjectGrail", path: "InjectGrail/Classes"),
    ],
    swiftLanguageVersions: [.v5]
)

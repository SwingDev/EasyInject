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
    targets: [
        .target(name: "InjectGrail", path: "InjectGrail/Classes"),
    ],
    swiftLanguageVersions: [.v5]
)

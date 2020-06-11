// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PJLinkSwift",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v12)
    ],
    products: [
        .executable(name: "PJLinkServer", targets: ["PJLinkServer"]),
        .library(name: "PJLinkSwift", targets: ["PJLinkSwift"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "PJLinkServer",
                dependencies: ["PJLinkSwift"],
                path: "PJLinkServer/Classes"),
        .target(name: "PJLinkSwift",
                dependencies: [],
                path: "PJLinkSwift/Classes"),
        .testTarget(name: "PJLinkSwiftTests",
                    dependencies: ["PJLinkSwift"],
                    path: "Example/Tests")
    ]
)

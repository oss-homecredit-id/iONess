// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iONess",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_10),
        .tvOS(.v10)
    ],
    products: [
        .library(
            name: "iONess",
            targets: ["iONess"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/nayanda1/Ergo.git", from: "1.0.2"),
        .package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.2.0")
    ],
    targets: [
        .target(
            name: "iONess",
            dependencies: ["Ergo"],
            path: "iONess/Classes"
        ),
        .testTarget(
            name: "iONessTests",
            dependencies: ["iONess", "Quick", "Nimble"],
            path: "Example/Tests",
            exclude: ["Info.plist"]
        )
    ]
)

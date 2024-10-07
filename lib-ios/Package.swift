// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "App",
  platforms: [.macOS(.v12), .iOS(.v17)],
  products: [
    .library(
      name: "App",
      targets: ["App"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.0.0"
    ),
  ],
  targets: [
    .target(
      name: "App",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: ["App"]
    ),
  ]
)

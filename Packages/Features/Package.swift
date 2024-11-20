// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Features",
  platforms: [.iOS(.v18), .macOS(.v15)],
  products: [
    .library(name: "Feed", targets: ["Feed"]),
    .library(name: "Post", targets: ["Post"]),
    .library(name: "DesignSystem", targets: ["DesignSystem"]),
  ],
  dependencies: [
    .package(name: "Model", path: "./Model"),
    .package(url: "https://github.com/nikstar/VariableBlur", from: "1.2.0")
  ],
  targets: [
    .target(
      name: "Feed",
      dependencies: [
        .product(name: "Network", package: "Model")
      ]
    ),
    .target(
      name: "Post",
      dependencies: [
        .product(name: "Network", package: "Model")
      ]
    ),
    .target(
      name: "DesignSystem",
      dependencies: [
        .product(name: "VariableBlur", package: "VariableBlur")
      ]
    ),
  ]
)

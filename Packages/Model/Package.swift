// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Model",
  platforms: [.iOS(.v18), .macOS(.v15)],
  products: [
    .library(name: "Network", targets: ["Network"]),
    .library(name: "Models", targets: ["Models"]),
    .library(name: "Auth", targets: ["Auth"]),
    .library(name: "User", targets: ["User"]),
    .library(name: "Router", targets: ["Router"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/MasterJ93/ATProtoKit", branch: "main"),
    .package(url: "https://github.com/evgenyneu/keychain-swift", from: "24.0.0"),
  ],
  targets: [
    .target(
      name: "Network",
      dependencies: [
        .product(name: "ATProtoKit", package: "ATProtoKit")
      ]
    ),
    .target(
      name: "Models",
      dependencies: [
        .product(name: "ATProtoKit", package: "ATProtoKit"),
        "Network",
      ]
    ),
    .target(
      name: "Auth",
      dependencies: [
        .product(name: "ATProtoKit", package: "ATProtoKit"),
        .product(name: "KeychainSwift", package: "keychain-swift"),
      ]
    ),
    .testTarget(
      name: "AuthTests",
      dependencies: ["Auth"]
    ),
    .target(
      name: "User",
      dependencies: [
        .product(name: "ATProtoKit", package: "ATProtoKit"),
        "Network",
      ]
    ),
    .target(
      name: "Router",
      dependencies: ["Models"]
    ),
  ]
)

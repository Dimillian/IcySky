// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let baseDeps: [PackageDescription.Target.Dependency] = [
  .product(name: "Network", package: "Model"),
  .product(name: "Models", package: "Model"),
  .product(name: "Router", package: "Model"),
  .product(name: "Auth", package: "Model"),
  .product(name: "User", package: "Model"),
  "DesignSystem",
]

let package = Package(
  name: "Features",
  platforms: [.iOS(.v18), .macOS(.v15)],
  products: [
    .library(name: "FeedUI", targets: ["FeedUI"]),
    .library(name: "PostUI", targets: ["PostUI"]),
    .library(name: "AuthUI", targets: ["AuthUI"]),
    .library(name: "SettingsUI", targets: ["SettingsUI"]),
    .library(name: "NotificationsUI", targets: ["NotificationsUI"]),
    .library(name: "DesignSystem", targets: ["DesignSystem"]),
  ],
  dependencies: [
    .package(name: "Model", path: "../Model"),
    .package(url: "https://github.com/nikstar/VariableBlur", from: "1.2.0"),
    .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.0"),
  ],
  targets: [
    .target(
      name: "FeedUI",
      dependencies: baseDeps
    ),
    .testTarget(
      name: "FeedUITests",
      dependencies: [
        "FeedUI",
        .product(name: "ViewInspector", package: "ViewInspector"),
      ]
    ),
    .target(
      name: "PostUI",
      dependencies: baseDeps + ["FeedUI"]
    ),
    .target(
      name: "AuthUI",
      dependencies: baseDeps
    ),
    .target(
      name: "SettingsUI",
      dependencies: baseDeps
    ),
    .target(
      name: "NotificationsUI",
      dependencies: baseDeps + ["PostUI"]
    ),
    .target(
      name: "DesignSystem",
      dependencies: [
        .product(name: "VariableBlur", package: "VariableBlur"),
        .product(name: "Router", package: "Model"),
      ]
    ),
    .testTarget(
      name: "DesignSystemTests",
      dependencies: [
        "DesignSystem",
        .product(name: "ViewInspector", package: "ViewInspector"),
      ]
    ),
  ]
)

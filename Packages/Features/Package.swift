// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let baseDeps: [PackageDescription.Target.Dependency] = [
  .product(name: "Client", package: "Model"),
  .product(name: "Models", package: "Model"),
  .product(name: "Auth", package: "Model"),
  .product(name: "User", package: "Model"),
  .product(name: "Destinations", package: "Model"),
  "DesignSystem",
]

let package = Package(
  name: "Features",
  platforms: [.iOS(.v26), .macOS(.v26)],
  products: [
    .library(name: "FeedUI", targets: ["FeedUI"]),
    .library(name: "PostUI", targets: ["PostUI"]),
    .library(name: "ProfileUI", targets: ["ProfileUI"]),
    .library(name: "AuthUI", targets: ["AuthUI"]),
    .library(name: "SettingsUI", targets: ["SettingsUI"]),
    .library(name: "NotificationsUI", targets: ["NotificationsUI"]),
    .library(name: "DesignSystem", targets: ["DesignSystem"]),
    .library(name: "MediaUI", targets: ["MediaUI"]),
    .library(name: "ComposerUI", targets: ["ComposerUI"]),
  ],
  dependencies: [
    .package(name: "Model", path: "../Model"),
    .package(url: "https://github.com/nalexn/ViewInspector", from: "0.10.1"),
    .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
    .package(url: "https://github.com/Dimillian/AppRouter.git", from: "1.0.2"),
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
      dependencies: baseDeps + [
        "FeedUI",
        .product(name: "Nuke", package: "Nuke"),
        .product(name: "NukeUI", package: "Nuke"),
      ]
    ),
    .target(
      name: "ProfileUI",
      dependencies: baseDeps + ["FeedUI", "PostUI"]
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
      name: "MediaUI",
      dependencies: baseDeps + [
        .product(name: "Nuke", package: "Nuke"),
        .product(name: "NukeUI", package: "Nuke"),
      ]
    ),
    .target(
      name: "NotificationsUI",
      dependencies: baseDeps + ["PostUI"]
    ),
    .target(
      name: "ComposerUI",
      dependencies: baseDeps
    ),
    .target(
      name: "DesignSystem",
      dependencies: [
        .product(name: "Destinations", package: "Model"),
        "AppRouter",
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

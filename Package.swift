// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "SwiftUIInterfaceOrientation",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    .library(
      name: "SwiftUIInterfaceOrientation",
      targets: ["SwiftUIInterfaceOrientation"]
    )
  ],
  targets: [
    .target(
      name: "SwiftUIInterfaceOrientation"
    ),
    .testTarget(
      name: "SwiftUIInterfaceOrientationTests",
      dependencies: ["SwiftUIInterfaceOrientation"]
    ),
  ],
  swiftLanguageModes: [.v5]
)

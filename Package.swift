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
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
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

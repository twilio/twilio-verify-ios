// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "TwilioVerify",
  platforms: [
    .iOS(.v10)
  ],
  products: [
    .library(
      name: "TwilioVerify",
      targets: ["TwilioVerify"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "TwilioVerify",
      dependencies: [],
      path: "TwilioVerify"
    ),
    .testTarget(
      name: "TwilioVerifyTests",
      dependencies: ["TwilioVerify"],
      path: "TwilioVerifyTests"
    )
  ]
)

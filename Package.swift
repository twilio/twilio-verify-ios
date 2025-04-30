// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "TwilioVerifySDK",
  platforms: [
    .iOS(.v12)
  ],
  products: [
    .library(
      name: "TwilioVerifySDK",
      targets: ["TwilioVerifySDK"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "TwilioVerifySDK",
      dependencies: [],
      path: "TwilioVerifySDK"
    ),
    .testTarget(
      name: "TwilioVerifySDKTests",
      dependencies: ["TwilioVerifySDK"],
      path: "TwilioVerifySDKTests"
    )
  ]
)

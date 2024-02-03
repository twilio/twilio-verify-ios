// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TwilioVerifyDemoCache",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "TwilioVerifyDemoCache",
            targets: ["TwilioVerifyDemoCache"]
        )
    ],
    dependencies: [
        .package(name: "TwilioVerifySDK", path: "../")
    ],
    targets: [
        .target(
            name: "TwilioVerifyDemoCache",
            dependencies: [
                .product(name: "TwilioVerifySDK", package: "TwilioVerifySDK")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "TwilioVerifyDemoCacheTests",
            dependencies: ["TwilioVerifyDemoCache"],
            path: "Tests"
        )
    ]
)

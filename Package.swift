// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "webauthn-models-swift",
    platforms: [
        .macOS(.v12),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "WebAuthnModels",
            targets: ["WebAuthnModels"]
        ),
        .library(
            name: "Base64Swift",
            targets: ["Base64Swift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMinor(from: "2.6.0"))
    ],
    targets: [
        .target(
            name: "Base64Swift"
        ),
        .target(
            name: "WebAuthnModels",
            dependencies: [
                .target(name: "Base64Swift"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "_CryptoExtras", package: "swift-crypto")
            ]
        ),
        .testTarget(
            name: "Base64SwiftTests",
            dependencies: [
                .target(name: "Base64Swift")
            ]
        )
    ]
)

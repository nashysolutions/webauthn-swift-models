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
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMinor(from: "2.6.0")),
        .package(url: "https://github.com/nashysolutions/base64-swift.git", .upToNextMinor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "WebAuthnModels",
            dependencies: [
                .product(name: "Base64Swift", package: "base64-swift"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "_CryptoExtras", package: "swift-crypto")
            ]
        )
    ]
)

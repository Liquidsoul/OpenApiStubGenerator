// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenApiStubGenerator",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "openapi-stub-generator", targets: ["OpenApiStubGenerator"]),
        .library(name: "SwaggerFaker", targets: ["SwaggerFaker"])
    ],
    dependencies: [
        .package(url: "https://github.com/yonaskolb/SwagGen.git", .upToNextMajor(from: "4.6.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.0.2")),
        .package(url: "https://github.com/vadymmarkov/Fakery", .upToNextMajor(from: "5.1.0")),
    ],
    targets: [
        .target(
            name: "OpenApiStubGenerator",
            dependencies: [
                "SwaggerFaker",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(name: "SwaggerFaker",
                dependencies: [
                    .product(name: "Swagger", package: "SwagGen"),
                    .product(name: "Fakery", package: "Fakery")
                ]),
        .testTarget(name: "SwaggerFakerTests",
                    dependencies: ["SwaggerFaker"])
    ]
)

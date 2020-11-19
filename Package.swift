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
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/liquidsoul/SwagGen.git", .branch("swagger/initializers")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/Liquidsoul/Fakery", .branch("spm/resources"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
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

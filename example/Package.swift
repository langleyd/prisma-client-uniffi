// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "prisma-client-uniffi",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "prisma-client-uniffi",
            targets: ["prisma-client-uniffi"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
               name: "prisma_client_uniffi_exampleFFI",
               path: "platforms/ios/lib/PrismaExample/prisma_client_uniffi_exampleFFI.xcframework"
           ),
        .target(
            name: "prisma-client-uniffi",
            dependencies: [
                            .target(name: "prisma_client_uniffi_exampleFFI")
                        ],
            path: "platforms/ios/lib/PrismaExample/Sources"
        ),
        .testTarget(
            name: "prisma-client-uniffiTests",
            dependencies: ["prisma-client-uniffi"],
            path: "platforms/ios/lib/PrismaExample/Tests"),
    ]
)

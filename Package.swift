// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ReceiptArchive",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "ReceiptArchive", targets: ["ReceiptArchive"])
    ],
    targets: [
        .executableTarget(name: "ReceiptArchive"),
        .testTarget(name: "ReceiptArchiveTests", dependencies: ["ReceiptArchive"])
    ]
)

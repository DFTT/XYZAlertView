// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "XYZAlert",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "XYZAlert", targets: ["XYZAlert"])
    ],
    targets: [
        .target(
            name: "XYZAlert",
            path: "XYZAlert/Classes",
            publicHeadersPath: "."
        )
    ]
)

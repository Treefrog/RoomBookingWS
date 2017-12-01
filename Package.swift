import PackageDescription

let package = Package(
    name: "RoomBookingWS",
    targets: [
        Target(
            name: "RoomBookingWS",
            dependencies: []),
        Target(
            name: "RoomBookingWSExe",
            dependencies: ["RoomBookingWS"]),
        ],
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Session-PostgreSQL.git", majorVersion: 3),
        .Package(url: "https://github.com/SwiftORM/Postgres-StORM.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 3),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-SMTP.git", majorVersion: 3),
        .Package(url: "https://github.com/iamjono/SwiftRandom.git", majorVersion: 0)
    ]
)

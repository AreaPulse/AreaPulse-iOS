import ProjectDescription

let project = Project(
    name: "AreaPulse",
    packages: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMinor(from: "15.0.0")),
    ],
    settings: .settings(
        configurations: [
            .debug(name: "SecretOnly", xcconfig: .relativeToRoot("../AreaPulse-iOS/AreaPulse/Core/Utils/Secret.xcconfig")),
            .release(
                name: "Release",
                xcconfig: .relativeToRoot("../AreaPulse-iOS/AreaPulse/Core/Utils/Secret.xcconfig")
            )
        ]
    ),
    targets: [
        .target(
            name: "AreaPulse",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.AreaPulse",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                        "API_URL": "$(API_URL)",
                    ],
                ]
            ),
            sources: ["AreaPulse/**"],
            resources: ["AreaPulse/Resources/**"],
            dependencies: [
                .package(product: "Moya"),
            ],
        ),
        .target(
            name: "AreaPulseTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.AreaPulseTests",
            infoPlist: .default,
            sources: ["../AreaPulse-iOS/Tests/**"],
            resources: [],
            dependencies: [.target(name: "AreaPulse")]
        ),
    ]
)

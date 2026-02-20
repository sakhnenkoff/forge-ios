# Essentia Core Packages

## About

Essentia Core Packages is a focused Swift package suite that bundles a single Core module (Domain, Data, Networking, Local Persistence) plus DesignSystem, so you can ship fast without wiring multiple targets.


## Packages

- Core: Domain + Data + Networking + Local Persistence in one module
- CoreMock: Mocks for Core (testing and previews)
- DesignSystem: UI components, colors, typography, resources

## Requirements

- Swift 5.9+ (tools 6.0)
- iOS 18.0+

## Installation (SPM)

Package.swift example:

```swift
dependencies: [
    .package(url: "https://github.com/sakhnenkoff/essentia-core-packages.git", from: "1.0.0")
]
```

Add products to targets:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "Core", package: "essentia-core-packages"),
        .product(name: "CoreMock", package: "essentia-core-packages"),
        .product(name: "DesignSystem", package: "essentia-core-packages")
    ]
)
```

Xcode: File > Add Packages... then use the repo URL.

## Local Override (Development)

In Xcode, use File > Packages > Add Local... and point to a local clone of this repo. Xcode will prefer the local package while you iterate.

## Development

```bash
swift build
swift test
```

## Release

1. Update code and tests
2. Run `swift test`
3. Tag and push: `git tag x.y.z && git push --tags`

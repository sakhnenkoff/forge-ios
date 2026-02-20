# Forge Core Packages

## About

Forge Core Packages is a focused Swift package suite that bundles a single Core module (Domain, Data, Networking, Local Persistence) plus DesignSystem, so you can ship fast without wiring multiple targets.

This is a **local package** embedded in the Forge project at `Packages/core-packages/`. No separate repository needed — the Xcode project references it directly.

## Packages

- Core: Domain + Data + Networking + Local Persistence in one module
- CoreMock: Mocks for Core (testing and previews)
- DesignSystem: UI components, colors, typography, resources

## Requirements

- Swift 5.9+ (tools 6.0)
- iOS 18.0+

## Development

```bash
swift build
swift test
```

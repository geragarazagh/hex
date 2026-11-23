# AGENTS.md — #HEX

Zero-permission macOS pixel colour picker (`#RRGGBB` sRGB via `NSColorSampler` + Carbon hot key) in plain Swift + AppKit. No Xcode project; `./build` compiles directly with `swiftc`.

## Architecture

- `main.swift` — `App` delegate, `NSColorSampler` loupe, `App.hex(_:)` sRGB conversion.
- `cli.swift` — `hex-cli` (`pick`, `status`, `--version`, `--help`) with `answersForItself()` guard.
- `window.swift` — shared 340 pt fixed settings window, Carbon hot-key recorder, Open at Login helper.
- `updates.swift` — Sparkle 2.10.1 updater.

## Build

- `./build` — builds ad-hoc signed `#HEX.app` (`-target arm64-apple-macos13.0`). Works with Xcode Command Line Tools alone (`iconutil` fallback). Full Xcode is used for `Assets.car` (required when `SIGN_ID` is set).

## Invariants

- **Zero permissions**: `NSColorSampler` and Carbon `RegisterEventHotKey` require neither Screen Recording nor Accessibility.
- **Customizing locally**: change colour formatting (e.g. lowercase or RGB/HSL) in `App.hex(_:)` in `main.swift`, run `./build`, replace `/Applications/#HEX.app`.

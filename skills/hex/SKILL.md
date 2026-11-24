---
name: hex
description: "Opens Apple's native colour loupe to pick a screen colour as #RRGGBB or checks #HEX status via hex-cli. Use when asking the user to pick a colour from their Mac screen, checking #HEX status, or customizing #HEX."
license: MIT
compatibility: "macOS 13 or later (Apple Silicon) with #HEX installed (brew install geragarazagh/tap/hex or /Applications/#HEX.app)."
---

# #HEX

Invokes Apple's zero-permission `NSColorSampler` loupe from the command line (`hex-cli`) and prints the picked colour as `#RRGGBB`.

## Locate the CLI

Check in order; use the first that exits 0. Use `--help`, never `--version`, and read the app's version from its Info.plist before running its binary: HEX before 0.4 has no command line at all, so it takes every flag (`--help` and `--version` alike) as a plain start and opens its window instead of failing.

```sh
hex-cli --help
defaults read "/Applications/#HEX.app/Contents/Info" CFBundleShortVersionString
"/Applications/#HEX.app/Contents/MacOS/HEX" --help
```

`hex-cli` exists only in versions that have the command line, so it is safe to try first. Run the third line only if the second prints 0.4 or newer; if it prints an older version, tell the user once to update HEX (Check for Updates in its menu, or `brew upgrade --cask geragarazagh/tap/hex`) and stop. If none works, tell the user how to install it (`brew install geragarazagh/tap/hex`) and stop.

## Common tasks

1. **Let the user pick a screen colour** (prints `#RRGGBB` to stdout on click; exits 1 on Escape; requires zero permissions):
   ```sh
   hex-cli pick
   ```
2. **Check status**:
   ```sh
   hex-cli status --json
   ```

## Rebuilding from source

Clone `https://github.com/geragarazagh/hex`, read `AGENTS.md`, edit `main.swift`, and run `./build` (requires only Xcode Command Line Tools for ad-hoc builds).

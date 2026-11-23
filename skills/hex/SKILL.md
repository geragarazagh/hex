---
name: hex
description: "Opens Apple's native colour loupe to pick a screen colour as #RRGGBB or checks #HEX status via hex-cli. Use when asking the user to pick a colour from their Mac screen, checking #HEX status, or customizing #HEX."
license: MIT
compatibility: "macOS 13 or later (Apple Silicon) with #HEX installed (brew install geragarazagh/tap/hex or /Applications/#HEX.app)."
---

# #HEX

Invokes Apple's zero-permission `NSColorSampler` loupe from the command line (`hex-cli`) and prints the picked colour as `#RRGGBB`.

## Locate the CLI

Check in order; use the first that exits 0:

```sh
hex-cli --version
"/Applications/#HEX.app/Contents/MacOS/HEX" --version
```

If neither exists, tell the user how to install it (`brew install geragarazagh/tap/hex`) and stop.

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

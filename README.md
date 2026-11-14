English · [Українська](README_UA.md) · [Русский](README_RU.md)

<picture><source media="(prefers-color-scheme: dark)" srcset="docs/icon-dark.png"><img src="docs/icon.png" width="128" alt="#HEX icon"></picture>

# #HEX: color picker for Mac

Free, open source color picker (eyedropper) for macOS. Press a keyboard shortcut anywhere and the color sampler of macOS opens, with its magnifier. Click any pixel on the screen and its color goes to the clipboard as a HEX code, for example `#EFEFEF`.

Apple silicon, macOS 13 or later. Interface in English, Ukrainian and Russian. Signed with a Developer ID and notarized by Apple.

The same color picker is part of [Pixlift](https://github.com/geragarazagh/pixlift), on Option-Command-5, together with screenshots, screen recording and text from the screen.

![#HEX in use: the macOS loupe on the red field of Mondrian's Composition II in Red, Blue, and Yellow, open in Preview, and the five picked codes in TextEdit, dark appearance](docs/scene.webp)

## Install

**Mac** (Apple silicon, macOS 13 or later): download [`HEX.dmg`](https://github.com/geragarazagh/hex/releases/latest/download/HEX.dmg) (1.7 MB), open it and drag `#HEX.app` to Applications. Later versions arrive through Check for Updates.

Or with [Homebrew](https://brew.sh):

```sh
brew install geragarazagh/tap/hex
```

## Use

Option-Command-0 opens the sampler. A click copies the color, Esc cancels.

The window has Check for Updates, Shortcut, Open at Login and Quit. Opening the app shows its window. Closing the window leaves the shortcut working.

## For advanced users and language models

#HEX adds no picker of its own. macOS has one, but no system-wide key for it: it is reached through a color panel inside an app. #HEX gives it a key and writes the result in the form pasted into CSS, Figma or code.

### What it does

- Picks any pixel of any app on the screen.
- Shortcut: Option-Command-0 by default, changed in the window.
- One output: sRGB, upper case, `#RRGGBB`.
- Nothing in the Dock or the menu bar. Open at Login stays off until it is turned on.

### How it works

- The loupe is `NSColorSampler`, the one the color panels of macOS open. It needs no permission, and Esc closes it.
- The color it returns is the pixel in the center of the loupe. #HEX converts it to sRGB, 8 bits per channel, and writes it in upper case after `#`.
- The shortcut is a Carbon hot key (`RegisterEventHotKey`), which needs no Accessibility. It is stored as a physical key, so it works in every keyboard layout.
- A second press while the loupe is open keeps the same loupe; only the latest press copies.
- macOS does not report a shortcut that another app already holds. If it does nothing, another one can be chosen in the window.

### Questions

#### Does macOS have a color picker?

Yes, and #HEX opens exactly that one. There is also Digital Color Meter in Utilities: it stays open as a window showing values under the pointer, and one is copied with Shift-Command-C. With #HEX it is a key and a click, and the code is already on the clipboard.

#### Which color space is the code in?

sRGB, the space of web colors and, by default, of Figma and Photoshop documents. Colors outside sRGB are clamped.

#### Why can a color picked in Safari differ by one from its CSS value?

WebKit paints pages into the display’s 8-bit P3 space, which merges about half of all sRGB colors with a neighbour. The screen itself then holds a color 1 off, rarely up to 5, and no picker can undo that. Colors drawn by Mac apps came back exact in a test of 48 of 48.

#### Are other formats available: RGB, HSL, SwiftUI?

No. Only `#RRGGBB`.

#### Does it run on Intel Macs?

No. Apple silicon only, macOS 13 or later.

### Updates

Once a day the app reads the feed of its latest GitHub release (`appcast.xml`) through Sparkle. Nothing about the Mac is sent. When a newer version is out, a window shows it with Install Update, Remind Me Later and Skip This Version; nothing is downloaded before Install Update. Check for Updates in the window checks at once.

The feed and the disk image are signed with an EdDSA key, and Sparkle installs only an app that carries the same Developer ID signature.

### Settings and removal

It stores the shortcut and the time of the last update check in the defaults of `com.geragaraza.hex`. Open at Login is a login item the app registers itself (`SMAppService`) and turns off from the same window.

To remove #HEX: Quit in its window, move `#HEX.app` to the Trash and clear its settings with this command:

```sh
defaults delete com.geragaraza.hex
```

Installed with Homebrew, this command quits it and removes the app and its settings:

```sh
brew uninstall --zap hex
```

### Details

- Version: 0.3.
- Bundle ID: `com.geragaraza.hex`.
- Download: `HEX.dmg`, 1.7 MB.
- Requires: Apple silicon, macOS 13 or later.
- Permissions: none. Network: only the update check.
- Signed with a Developer ID and notarized by Apple.
- Interface: English, Ukrainian, Russian, from the language of macOS.
- Code: Swift with AppKit, about 500 lines, and the Sparkle framework for updates.
- License: MIT. Sparkle is MIT too; its license comes with the app and is in `THIRD-PARTY-LICENSES.md`.

### Build

Needs Xcode 26 or later in Applications: the Swift compiler, and actool with Icon Composer for the light and dark icon. The first build downloads the Sparkle framework from its release.

    ./build

Search terms: color picker for Mac, colour picker macOS, eyedropper tool, pick color from screen, get HEX code from screen, screen color picker, color sampler shortcut, NSColorSampler.

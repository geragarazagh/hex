// #HEX: a hot key -> Apple's own colour sampler -> a click copies the colour as #RRGGBB.
// Apple parts only: NSColorSampler (no permissions at all), a Carbon hot key (no Accessibility).
// No network, no logs. The one thing it keeps is the chosen hot key.
//
// Test without touching the real clipboard (quit the app first, a hot key has one owner):
//   '#HEX.app/Contents/MacOS/HEX' --pasteboard test
//
// Why it is built this way (macOS 27.0.1, measured):
// - The system sampler needs no permission, Esc cancels it, and the colour it returns is
//   exactly the one in the centre of its loupe (32 of 32 single-pixel picks on a test pattern).
// - Hex is sRGB, the space of web colours and of Figma and Photoshop documents by default.
//   Colours drawn by Mac apps came back exact (48 of 48). WebKit pages (Safari) are painted
//   into the display's 8-bit P3 space, which merges about half of all sRGB colours with a
//   neighbour; there the screen itself holds a colour 1 (rarely up to 5) off the CSS value,
//   and no picker can undo that.
// - The sampler has no cancel call. A second press while it is open joins the same loupe
//   (tested), so only the latest press copies.

import AppKit
import Carbon.HIToolbox

@MainActor final class App: NSObject, NSApplicationDelegate {
    let pasteboard: NSPasteboard
    let sampler = NSColorSampler()
    var session = 0
    var window: AppWindow?

    init(pasteboard: NSPasteboard) { self.pasteboard = pasteboard }

    func applicationDidFinishLaunching(_ n: Notification) {
        window = AppWindow(name: "#HEX", github: "https://github.com/geragarazagh/hex",
                           defaultShortcut: Shortcut(key: kVK_ANSI_0, mods: cmdKey | optionKey)) { [weak self] in self?.pick() }
    }

    func applicationShouldHandleReopen(_ a: NSApplication, hasVisibleWindows: Bool) -> Bool {
        window?.show()
        return false
    }

    func pick() {
        session += 1
        let mine = session
        sampler.show { [weak self] color in
            DispatchQueue.main.async {
                guard let self, mine == self.session, let color, let hex = Self.hex(color) else { return }
                self.pasteboard.clearContents()
                self.pasteboard.setString(hex, forType: .string)
            }
        }
    }

    // sRGB, 8 bits per channel, upper case with "#". Colours outside sRGB are clamped per channel.
    static func hex(_ color: NSColor) -> String? {
        guard let c = color.usingColorSpace(.extendedSRGB) else { return nil }
        let v = [c.redComponent, c.greenComponent, c.blueComponent].map { max(0, min(255, Int(($0 * 255).rounded()))) }
        return String(format: "#%02X%02X%02X", v[0], v[1], v[2])
    }
}

startInBackgroundIfAtLogin()

let args = CommandLine.arguments
let pasteboard = args.count > 2 && args[1] == "--pasteboard" ? NSPasteboard(name: .init(args[2])) : .general

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = App(pasteboard: pasteboard)
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}

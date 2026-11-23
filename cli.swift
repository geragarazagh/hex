// Command line interface for #HEX: pick a colour via Apple's native NSColorSampler loupe and print #RRGGBB, or inspect status.
// Run as hex-cli (symlink to #HEX.app/Contents/MacOS/HEX) or as HEX with subcommands:
//
//   hex-cli pick              opens Apple's native colour loupe; prints #RRGGBB on click (exit 1 on Esc)
//   hex-cli status [--json]   prints version, running state and Open at Login status
//   hex-cli --version | --help

import AppKit
import ServiceManagement

private let hexCliName = "hex-cli"

private let hxAppBundle: Bundle = {
    let real = URL(fileURLWithPath: CommandLine.arguments[0]).resolvingSymlinksInPath()
    let appURL = real.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    return Bundle(url: appURL) ?? .main
}()

private func hexAnswersForItself() -> Bool {
    typealias Lookup = @convention(c) (pid_t) -> pid_t
    let me = getpid()
    if let f = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "responsibility_get_pid_responsible_for_pid") {
        let r = unsafeBitCast(f, to: Lookup.self)(me)
        if r > 0 { return r == me }
    }
    return getppid() == 1
}

private func hxFail(_ s: String) -> Never {
    FileHandle.standardError.write(Data((s + "\n").utf8))
    exit(1)
}

private func hxJSON(_ obj: Any) -> Never {
    guard let data = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]),
          let text = String(data: data, encoding: .utf8) else { hxFail("Could not encode JSON.") }
    print(text)
    exit(0)
}

private func hxRunning() -> Bool {
    guard let id = hxAppBundle.bundleIdentifier else { return false }
    return NSRunningApplication.runningApplications(withBundleIdentifier: id).contains { $0.processIdentifier != getpid() }
}

@MainActor func runHexCLI(_ rawArgs: [String]) -> Bool {
    let exe = hxAppBundle.object(forInfoDictionaryKey: "CFBundleExecutable") as? String ?? "HEX"
    let named = URL(fileURLWithPath: rawArgs[0]).lastPathComponent != exe
    let rest = Array(rawArgs.dropFirst())
    let usage = """
    Usage: \(hexCliName) pick                opens Apple's colour loupe and prints #RRGGBB on click
           \(hexCliName) status [--json]     prints version, running state and Open at Login status
           \(hexCliName) --version | --help
    """
    let guiFlags: Set<String> = ["--login", "--background", "--pasteboard"]
    guard let cmd = rest.first else {
        if named { print(usage); exit(0) }
        return false
    }
    switch cmd {
    case "--help", "-h":
        print(usage); exit(0)
    case "--version", "-V":
        let v = hxAppBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        print("#HEX \(v)"); exit(0)
    case "pick", "status":
        break
    default:
        if named || (cmd.hasPrefix("--") && !guiFlags.contains(cmd)) { hxFail(usage) }
        return false
    }
    if hexAnswersForItself() {
        hxFail("\(hexCliName) runs from a terminal or script, not launched as an app or launchd job.")
    }

    let tail = Array(rest.dropFirst())
    switch cmd {
    case "status":
        let json = tail == ["--json"]
        guard tail.isEmpty || json else { hxFail(usage) }
        let version = hxAppBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let running = hxRunning()
        let login = SMAppService.agent(plistName: "\(hxAppBundle.bundleIdentifier ?? "com.geragaraza.hex").login.plist").status == .enabled
        if json {
            hxJSON(["version": version, "running": running, "openAtLogin": login])
        }
        print("version: \(version)")
        print("running: \(running ? "yes" : "no")")
        print("openAtLogin: \(login ? "yes" : "no")")
        exit(0)

    case "pick":
        guard tail.isEmpty else { hxFail(usage) }
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        let sampler = NSColorSampler()
        DispatchQueue.main.async {
            sampler.show { color in
                DispatchQueue.main.async {
                    if let color, let hex = App.hex(color) {
                        print(hex)
                        exit(0)
                    }
                    exit(1)
                }
            }
        }
        app.run()
        exit(1)

    default:
        hxFail(usage)
    }
}

// #HEX app icon. Since 2026-11-09 an Icon Composer icon (macOS 26+ switches it with the theme, Apple's way):
// this draws only the picture, 1024 px, transparent, the same in light and dark (the loupe looks the same on
// any screen); the plate is the system's own fill, ./build writes icon.json and runs actool. The scene is Apple's own colour sampler loupe, copied
// from a screen recording of it: the thick outer ring takes the colour of the centre
// pixel, a thin inner line, 9 magnified pixels across with faint grid lines, the centre pixel framed
// by a rounded square (white on dark pixels, black on light). Measured at 2x on a 242 px loupe:
// ring 26, inner line 6, pixel pitch 21, centre frame 27 with a 6 px stroke.
// Under the loupe is a rainbow in the manner of the Colors panel's Spectrum: hues top to bottom, light
// to dark left to right. Its centre is a light cyan, so the ring is that cyan: the icon obeys the
// loupe's own rule.
// Usage: ./build runs this: icon <dir> writes <dir>/light.png and <dir>/dark.png (identical).

import AppKit

struct RGB { var r, g, b: CGFloat
    var cg: CGColor { CGColor(srgbRed: r, green: g, blue: b, alpha: 1) }
    var lum: CGFloat { 0.2126 * r + 0.7152 * g + 0.0722 * b }
}

// The 9 x 9 magnified pixels, row by row, as sRGB.
let half = 4
let pixels: [UInt32] = [
    0xF5EBE5, 0xE3B79C, 0xDC8055, 0xE46132, 0xEB5A2A, 0xDE592A, 0xAE4C26, 0x66301C, 0x1E0F0A,
    0xF6F6E7, 0xE7E8A1, 0xE4E764, 0xECEF51, 0xF5FA51, 0xE1E34B, 0xAEAE3C, 0x676525, 0x1E1A0B,
    0xEDF7E6, 0xC0E9A0, 0x97E662, 0x86F14D, 0x84FA4C, 0x7FEB49, 0x67B73B, 0x3F6924, 0x141B0A,
    0xE8F6EB, 0xAAE8B5, 0x7BE681, 0x72F066, 0x74F962, 0x6DEA5E, 0x56B64F, 0x336930, 0x0F1B0F,
    0xE8F6F5, 0xAAE7E4, 0x7AE5DD, 0x71EEE3, 0x74F8EA, 0x6BE6D8, 0x54B1A4, 0x32675F, 0x0F1B19,
    0xE6EDF6, 0x9FBCE6, 0x5D88E2, 0x346AEC, 0x2A64F4, 0x2C61E6, 0x2953B3, 0x1D3268, 0x0C0F1B,
    0xE9E5F6, 0xAC99E4, 0x6D4BE1, 0x421AEA, 0x3407F4, 0x3710E5, 0x3618B2, 0x251667, 0x0E081B,
    0xF3E6F6, 0xDA9BE4, 0xCE53E1, 0xD233E9, 0xD82FF4, 0xC82EE1, 0x9827AE, 0x591C65, 0x1A091B,
    0xF5E6ED, 0xDF9CBA, 0xD85586, 0xE13669, 0xE93361, 0xDB325F, 0xAC2B51, 0x641D32, 0x1D0A0F,
]
func cell(_ i: Int, _ j: Int) -> RGB {
    let v = pixels[(j + half) * (2 * half + 1) + i + half]
    return RGB(r: CGFloat(v >> 16 & 255) / 255, g: CGFloat(v >> 8 & 255) / 255, b: CGFloat(v & 255) / 255)
}

func draw(_ c: CGContext) {
    // The plate is the system's fill now; the old 824 px plate becomes the whole 1024 canvas.
    c.scaleBy(x: 1024 / 824, y: 1024 / 824); c.translateBy(x: -100, y: -100)

    // loupe
    let o = CGPoint(x: 512, y: 512), D: CGFloat = 640
    let ringW = D * 26 / 242, lineW = D * 6 / 242, pitch = D * 21 / 242
    let mid = cell(0, 0)
    let outer = CGRect(x: o.x - D / 2, y: o.y - D / 2, width: D, height: D)
    c.saveGState()
    c.setShadow(offset: CGSize(width: 0, height: -D * 0.02), blur: D * 0.06, color: CGColor(gray: 0, alpha: 0.55))
    c.setFillColor(mid.cg); c.fillEllipse(in: outer)
    c.restoreGState()
    c.setStrokeColor(CGColor(gray: 0.62, alpha: 1)); c.setLineWidth(D * 1.2 / 242); c.strokeEllipse(in: outer)
    let inner = outer.insetBy(dx: ringW, dy: ringW)
    c.setFillColor(mid.lum > 0.75 ? CGColor(gray: 0.6, alpha: 1) : CGColor(gray: 1, alpha: 1)); c.fillEllipse(in: inner)
    let grid = inner.insetBy(dx: lineW, dy: lineW)
    c.saveGState(); c.addEllipse(in: grid); c.clip()
    for j in -half...half { for i in -half...half {
        let col = cell(i, j)
        let r = CGRect(x: o.x - pitch / 2 + CGFloat(i) * pitch, y: o.y - pitch / 2 - CGFloat(j) * pitch, width: pitch, height: pitch)
        c.setFillColor(col.cg); c.fill(r)
        c.setStrokeColor(col.lum > 0.6 ? CGColor(gray: 0, alpha: 0.22) : CGColor(gray: 1, alpha: 0.5))
        c.setLineWidth(pitch * 0.07); c.stroke(r)
    } }
    c.restoreGState()
    let f = CGRect(x: o.x - pitch / 2 - 3 * pitch / 21, y: o.y - pitch / 2 - 3 * pitch / 21, width: pitch * 27 / 21, height: pitch * 27 / 21)
    c.setStrokeColor(mid.lum > 0.6 ? CGColor(gray: 0, alpha: 1) : CGColor(gray: 1, alpha: 1)); c.setLineWidth(pitch * 6 / 21)
    c.addPath(CGPath(roundedRect: f, cornerWidth: pitch * 0.12, cornerHeight: pitch * 0.12, transform: nil)); c.strokePath()
}

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSGraphicsContext.current!.cgContext.clear(CGRect(x: 0, y: 0, width: 1024, height: 1024))
draw(NSGraphicsContext.current!.cgContext)
NSGraphicsContext.restoreGraphicsState()
let png = rep.representation(using: .png, properties: [:])!
for n in ["light", "dark"] { try! png.write(to: URL(fileURLWithPath: CommandLine.arguments[1] + "/\(n).png")) }

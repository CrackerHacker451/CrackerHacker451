import AppKit
import Foundation

let width = 1600
let height = 600
let arguments = Array(CommandLine.arguments.dropFirst())
let bannerPath = arguments.first ?? "profile-banner.png"
let avatarPath = arguments.dropFirst().first ?? "profile-avatar.png"

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
}

func polygon(_ points: [NSPoint]) -> NSBezierPath {
    let path = NSBezierPath()
    guard let first = points.first else { return path }
    path.move(to: first)
    for point in points.dropFirst() {
        path.line(to: point)
    }
    path.close()
    return path
}

func stroke(_ path: NSBezierPath, color: NSColor, width: CGFloat) {
    path.lineWidth = width
    color.setStroke()
    path.stroke()
}

func fill(_ path: NSBezierPath, color: NSColor) {
    color.setFill()
    path.fill()
}

func drawAvatar() -> NSBitmapImageRep {
    let size = 512
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fatalError("Could not create the avatar drawing context.")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    let canvas = NSRect(x: 0, y: 0, width: size, height: size)
    NSGradient(colors: [color(0.008, 0.025, 0.018), color(0.012, 0.055, 0.03), color(0.005, 0.012, 0.02)])!
        .draw(in: canvas, angle: 35)

    let green = color(0.18, 1, 0.38)
    let dimGreen = color(0.12, 0.62, 0.27, 0.7)
    let grid = NSBezierPath()
    grid.lineWidth = 1
    for x in stride(from: 24, through: size, by: 32) {
        grid.move(to: NSPoint(x: x, y: 0))
        grid.line(to: NSPoint(x: x, y: size))
    }
    for y in stride(from: 24, through: size, by: 32) {
        grid.move(to: NSPoint(x: 0, y: y))
        grid.line(to: NSPoint(x: size, y: y))
    }
    stroke(grid, color: color(0.1, 0.65, 0.25, 0.12), width: 1)

    let terminal = NSBezierPath(roundedRect: NSRect(x: 27, y: 30, width: 458, height: 452), xRadius: 18, yRadius: 18)
    fill(terminal, color: color(0.005, 0.018, 0.014, 0.94))
    stroke(terminal, color: color(0.15, 0.92, 0.34, 0.75), width: 2)
    let titleBar = NSBezierPath(roundedRect: NSRect(x: 28, y: 442, width: 456, height: 39), xRadius: 17, yRadius: 17)
    fill(titleBar, color: color(0.035, 0.12, 0.07))
    let divider = NSBezierPath()
    divider.move(to: NSPoint(x: 29, y: 440))
    divider.line(to: NSPoint(x: 483, y: 440))
    stroke(divider, color: color(0.15, 0.82, 0.3, 0.56), width: 1)

    for (index, dotColor) in [color(1, 0.28, 0.25), color(1, 0.76, 0.2), green].enumerated() {
        let dot = NSBezierPath(ovalIn: NSRect(x: 45 + index * 19, y: 455, width: 9, height: 9))
        fill(dot, color: dotColor)
    }
    let terminalTitle = "root@cracker:~" as NSString
    terminalTitle.draw(
        at: NSPoint(x: 122, y: 452),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 15, weight: .medium),
            .foregroundColor: color(0.46, 0.86, 0.54)
        ]
    )

    let rainColumns: [(CGFloat, [String])] = [
        (55, ["01", "A7", "10", "C3", "0F", "11"]),
        (96, ["F0", "01", "7B", "10", "00"]),
        (410, ["10", "E1", "0A", "FF", "01"]),
        (451, ["C0", "10", "01", "B4", "0F"])
    ]
    for (columnX, items) in rainColumns {
        for (index, text) in items.enumerated() {
            let glyph = text as NSString
            glyph.draw(
                at: NSPoint(x: columnX, y: 137 + CGFloat(index) * 34),
                withAttributes: [
                    .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .bold),
                    .foregroundColor: color(0.15, 0.9, 0.34, max(0.16, 0.64 - CGFloat(index) * 0.07))
                ]
            )
        }
    }

    let hood = NSBezierPath()
    hood.move(to: NSPoint(x: 106, y: 99))
    hood.curve(to: NSPoint(x: 132, y: 315), controlPoint1: NSPoint(x: 73, y: 175), controlPoint2: NSPoint(x: 86, y: 271))
    hood.curve(to: NSPoint(x: 256, y: 408), controlPoint1: NSPoint(x: 154, y: 414), controlPoint2: NSPoint(x: 204, y: 408))
    hood.curve(to: NSPoint(x: 380, y: 315), controlPoint1: NSPoint(x: 308, y: 408), controlPoint2: NSPoint(x: 359, y: 414))
    hood.curve(to: NSPoint(x: 406, y: 99), controlPoint1: NSPoint(x: 426, y: 271), controlPoint2: NSPoint(x: 439, y: 175))
    hood.close()
    NSGradient(colors: [color(0.045, 0.17, 0.095), color(0.012, 0.045, 0.035), color(0.004, 0.017, 0.018)])!
        .draw(in: hood, angle: 90)
    stroke(hood, color: green, width: 3)

    let innerHood = NSBezierPath()
    innerHood.move(to: NSPoint(x: 137, y: 148))
    innerHood.curve(to: NSPoint(x: 256, y: 384), controlPoint1: NSPoint(x: 128, y: 267), controlPoint2: NSPoint(x: 174, y: 360))
    innerHood.curve(to: NSPoint(x: 375, y: 148), controlPoint1: NSPoint(x: 338, y: 360), controlPoint2: NSPoint(x: 384, y: 267))
    stroke(innerHood, color: color(0.1, 0.8, 0.27, 0.76), width: 2)

    let face = polygon([
        NSPoint(x: 164, y: 314), NSPoint(x: 170, y: 242), NSPoint(x: 202, y: 196),
        NSPoint(x: 256, y: 172), NSPoint(x: 310, y: 196), NSPoint(x: 342, y: 242),
        NSPoint(x: 348, y: 314), NSPoint(x: 312, y: 361), NSPoint(x: 256, y: 384),
        NSPoint(x: 200, y: 361)
    ])
    NSGradient(colors: [color(0.018, 0.07, 0.05), color(0.003, 0.018, 0.018)])!
        .draw(in: face, angle: 90)
    stroke(face, color: color(0.2, 1, 0.4, 0.86), width: 2)

    let mask = NSBezierPath(roundedRect: NSRect(x: 157, y: 253, width: 198, height: 55), xRadius: 14, yRadius: 14)
    NSGradient(colors: [color(0.02, 0.18, 0.08), color(0.005, 0.045, 0.035)])!.draw(in: mask, angle: 0)
    stroke(mask, color: color(0.36, 1, 0.42, 0.9), width: 2)

    for (x, y) in [(188.0, 278.0), (305.0, 278.0)] {
        let eye = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: 23, height: 5), xRadius: 2, yRadius: 2)
        fill(eye, color: color(0.54, 1, 0.53))
    }
    for x in stride(from: 224.0, through: 289.0, by: 11.0) {
        let vent = NSBezierPath()
        vent.move(to: NSPoint(x: x, y: 329))
        vent.line(to: NSPoint(x: x, y: 343))
        stroke(vent, color: dimGreen, width: 2)
    }

    let cheekCircuit = NSBezierPath()
    cheekCircuit.move(to: NSPoint(x: 177, y: 313))
    cheekCircuit.line(to: NSPoint(x: 201, y: 333))
    cheekCircuit.line(to: NSPoint(x: 218, y: 333))
    cheekCircuit.move(to: NSPoint(x: 335, y: 313))
    cheekCircuit.line(to: NSPoint(x: 311, y: 333))
    cheekCircuit.line(to: NSPoint(x: 294, y: 333))
    stroke(cheekCircuit, color: color(0.1, 0.9, 0.32, 0.86), width: 2)
    for x in [201.0, 311.0] {
        fill(NSBezierPath(ovalIn: NSRect(x: x - 3, y: 330, width: 6, height: 6)), color: green)
    }

    let codePanel = NSBezierPath(roundedRect: NSRect(x: 135, y: 92, width: 242, height: 51), xRadius: 8, yRadius: 8)
    fill(codePanel, color: color(0.004, 0.025, 0.018, 0.95))
    stroke(codePanel, color: color(0.14, 0.78, 0.29, 0.82), width: 1)
    let code = "0101  1010  0110" as NSString
    code.draw(
        at: NSPoint(x: 157, y: 111),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 15, weight: .bold),
            .foregroundColor: color(0.32, 1, 0.45)
        ]
    )

    for y in stride(from: 186.0, through: 397.0, by: 13.0) {
        let scanline = NSBezierPath()
        scanline.move(to: NSPoint(x: 151, y: y))
        scanline.line(to: NSPoint(x: 361, y: y))
        stroke(scanline, color: color(0.16, 0.92, 0.33, 0.08), width: 1)
    }
    for (x, y, w) in [(112.0, 350.0, 25.0), (378.0, 350.0, 25.0), (99.0, 181.0, 19.0), (394.0, 181.0, 19.0)] {
        let glitch = NSBezierPath(rect: NSRect(x: x, y: y, width: w, height: 3))
        fill(glitch, color: color(0.45, 1, 0.42, 0.82))
    }

    let badge = NSBezierPath(roundedRect: NSRect(x: 215, y: 49, width: 82, height: 31), xRadius: 9, yRadius: 9)
    fill(badge, color: color(0.003, 0.025, 0.016))
    stroke(badge, color: green, width: 1.5)
    let initials = "LC" as NSString
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: 18, weight: .bold),
        .foregroundColor: color(0.52, 1, 0.55)
    ]
    let textSize = initials.size(withAttributes: attributes)
    initials.draw(
        at: NSPoint(x: (CGFloat(size) - textSize.width) / 2, y: 55),
        withAttributes: attributes
    )

    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

func drawBanner(avatar: NSImage) -> NSBitmapImageRep {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        fatalError("Could not create the banner drawing context.")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.imageInterpolation = .high
    let canvas = NSRect(x: 0, y: 0, width: width, height: height)
    NSGradient(colors: [
        color(0.008, 0.024, 0.016),
        color(0.015, 0.045, 0.027),
        color(0.008, 0.016, 0.025)
    ])!.draw(in: canvas, angle: 0)

    let grid = NSBezierPath()
    grid.lineWidth = 1
    for x in stride(from: 700, through: width, by: 42) {
        grid.move(to: NSPoint(x: x, y: 0))
        grid.line(to: NSPoint(x: x, y: height))
    }
    for y in stride(from: 18, through: height, by: 42) {
        grid.move(to: NSPoint(x: 700, y: y))
        grid.line(to: NSPoint(x: width, y: y))
    }
    stroke(grid, color: color(0.15, 0.72, 0.28, 0.12), width: 1)

    let frame = NSBezierPath(roundedRect: canvas.insetBy(dx: 22, dy: 22), xRadius: 22, yRadius: 22)
    stroke(frame, color: color(0.18, 0.94, 0.34, 0.65), width: 2)

    for (x, y, w, h) in [
        (735.0, 78.0, 116.0, 134.0), (852.0, 280.0, 138.0, 160.0),
        (1457.0, 90.0, 119.0, 154.0), (1455.0, 375.0, 119.0, 112.0)
    ] {
        let panel = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: 8, yRadius: 8)
        fill(panel, color: color(0.004, 0.02, 0.013, 0.92))
        stroke(panel, color: color(0.15, 0.78, 0.29, 0.48), width: 1)
        let prompt = "$ _" as NSString
        prompt.draw(
            at: NSPoint(x: x + 11, y: y + h - 24),
            withAttributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .bold),
                .foregroundColor: color(0.39, 1, 0.47, 0.9)
            ]
        )
        for line in 0..<5 {
            let lineWidth = max(20, w - CGFloat((line * 17) % 42) - 27)
            let codeLine = NSBezierPath(roundedRect: NSRect(
                x: x + 12,
                y: y + h - 47 - CGFloat(line) * 15,
                width: lineWidth,
                height: 3
            ), xRadius: 1, yRadius: 1)
            fill(codeLine, color: color(0.16, 0.83, 0.32, 0.26 + CGFloat(line % 2) * 0.12))
        }
    }

    let accent = NSBezierPath(roundedRect: NSRect(x: 104, y: 493, width: 12, height: 12), xRadius: 6, yRadius: 6)
    fill(accent, color: color(0.32, 1, 0.42))
    let kicker = "root@crackerhacker451:~$ whoami" as NSString
    kicker.draw(
        at: NSPoint(x: 130, y: 489),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 17, weight: .medium),
            .foregroundColor: color(0.43, 0.91, 0.5)
        ]
    )

    let name = "LALTESH" as NSString
    name.draw(
        at: NSPoint(x: 99, y: 349),
        withAttributes: [
            .font: NSFont.systemFont(ofSize: 82, weight: .heavy),
            .foregroundColor: color(0.91, 1, 0.91)
        ]
    )
    let surname = "CHAUDHARY" as NSString
    surname.draw(
        at: NSPoint(x: 105, y: 294),
        withAttributes: [
            .font: NSFont.systemFont(ofSize: 43, weight: .bold),
            .foregroundColor: color(0.28, 1, 0.42)
        ]
    )

    let rule = NSBezierPath()
    rule.move(to: NSPoint(x: 107, y: 265))
    rule.line(to: NSPoint(x: 626, y: 265))
    stroke(rule, color: color(0.22, 0.95, 0.37, 0.9), width: 3)

    let handle = "@Crackerhacker451" as NSString
    handle.draw(
        at: NSPoint(x: 107, y: 222),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 27, weight: .semibold),
            .foregroundColor: color(0.69, 0.91, 0.72)
        ]
    )
    let descriptor = "CODE  /  SECURITY  /  SYSTEMS" as NSString
    descriptor.draw(
        at: NSPoint(x: 107, y: 166),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 18, weight: .regular),
            .foregroundColor: color(0.49, 0.7, 0.53)
        ]
    )

    let avatarFrame = NSBezierPath(roundedRect: NSRect(x: 1032, y: 78, width: 446, height: 446), xRadius: 30, yRadius: 30)
    fill(avatarFrame, color: color(0.012, 0.035, 0.02, 0.96))
    stroke(avatarFrame, color: color(0.18, 0.94, 0.34, 0.82), width: 2)
    avatar.draw(in: NSRect(x: 1060, y: 106, width: 390, height: 390))

    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

func writePNG(_ bitmap: NSBitmapImageRep, to path: String) {
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not encode \(path) as PNG.")
    }
    do {
        try data.write(to: URL(fileURLWithPath: path))
    } catch {
        fatalError("Could not write \(path): \(error)")
    }
}

let avatarBitmap = drawAvatar()
writePNG(avatarBitmap, to: avatarPath)
guard let avatarData = avatarBitmap.representation(using: .png, properties: [:]),
      let avatarImage = NSImage(data: avatarData) else {
    fatalError("Could not load the generated avatar for the banner.")
}
writePNG(drawBanner(avatar: avatarImage), to: bannerPath)

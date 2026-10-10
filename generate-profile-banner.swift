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

func fill(_ path: NSBezierPath, _ color: NSColor) {
    color.setFill()
    path.fill()
}

func stroke(_ path: NSBezierPath, _ color: NSColor, _ width: CGFloat) {
    path.lineWidth = width
    color.setStroke()
    path.stroke()
}

func glow(_ path: NSBezierPath, _ color: NSColor, _ width: CGFloat) {
    stroke(path, color.withAlphaComponent(0.12), width * 5)
    stroke(path, color.withAlphaComponent(0.24), width * 2.5)
    stroke(path, color, width)
}

func drawText(_ text: String, x: CGFloat, y: CGFloat, size: CGFloat, weight: NSFont.Weight, foreground: NSColor, mono: Bool = false) {
    let font = mono
        ? NSFont.monospacedSystemFont(ofSize: size, weight: weight)
        : NSFont.systemFont(ofSize: size, weight: weight)
    (text as NSString).draw(
        at: NSPoint(x: x, y: y),
        withAttributes: [.font: font, .foregroundColor: foreground]
    )
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
    NSGradient(colors: [
        color(0.012, 0.008, 0.04),
        color(0.04, 0.009, 0.05),
        color(0.005, 0.035, 0.045)
    ])!.draw(in: canvas, angle: 38)

    let cyan = color(0.03, 0.96, 1)
    let acid = color(0.7, 1, 0.08)
    let magenta = color(1, 0.03, 0.65)
    let red = color(1, 0.12, 0.16)

    let grid = NSBezierPath()
    for x in stride(from: 0, through: size, by: 32) {
        grid.move(to: NSPoint(x: x, y: 0))
        grid.line(to: NSPoint(x: x, y: size))
    }
    for y in stride(from: 0, through: size, by: 32) {
        grid.move(to: NSPoint(x: 0, y: y))
        grid.line(to: NSPoint(x: size, y: y))
    }
    stroke(grid, color(0.14, 0.61, 0.42, 0.12), 1)

    let halo = NSBezierPath()
    halo.appendArc(withCenter: NSPoint(x: 256, y: 254), radius: 225, startAngle: 28, endAngle: 117)
    halo.appendArc(withCenter: NSPoint(x: 256, y: 254), radius: 225, startAngle: 143, endAngle: 198)
    halo.appendArc(withCenter: NSPoint(x: 256, y: 254), radius: 225, startAngle: 223, endAngle: 343)
    glow(halo, cyan, 2)
    let innerHalo = NSBezierPath()
    innerHalo.appendArc(withCenter: NSPoint(x: 256, y: 254), radius: 202, startAngle: 8, endAngle: 94)
    innerHalo.appendArc(withCenter: NSPoint(x: 256, y: 254), radius: 202, startAngle: 162, endAngle: 310)
    glow(innerHalo, magenta, 1.5)

    for (x, y, w, h, hue) in [
        (65.0, 378.0, 36.0, 5.0, cyan), (389.0, 416.0, 50.0, 4.0, magenta),
        (52.0, 175.0, 46.0, 4.0, acid), (415.0, 125.0, 40.0, 5.0, cyan),
        (82.0, 99.0, 30.0, 3.0, magenta), (365.0, 75.0, 52.0, 4.0, acid),
        (28.0, 290.0, 42.0, 3.0, red), (442.0, 301.0, 38.0, 4.0, cyan)
    ] {
        let shard = NSBezierPath(rect: NSRect(x: x, y: y, width: w, height: h))
        fill(shard, hue)
        let split = NSBezierPath(rect: NSRect(x: x + w * 0.28, y: y - 6, width: w * 0.48, height: 2))
        fill(split, color(0.95, 1, 1, 0.8))
    }

    for (x, startY, step, glyphs) in [
        (45.0, 210.0, 25.0, ["0", "1", "A", "7", "F", "0", "1"]),
        (447.0, 190.0, 28.0, ["1", "0", "C", "0", "1", "B"]),
        (112.0, 55.0, 20.0, ["0", "1", "0", "1"]),
        (378.0, 455.0, 19.0, ["1", "0", "1"])
    ] {
        for (index, glyph) in glyphs.enumerated() {
            drawText(
                glyph,
                x: x,
                y: startY + CGFloat(index) * step,
                size: 12,
                weight: .bold,
                foreground: color(0.27, 1, 0.55, 0.28 + CGFloat(index % 3) * 0.15),
                mono: true
            )
        }
    }

    let horns = polygon([
        NSPoint(x: 179, y: 354), NSPoint(x: 55, y: 484), NSPoint(x: 97, y: 322),
        NSPoint(x: 78, y: 203), NSPoint(x: 173, y: 250)
    ])
    NSGradient(colors: [color(0.02, 0.39, 0.42), color(0.018, 0.035, 0.085)])!.draw(in: horns, angle: 130)
    glow(horns, cyan, 2.5)
    let rightHorn = polygon([
        NSPoint(x: 333, y: 354), NSPoint(x: 457, y: 484), NSPoint(x: 415, y: 322),
        NSPoint(x: 434, y: 203), NSPoint(x: 339, y: 250)
    ])
    NSGradient(colors: [color(0.4, 0.015, 0.22), color(0.035, 0.025, 0.09)])!.draw(in: rightHorn, angle: 40)
    glow(rightHorn, magenta, 2.5)

    let skull = polygon([
        NSPoint(x: 131, y: 332), NSPoint(x: 118, y: 270), NSPoint(x: 131, y: 203),
        NSPoint(x: 163, y: 147), NSPoint(x: 211, y: 118), NSPoint(x: 256, y: 108),
        NSPoint(x: 301, y: 118), NSPoint(x: 349, y: 147), NSPoint(x: 381, y: 203),
        NSPoint(x: 394, y: 270), NSPoint(x: 381, y: 332), NSPoint(x: 339, y: 372),
        NSPoint(x: 304, y: 380), NSPoint(x: 296, y: 420), NSPoint(x: 216, y: 420),
        NSPoint(x: 208, y: 380), NSPoint(x: 173, y: 372)
    ])
    NSGradient(colors: [color(0.17, 0.2, 0.23), color(0.035, 0.045, 0.08), color(0.012, 0.02, 0.04)])!
        .draw(in: skull, angle: 90)
    glow(skull, color(0.77, 0.91, 0.76), 1.5)

    let leftPlate = polygon([
        NSPoint(x: 131, y: 203), NSPoint(x: 163, y: 147), NSPoint(x: 211, y: 118),
        NSPoint(x: 234, y: 206), NSPoint(x: 188, y: 240)
    ])
    fill(leftPlate, color(0, 0.83, 0.91, 0.14))
    stroke(leftPlate, cyan, 1)
    let rightPlate = polygon([
        NSPoint(x: 381, y: 203), NSPoint(x: 349, y: 147), NSPoint(x: 301, y: 118),
        NSPoint(x: 278, y: 206), NSPoint(x: 324, y: 240)
    ])
    fill(rightPlate, color(1, 0.02, 0.46, 0.15))
    stroke(rightPlate, magenta, 1)

    let brow = polygon([
        NSPoint(x: 121, y: 245), NSPoint(x: 174, y: 211), NSPoint(x: 226, y: 221),
        NSPoint(x: 256, y: 238), NSPoint(x: 286, y: 221), NSPoint(x: 338, y: 211),
        NSPoint(x: 391, y: 245), NSPoint(x: 364, y: 277), NSPoint(x: 300, y: 263),
        NSPoint(x: 256, y: 279), NSPoint(x: 212, y: 263), NSPoint(x: 148, y: 277)
    ])
    NSGradient(colors: [color(0.28, 0.01, 0.07), color(0.025, 0.025, 0.04), color(0.015, 0.22, 0.08)])!
        .draw(in: brow, angle: 0)
    glow(brow, red, 2)

    let leftEye = polygon([
        NSPoint(x: 148, y: 248), NSPoint(x: 202, y: 230), NSPoint(x: 241, y: 246),
        NSPoint(x: 213, y: 259), NSPoint(x: 161, y: 261)
    ])
    NSGradient(colors: [color(1, 0.03, 0.08), color(0.48, 0.015, 0.04)])!.draw(in: leftEye, angle: 90)
    glow(leftEye, red, 2)
    let rightEye = polygon([
        NSPoint(x: 364, y: 248), NSPoint(x: 310, y: 230), NSPoint(x: 271, y: 246),
        NSPoint(x: 299, y: 259), NSPoint(x: 351, y: 261)
    ])
    NSGradient(colors: [color(0.4, 1, 0.05), color(0.06, 0.5, 0.1)])!.draw(in: rightEye, angle: 90)
    glow(rightEye, acid, 2)

    let pupils = NSBezierPath()
    pupils.move(to: NSPoint(x: 173, y: 247))
    pupils.line(to: NSPoint(x: 220, y: 247))
    pupils.move(to: NSPoint(x: 292, y: 247))
    pupils.line(to: NSPoint(x: 339, y: 247))
    glow(pupils, color(1, 1, 0.84), 2)
    let leftGlint = NSBezierPath(ovalIn: NSRect(x: 185, y: 243, width: 8, height: 8))
    let rightGlint = NSBezierPath(ovalIn: NSRect(x: 319, y: 243, width: 8, height: 8))
    fill(leftGlint, color(1, 1, 1))
    fill(rightGlint, color(1, 1, 1))

    let nose = polygon([
        NSPoint(x: 256, y: 255), NSPoint(x: 276, y: 294), NSPoint(x: 256, y: 312),
        NSPoint(x: 236, y: 294)
    ])
    fill(nose, color(0.08, 0.1, 0.13))
    glow(nose, cyan, 1.5)

    let cheekLeft = polygon([
        NSPoint(x: 145, y: 278), NSPoint(x: 220, y: 268), NSPoint(x: 246, y: 299),
        NSPoint(x: 225, y: 336), NSPoint(x: 177, y: 326)
    ])
    fill(cheekLeft, color(0.015, 0.12, 0.15))
    glow(cheekLeft, cyan, 1.5)
    let cheekRight = polygon([
        NSPoint(x: 367, y: 278), NSPoint(x: 292, y: 268), NSPoint(x: 266, y: 299),
        NSPoint(x: 287, y: 336), NSPoint(x: 335, y: 326)
    ])
    fill(cheekRight, color(0.15, 0.015, 0.09))
    glow(cheekRight, magenta, 1.5)

    let jaw = polygon([
        NSPoint(x: 188, y: 326), NSPoint(x: 225, y: 339), NSPoint(x: 256, y: 329),
        NSPoint(x: 287, y: 339), NSPoint(x: 324, y: 326), NSPoint(x: 298, y: 381),
        NSPoint(x: 278, y: 399), NSPoint(x: 234, y: 399), NSPoint(x: 214, y: 381)
    ])
    fill(jaw, color(0.025, 0.04, 0.055))
    glow(jaw, color(0.62, 0.76, 0.66), 1)
    for i in 0..<7 {
        let tooth = NSBezierPath(rect: NSRect(x: 222 + i * 10, y: 348, width: 5, height: 16))
        fill(tooth, i == 3 ? red : color(0.68, 0.9, 0.76))
    }

    let circuit = NSBezierPath()
    circuit.move(to: NSPoint(x: 141, y: 300))
    circuit.line(to: NSPoint(x: 115, y: 316))
    circuit.line(to: NSPoint(x: 95, y: 316))
    circuit.move(to: NSPoint(x: 371, y: 300))
    circuit.line(to: NSPoint(x: 397, y: 316))
    circuit.line(to: NSPoint(x: 417, y: 316))
    circuit.move(to: NSPoint(x: 173, y: 365))
    circuit.line(to: NSPoint(x: 148, y: 385))
    circuit.move(to: NSPoint(x: 339, y: 365))
    circuit.line(to: NSPoint(x: 364, y: 385))
    glow(circuit, cyan, 2)

    for (x, y, radius, hue) in [
        (91.0, 315.0, 5.0, cyan), (412.0, 315.0, 5.0, acid),
        (145.0, 385.0, 4.0, magenta), (363.0, 385.0, 4.0, cyan),
        (256.0, 106.0, 6.0, acid)
    ] {
        let node = NSBezierPath(ovalIn: NSRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2))
        fill(node, hue)
    }

    let glitchSlices: [(CGFloat, CGFloat, CGFloat, NSColor)] = [
        (71, 356, 78, cyan), (363, 371, 68, magenta), (83, 172, 43, acid),
        (380, 183, 58, red), (126, 410, 35, magenta), (347, 116, 43, cyan),
        (54, 290, 29, red), (423, 335, 32, acid), (203, 94, 47, cyan)
    ]
    for (x, y, w, hue) in glitchSlices {
        fill(NSBezierPath(rect: NSRect(x: x, y: y, width: w, height: 4)), hue)
        fill(NSBezierPath(rect: NSRect(x: x + 9, y: y - 6, width: w * 0.54, height: 2)), color(1, 1, 1, 0.7))
    }

    let sigil = NSBezierPath(roundedRect: NSRect(x: 189, y: 50, width: 134, height: 34), xRadius: 6, yRadius: 6)
    fill(sigil, color(0.006, 0.015, 0.025))
    glow(sigil, acid, 1)
    drawText("LC // 451", x: 202, y: 60, size: 15, weight: .bold, foreground: color(0.86, 1, 0.45), mono: true)

    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

func drawBanner() -> NSBitmapImageRep {
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
    let canvas = NSRect(x: 0, y: 0, width: width, height: height)
    NSGradient(colors: [color(0.008, 0.018, 0.014), color(0.025, 0.012, 0.032), color(0.004, 0.025, 0.027)])!
        .draw(in: canvas, angle: 0)

    let grid = NSBezierPath()
    for x in stride(from: 0, through: width, by: 48) {
        grid.move(to: NSPoint(x: x, y: 0))
        grid.line(to: NSPoint(x: x, y: height))
    }
    for y in stride(from: 0, through: height, by: 48) {
        grid.move(to: NSPoint(x: 0, y: y))
        grid.line(to: NSPoint(x: width, y: y))
    }
    stroke(grid, color(0.1, 0.57, 0.32, 0.11), 1)

    let border = NSBezierPath(roundedRect: canvas.insetBy(dx: 22, dy: 22), xRadius: 22, yRadius: 22)
    glow(border, color(0.15, 1, 0.39), 1.5)
    let accent = NSBezierPath(ovalIn: NSRect(x: 102, y: 495, width: 11, height: 11))
    fill(accent, color(0.23, 1, 0.42))
    drawText("root@crackerhacker451:~$ whoami", x: 128, y: 490, size: 17, weight: .medium, foreground: color(0.48, 0.95, 0.55), mono: true)

    drawText("LALTESH", x: 99, y: 350, size: 82, weight: .heavy, foreground: color(0.93, 1, 0.93))
    drawText("CHAUDHARY", x: 105, y: 295, size: 43, weight: .bold, foreground: color(0.25, 1, 0.43))

    let rule = NSBezierPath()
    rule.move(to: NSPoint(x: 107, y: 267))
    rule.line(to: NSPoint(x: 626, y: 267))
    glow(rule, color(0.22, 1, 0.4), 2)
    drawText("@Crackerhacker451", x: 107, y: 224, size: 27, weight: .semibold, foreground: color(0.75, 0.95, 0.79), mono: true)
    drawText("CODE  /  SECURITY  /  SYSTEMS", x: 107, y: 168, size: 18, weight: .regular, foreground: color(0.53, 0.74, 0.57), mono: true)
    drawText("AUTHORIZED TO EXPLORE", x: 107, y: 127, size: 13, weight: .medium, foreground: color(0.34, 0.62, 0.42), mono: true)

    for (x, y, w, h) in [
        (741.0, 80.0, 115.0, 127.0), (855.0, 285.0, 128.0, 159.0),
        (1454.0, 82.0, 119.0, 155.0), (1456.0, 378.0, 117.0, 103.0)
    ] {
        let panel = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: 8, yRadius: 8)
        fill(panel, color(0.004, 0.022, 0.015, 0.94))
        stroke(panel, color(0.15, 0.82, 0.32, 0.52), 1)
        drawText("$ _", x: x + 11, y: y + h - 24, size: 13, weight: .bold, foreground: color(0.38, 1, 0.48), mono: true)
        for line in 0..<5 {
            let lineWidth = max(20, w - CGFloat((line * 17) % 42) - 27)
            let codeLine = NSBezierPath(roundedRect: NSRect(
                x: x + 12,
                y: y + h - 47 - CGFloat(line) * 15,
                width: lineWidth,
                height: 3
            ), xRadius: 1, yRadius: 1)
            fill(codeLine, color(0.17, 0.84, 0.32, 0.3 + CGFloat(line % 2) * 0.12))
        }
    }

    let matrixPanel = NSBezierPath(roundedRect: NSRect(x: 1025, y: 73, width: 438, height: 455), xRadius: 24, yRadius: 24)
    fill(matrixPanel, color(0.004, 0.017, 0.016, 0.92))
    glow(matrixPanel, color(0.2, 1, 0.42), 1.5)
    drawText("ACCESS / NODE 451", x: 1081, y: 485, size: 13, weight: .semibold, foreground: color(0.44, 1, 0.55), mono: true)

    let rings = NSBezierPath()
    rings.appendArc(withCenter: NSPoint(x: 1244, y: 294), radius: 157, startAngle: 18, endAngle: 163)
    rings.appendArc(withCenter: NSPoint(x: 1244, y: 294), radius: 157, startAngle: 195, endAngle: 345)
    glow(rings, color(0.15, 1, 0.38), 2)
    let innerRings = NSBezierPath()
    innerRings.appendArc(withCenter: NSPoint(x: 1244, y: 294), radius: 124, startAngle: 40, endAngle: 142)
    innerRings.appendArc(withCenter: NSPoint(x: 1244, y: 294), radius: 124, startAngle: 220, endAngle: 320)
    glow(innerRings, color(0.76, 1, 0.14), 1.5)

    let crosshair = NSBezierPath()
    crosshair.move(to: NSPoint(x: 1068, y: 294))
    crosshair.line(to: NSPoint(x: 1420, y: 294))
    crosshair.move(to: NSPoint(x: 1244, y: 117))
    crosshair.line(to: NSPoint(x: 1244, y: 471))
    stroke(crosshair, color(0.21, 0.82, 0.37, 0.38), 1)
    let core = NSBezierPath(ovalIn: NSRect(x: 1210, y: 260, width: 68, height: 68))
    fill(core, color(0.008, 0.042, 0.021))
    glow(core, color(0.17, 1, 0.34), 2)
    drawText("451", x: 1214, y: 282, size: 22, weight: .bold, foreground: color(0.66, 1, 0.6), mono: true)

    for (x, y) in [(1122.0, 380.0), (1361.0, 378.0), (1092.0, 204.0), (1389.0, 214.0)] {
        let node = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: 8, height: 8))
        fill(node, color(0.74, 1, 0.13))
    }

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

writePNG(drawAvatar(), to: avatarPath)
writePNG(drawBanner(), to: bannerPath)

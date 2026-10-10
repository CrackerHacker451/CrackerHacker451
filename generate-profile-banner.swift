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

func neonStroke(_ path: NSBezierPath, color: NSColor, width: CGFloat) {
    stroke(path, color: color.withAlphaComponent(0.12), width: width * 4)
    stroke(path, color: color.withAlphaComponent(0.24), width: width * 2)
    stroke(path, color: color, width: width)
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
    NSGradient(colors: [color(0.014, 0.01, 0.035), color(0.025, 0.012, 0.04), color(0.004, 0.025, 0.018)])!
        .draw(in: canvas, angle: 32)

    let green = color(0.25, 1, 0.42)
    let acid = color(0.73, 1, 0.15)
    let red = color(1, 0.12, 0.27)

    let grid = NSBezierPath()
    grid.lineWidth = 1
    for x in stride(from: 0, through: size, by: 32) {
        grid.move(to: NSPoint(x: x, y: 0))
        grid.line(to: NSPoint(x: x, y: size))
    }
    for y in stride(from: 0, through: size, by: 32) {
        grid.move(to: NSPoint(x: 0, y: y))
        grid.line(to: NSPoint(x: size, y: y))
    }
    stroke(grid, color: color(0.16, 0.72, 0.29, 0.1), width: 1)

    let rain = [
        (CGFloat(40), "010101 101100 011010"),
        (CGFloat(448), "101110 010101 110010"),
        (CGFloat(75), "011001 100101 011101"),
        (CGFloat(422), "110010 011100 101011")
    ]
    for (column, text) in rain {
        for row in 0..<3 {
            let glyph = String(text.dropFirst(row * 7).prefix(6)) as NSString
            glyph.draw(
                at: NSPoint(x: column, y: 126 + CGFloat(row) * 39),
                withAttributes: [
                    .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .bold),
                    .foregroundColor: color(0.3, 1, 0.39, 0.24 + CGFloat(row) * 0.16)
                ]
            )
        }
    }

    let frame = NSBezierPath(ovalIn: NSRect(x: 21, y: 21, width: 470, height: 470))
    stroke(frame, color: color(0.27, 1, 0.4, 0.58), width: 2)
    let brokenRing = NSBezierPath()
    brokenRing.appendArc(withCenter: NSPoint(x: 256, y: 256), radius: 226, startAngle: 14, endAngle: 92)
    brokenRing.appendArc(withCenter: NSPoint(x: 256, y: 256), radius: 226, startAngle: 193, endAngle: 254)
    neonStroke(brokenRing, color: acid, width: 2)

    let outerRing = NSBezierPath(ovalIn: NSRect(x: 18, y: 18, width: 476, height: 476))
    neonStroke(outerRing, color: green, width: 1.5)

    let hood = NSBezierPath()
    hood.move(to: NSPoint(x: 52, y: 22))
    hood.line(to: NSPoint(x: 85, y: 133))
    hood.curve(to: NSPoint(x: 120, y: 375), controlPoint1: NSPoint(x: 76, y: 252), controlPoint2: NSPoint(x: 90, y: 333))
    hood.curve(to: NSPoint(x: 256, y: 475), controlPoint1: NSPoint(x: 143, y: 463), controlPoint2: NSPoint(x: 192, y: 478))
    hood.curve(to: NSPoint(x: 392, y: 375), controlPoint1: NSPoint(x: 320, y: 478), controlPoint2: NSPoint(x: 369, y: 463))
    hood.curve(to: NSPoint(x: 427, y: 133), controlPoint1: NSPoint(x: 422, y: 333), controlPoint2: NSPoint(x: 436, y: 252))
    hood.line(to: NSPoint(x: 460, y: 22))
    hood.curve(to: NSPoint(x: 328, y: 79), controlPoint1: NSPoint(x: 415, y: 30), controlPoint2: NSPoint(x: 373, y: 50))
    hood.curve(to: NSPoint(x: 184, y: 79), controlPoint1: NSPoint(x: 290, y: 62), controlPoint2: NSPoint(x: 222, y: 62))
    hood.close()
    NSGradient(colors: [color(0.11, 0.15, 0.13), color(0.025, 0.035, 0.04), color(0.005, 0.012, 0.02)])!
        .draw(in: hood, angle: 90)
    neonStroke(hood, color: green, width: 2)

    let shoulderSeam = NSBezierPath()
    shoulderSeam.move(to: NSPoint(x: 108, y: 124))
    shoulderSeam.curve(to: NSPoint(x: 256, y: 464), controlPoint1: NSPoint(x: 119, y: 332), controlPoint2: NSPoint(x: 164, y: 430))
    shoulderSeam.curve(to: NSPoint(x: 404, y: 124), controlPoint1: NSPoint(x: 348, y: 430), controlPoint2: NSPoint(x: 393, y: 332))
    stroke(shoulderSeam, color: color(0.28, 0.55, 0.37, 0.55), width: 1.5)

    let face = NSBezierPath()
    face.move(to: NSPoint(x: 150, y: 149))
    face.curve(to: NSPoint(x: 140, y: 301), controlPoint1: NSPoint(x: 131, y: 206), controlPoint2: NSPoint(x: 129, y: 263))
    face.curve(to: NSPoint(x: 256, y: 400), controlPoint1: NSPoint(x: 162, y: 371), controlPoint2: NSPoint(x: 197, y: 405))
    face.curve(to: NSPoint(x: 372, y: 301), controlPoint1: NSPoint(x: 315, y: 405), controlPoint2: NSPoint(x: 350, y: 371))
    face.curve(to: NSPoint(x: 362, y: 149), controlPoint1: NSPoint(x: 383, y: 263), controlPoint2: NSPoint(x: 381, y: 206))
    face.curve(to: NSPoint(x: 256, y: 108), controlPoint1: NSPoint(x: 327, y: 112), controlPoint2: NSPoint(x: 285, y: 102))
    face.curve(to: NSPoint(x: 150, y: 149), controlPoint1: NSPoint(x: 227, y: 102), controlPoint2: NSPoint(x: 185, y: 112))
    face.close()
    NSGradient(colors: [color(0.08, 0.095, 0.1), color(0.012, 0.018, 0.027)])!
        .draw(in: face, angle: 90)
    stroke(face, color: color(0.42, 0.57, 0.48, 0.75), width: 1.5)

    let brow = NSBezierPath()
    brow.move(to: NSPoint(x: 153, y: 271))
    brow.curve(to: NSPoint(x: 359, y: 271), controlPoint1: NSPoint(x: 208, y: 307), controlPoint2: NSPoint(x: 304, y: 307))
    stroke(brow, color: color(0.52, 0.65, 0.52, 0.46), width: 1.5)

    let visor = NSBezierPath()
    visor.move(to: NSPoint(x: 111, y: 268))
    visor.line(to: NSPoint(x: 160, y: 230))
    visor.line(to: NSPoint(x: 224, y: 246))
    visor.line(to: NSPoint(x: 256, y: 260))
    visor.line(to: NSPoint(x: 288, y: 246))
    visor.line(to: NSPoint(x: 352, y: 230))
    visor.line(to: NSPoint(x: 401, y: 268))
    visor.line(to: NSPoint(x: 369, y: 322))
    visor.line(to: NSPoint(x: 300, y: 297))
    visor.line(to: NSPoint(x: 256, y: 310))
    visor.line(to: NSPoint(x: 212, y: 297))
    visor.line(to: NSPoint(x: 143, y: 322))
    visor.close()
    NSGradient(colors: [color(0.23, 0.025, 0.055), color(0.035, 0.025, 0.035), color(0.025, 0.18, 0.075)])!
        .draw(in: visor, angle: 0)
    neonStroke(visor, color: red, width: 2)

    let leftLens = NSBezierPath()
    leftLens.move(to: NSPoint(x: 145, y: 269))
    leftLens.line(to: NSPoint(x: 199, y: 253))
    leftLens.line(to: NSPoint(x: 236, y: 268))
    leftLens.line(to: NSPoint(x: 202, y: 279))
    leftLens.close()
    fill(leftLens, color: color(1, 0.11, 0.2, 0.95))
    neonStroke(leftLens, color: red, width: 2)

    let rightLens = NSBezierPath()
    rightLens.move(to: NSPoint(x: 367, y: 269))
    rightLens.line(to: NSPoint(x: 313, y: 253))
    rightLens.line(to: NSPoint(x: 276, y: 268))
    rightLens.line(to: NSPoint(x: 310, y: 279))
    rightLens.close()
    fill(rightLens, color: color(0.34, 1, 0.26, 0.95))
    neonStroke(rightLens, color: green, width: 2)
    for x in stride(from: 160.0, through: 352.0, by: 32.0) {
        let glint = NSBezierPath(ovalIn: NSRect(x: x, y: 266, width: 5, height: 5))
        fill(glint, color: color(1, 1, 0.86))
    }

    let cheekGuard = NSBezierPath()
    cheekGuard.move(to: NSPoint(x: 146, y: 317))
    cheekGuard.line(to: NSPoint(x: 190, y: 337))
    cheekGuard.line(to: NSPoint(x: 214, y: 330))
    cheekGuard.move(to: NSPoint(x: 366, y: 317))
    cheekGuard.line(to: NSPoint(x: 322, y: 337))
    cheekGuard.line(to: NSPoint(x: 298, y: 330))
    neonStroke(cheekGuard, color: acid, width: 1.5)

    let lowerMask = NSBezierPath()
    lowerMask.move(to: NSPoint(x: 182, y: 322))
    lowerMask.curve(to: NSPoint(x: 256, y: 386), controlPoint1: NSPoint(x: 196, y: 369), controlPoint2: NSPoint(x: 228, y: 389))
    lowerMask.curve(to: NSPoint(x: 330, y: 322), controlPoint1: NSPoint(x: 284, y: 389), controlPoint2: NSPoint(x: 316, y: 369))
    stroke(lowerMask, color: color(0.55, 0.66, 0.57, 0.65), width: 1.5)
    for (index, x) in stride(from: 216, through: 288, by: 12).enumerated() {
        let vent = NSBezierPath(roundedRect: NSRect(x: x, y: 339, width: 5, height: 22), xRadius: 2, yRadius: 2)
        fill(vent, color: index == 3 ? red : color(0.3, 0.72, 0.4, 0.82))
    }

    let glitchSlices: [(CGFloat, CGFloat, CGFloat)] = [
        (74, 355, 65), (139, 348, 37), (348, 184, 66),
        (373, 146, 47), (67, 159, 31), (399, 324, 35)
    ]
    for (x, y, w) in glitchSlices {
        let slice = NSBezierPath(rect: NSRect(x: x, y: y, width: w, height: 4))
        fill(slice, color: color(0.32, 1, 0.42, 0.86))
        let offset = NSBezierPath(rect: NSRect(x: x + 7, y: y - 5, width: w * 0.7, height: 2))
        fill(offset, color: color(1, 0.13, 0.24, 0.84))
    }

    let badge = NSBezierPath(roundedRect: NSRect(x: 205, y: 48, width: 102, height: 35), xRadius: 7, yRadius: 7)
    fill(badge, color: color(0.01, 0.025, 0.02))
    neonStroke(badge, color: green, width: 1)
    let initials = "LC // 451" as NSString
    initials.draw(
        at: NSPoint(x: 215, y: 58),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold),
            .foregroundColor: color(0.65, 1, 0.7)
        ]
    )

    let cornerMarks = NSBezierPath()
    cornerMarks.move(to: NSPoint(x: 77, y: 477))
    cornerMarks.line(to: NSPoint(x: 77, y: 455))
    cornerMarks.line(to: NSPoint(x: 99, y: 455))
    cornerMarks.move(to: NSPoint(x: 435, y: 477))
    cornerMarks.line(to: NSPoint(x: 435, y: 455))
    cornerMarks.line(to: NSPoint(x: 413, y: 455))
    neonStroke(cornerMarks, color: acid, width: 2)

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

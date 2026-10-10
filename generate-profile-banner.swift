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
    NSGradient(colors: [
        color(0.018, 0.025, 0.085),
        color(0.075, 0.025, 0.13),
        color(0.015, 0.065, 0.12)
    ])!.draw(in: canvas, angle: 38)

    let center = NSPoint(x: 256, y: 265)
    for (radius, hue, lineWidth) in [
        (229.0, color(0.0, 0.88, 1, 0.30), 1.0),
        (207.0, color(0.95, 0.12, 0.72, 0.44), 2.0),
        (177.0, color(0.0, 0.88, 1, 0.2), 1.0)
    ] {
        let ring = NSBezierPath(ovalIn: NSRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
        stroke(ring, color: hue, width: lineWidth)
    }

    let stars: [(CGFloat, CGFloat, CGFloat)] = [
        (61, 372, 2), (94, 414, 3), (142, 105, 2), (188, 454, 2),
        (321, 448, 2), (374, 414, 3), (438, 356, 2), (420, 161, 3),
        (351, 69, 2), (89, 181, 2), (52, 280, 2), (458, 252, 2)
    ]
    for (x, y, radius) in stars {
        let star = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: radius * 2, height: radius * 2))
        fill(star, color: color(0.56, 0.94, 1, 0.92))
    }

    let orbit = NSBezierPath()
    orbit.appendArc(withCenter: center, radius: 218, startAngle: 16, endAngle: 71)
    orbit.appendArc(withCenter: center, radius: 218, startAngle: 195, endAngle: 249)
    stroke(orbit, color: color(0.0, 0.91, 1, 0.92), width: 3)
    let orbitDot = NSBezierPath(ovalIn: NSRect(x: 409, y: 335, width: 12, height: 12))
    fill(orbitDot, color: color(1, 0.17, 0.74))

    let horizon = NSBezierPath()
    horizon.move(to: NSPoint(x: 36, y: 93))
    horizon.line(to: NSPoint(x: 476, y: 93))
    stroke(horizon, color: color(0.0, 0.86, 1, 0.46), width: 2)
    for (x, buildingHeight, buildingWidth) in [
        (45.0, 44.0, 24.0), (80.0, 68.0, 19.0), (111.0, 36.0, 26.0),
        (369.0, 55.0, 22.0), (402.0, 78.0, 27.0), (444.0, 41.0, 20.0)
    ] {
        let building = NSBezierPath(rect: NSRect(x: x, y: 94, width: buildingWidth, height: buildingHeight))
        fill(building, color: color(0.025, 0.09, 0.17, 0.8))
        stroke(building, color: color(0.0, 0.82, 1, 0.45), width: 1)
        for windowY in stride(from: 104.0, through: buildingHeight + 84, by: 14) {
            let window = NSBezierPath(roundedRect: NSRect(x: x + 7, y: windowY, width: 4, height: 5), xRadius: 1, yRadius: 1)
            fill(window, color: color(1, 0.17, 0.74, 0.8))
        }
    }

    let leftEar = polygon([
        NSPoint(x: 143, y: 317), NSPoint(x: 91, y: 463),
        NSPoint(x: 221, y: 392), NSPoint(x: 212, y: 304)
    ])
    NSGradient(colors: [color(0.19, 0.12, 0.42), color(0.035, 0.07, 0.19)])!.draw(in: leftEar, angle: 90)
    stroke(leftEar, color: color(0.0, 0.91, 1, 0.95), width: 3)

    let rightEar = polygon([
        NSPoint(x: 369, y: 317), NSPoint(x: 421, y: 463),
        NSPoint(x: 291, y: 392), NSPoint(x: 300, y: 304)
    ])
    NSGradient(colors: [color(0.19, 0.12, 0.42), color(0.035, 0.07, 0.19)])!.draw(in: rightEar, angle: 90)
    stroke(rightEar, color: color(1, 0.16, 0.72, 0.95), width: 3)

    let leftEarFacet = polygon([
        NSPoint(x: 139, y: 344), NSPoint(x: 112, y: 432),
        NSPoint(x: 190, y: 382), NSPoint(x: 181, y: 333)
    ])
    fill(leftEarFacet, color: color(0.0, 0.83, 1, 0.2))
    stroke(leftEarFacet, color: color(0.0, 0.9, 1, 0.75), width: 2)
    let rightEarFacet = polygon([
        NSPoint(x: 373, y: 344), NSPoint(x: 400, y: 432),
        NSPoint(x: 322, y: 382), NSPoint(x: 331, y: 333)
    ])
    fill(rightEarFacet, color: color(1, 0.12, 0.68, 0.18))
    stroke(rightEarFacet, color: color(1, 0.2, 0.75, 0.75), width: 2)

    let face = polygon([
        NSPoint(x: 164, y: 342), NSPoint(x: 177, y: 276),
        NSPoint(x: 211, y: 226), NSPoint(x: 256, y: 201),
        NSPoint(x: 301, y: 226), NSPoint(x: 335, y: 276),
        NSPoint(x: 348, y: 342), NSPoint(x: 310, y: 390),
        NSPoint(x: 256, y: 417), NSPoint(x: 202, y: 390)
    ])
    NSGradient(colors: [color(0.15, 0.14, 0.34), color(0.035, 0.065, 0.16)])!.draw(in: face, angle: 90)
    stroke(face, color: color(1, 0.18, 0.74, 0.95), width: 3)

    let leftFacet = polygon([
        NSPoint(x: 177, y: 276), NSPoint(x: 224, y: 297),
        NSPoint(x: 240, y: 348), NSPoint(x: 202, y: 390),
        NSPoint(x: 164, y: 342)
    ])
    fill(leftFacet, color: color(0.0, 0.78, 1, 0.19))
    stroke(leftFacet, color: color(0.0, 0.88, 1, 0.62), width: 1.5)
    let rightFacet = polygon([
        NSPoint(x: 335, y: 276), NSPoint(x: 288, y: 297),
        NSPoint(x: 272, y: 348), NSPoint(x: 310, y: 390),
        NSPoint(x: 348, y: 342)
    ])
    fill(rightFacet, color: color(1, 0.12, 0.7, 0.16))
    stroke(rightFacet, color: color(1, 0.2, 0.74, 0.64), width: 1.5)

    let leftEye = polygon([
        NSPoint(x: 179, y: 302), NSPoint(x: 222, y: 321),
        NSPoint(x: 241, y: 307), NSPoint(x: 218, y: 284),
        NSPoint(x: 194, y: 286)
    ])
    NSGradient(colors: [color(0.0, 0.94, 1), color(0.45, 0.35, 1)])!.draw(in: leftEye, angle: 0)
    stroke(leftEye, color: color(0.82, 1, 1), width: 2)
    let rightEye = polygon([
        NSPoint(x: 333, y: 302), NSPoint(x: 290, y: 321),
        NSPoint(x: 271, y: 307), NSPoint(x: 294, y: 284),
        NSPoint(x: 318, y: 286)
    ])
    NSGradient(colors: [color(1, 0.18, 0.72), color(0.42, 0.34, 1)])!.draw(in: rightEye, angle: 0)
    stroke(rightEye, color: color(1, 0.85, 1), width: 2)
    let leftPupil = NSBezierPath(ovalIn: NSRect(x: 205, y: 297, width: 12, height: 12))
    let rightPupil = NSBezierPath(ovalIn: NSRect(x: 295, y: 297, width: 12, height: 12))
    fill(leftPupil, color: color(0.015, 0.04, 0.12))
    fill(rightPupil, color: color(0.015, 0.04, 0.12))
    fill(NSBezierPath(ovalIn: NSRect(x: 208, y: 301, width: 4, height: 4)), color: color(1, 1, 1))
    fill(NSBezierPath(ovalIn: NSRect(x: 298, y: 301, width: 4, height: 4)), color: color(1, 1, 1))

    let nose = polygon([
        NSPoint(x: 256, y: 299), NSPoint(x: 273, y: 335),
        NSPoint(x: 256, y: 352), NSPoint(x: 239, y: 335)
    ])
    NSGradient(colors: [color(1, 0.2, 0.76), color(0, 0.9, 1)])!.draw(in: nose, angle: 90)
    stroke(nose, color: color(0.92, 0.98, 1), width: 2)

    let muzzle = polygon([
        NSPoint(x: 212, y: 354), NSPoint(x: 244, y: 346),
        NSPoint(x: 256, y: 359), NSPoint(x: 268, y: 346),
        NSPoint(x: 300, y: 354), NSPoint(x: 281, y: 383),
        NSPoint(x: 256, y: 393), NSPoint(x: 231, y: 383)
    ])
    fill(muzzle, color: color(0.035, 0.085, 0.17, 0.92))
    stroke(muzzle, color: color(0.0, 0.9, 1, 0.82), width: 2)

    let mouth = NSBezierPath()
    mouth.move(to: NSPoint(x: 229, y: 371))
    mouth.line(to: NSPoint(x: 256, y: 378))
    mouth.line(to: NSPoint(x: 283, y: 371))
    stroke(mouth, color: color(1, 0.18, 0.74), width: 3)
    for x in stride(from: 239.0, through: 273.0, by: 11.0) {
        let vent = NSBezierPath()
        vent.move(to: NSPoint(x: x, y: 382))
        vent.line(to: NSPoint(x: x, y: 388))
        stroke(vent, color: color(0.48, 0.88, 1, 0.8), width: 1.5)
    }

    let crown = polygon([
        NSPoint(x: 217, y: 217), NSPoint(x: 226, y: 176),
        NSPoint(x: 256, y: 201), NSPoint(x: 286, y: 176),
        NSPoint(x: 295, y: 217), NSPoint(x: 256, y: 198)
    ])
    fill(crown, color: color(0.04, 0.1, 0.21))
    stroke(crown, color: color(0.0, 0.91, 1, 0.88), width: 2)
    let crownCore = polygon([
        NSPoint(x: 256, y: 203), NSPoint(x: 266, y: 217),
        NSPoint(x: 256, y: 231), NSPoint(x: 246, y: 217)
    ])
    NSGradient(colors: [color(1, 0.18, 0.75), color(0.1, 0.93, 1)])!.draw(in: crownCore, angle: 90)
    stroke(crownCore, color: color(0.95, 1, 1), width: 1.5)

    let cheekCircuit = NSBezierPath()
    cheekCircuit.move(to: NSPoint(x: 183, y: 346))
    cheekCircuit.line(to: NSPoint(x: 205, y: 363))
    cheekCircuit.line(to: NSPoint(x: 219, y: 363))
    cheekCircuit.move(to: NSPoint(x: 329, y: 346))
    cheekCircuit.line(to: NSPoint(x: 307, y: 363))
    cheekCircuit.line(to: NSPoint(x: 293, y: 363))
    stroke(cheekCircuit, color: color(1, 0.23, 0.76, 0.88), width: 2)
    for x in [205.0, 307.0] {
        fill(NSBezierPath(ovalIn: NSRect(x: x - 3, y: 360, width: 6, height: 6)), color: color(0.1, 0.94, 1))
    }

    let badge = NSBezierPath(roundedRect: NSRect(x: 219, y: 111, width: 74, height: 31), xRadius: 10, yRadius: 10)
    fill(badge, color: color(0.025, 0.04, 0.12))
    stroke(badge, color: color(1, 0.16, 0.72, 0.9), width: 2)
    let initials = "LC" as NSString
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: 19, weight: .bold),
        .foregroundColor: color(0.88, 0.98, 1)
    ]
    let textSize = initials.size(withAttributes: attributes)
    initials.draw(
        at: NSPoint(x: (CGFloat(size) - textSize.width) / 2, y: 117),
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
        color(0.018, 0.025, 0.085),
        color(0.055, 0.022, 0.12),
        color(0.014, 0.055, 0.105)
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
    stroke(grid, color: color(0.12, 0.55, 0.78, 0.15), width: 1)

    let frame = NSBezierPath(roundedRect: canvas.insetBy(dx: 22, dy: 22), xRadius: 22, yRadius: 22)
    stroke(frame, color: color(0, 0.88, 1, 0.62), width: 2)

    for (x, h, w) in [
        (735.0, 107.0, 46.0), (793.0, 154.0, 32.0), (837.0, 92.0, 52.0),
        (1418.0, 130.0, 48.0), (1474.0, 90.0, 34.0), (1517.0, 162.0, 52.0)
    ] {
        let building = NSBezierPath(rect: NSRect(x: x, y: 48, width: w, height: h))
        fill(building, color: color(0.025, 0.09, 0.17, 0.72))
        stroke(building, color: color(0, 0.84, 1, 0.38), width: 1)
        for windowY in stride(from: 59.0, through: h + 37, by: 18) {
            let window = NSBezierPath(roundedRect: NSRect(x: x + 9, y: windowY, width: 5, height: 7), xRadius: 1, yRadius: 1)
            fill(window, color: color(1, 0.16, 0.72, 0.78))
        }
    }

    let accent = NSBezierPath(roundedRect: NSRect(x: 104, y: 493, width: 12, height: 12), xRadius: 6, yRadius: 6)
    fill(accent, color: color(0, 0.95, 1))
    let kicker = "PERSONAL INTERFACE  /  CRACKERHACKER451" as NSString
    kicker.draw(
        at: NSPoint(x: 130, y: 489),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 17, weight: .medium),
            .foregroundColor: color(0.54, 0.88, 1)
        ]
    )

    let name = "LALTESH" as NSString
    name.draw(
        at: NSPoint(x: 99, y: 349),
        withAttributes: [
            .font: NSFont.systemFont(ofSize: 82, weight: .heavy),
            .foregroundColor: color(0.96, 0.97, 1)
        ]
    )
    let surname = "CHAUDHARY" as NSString
    surname.draw(
        at: NSPoint(x: 105, y: 294),
        withAttributes: [
            .font: NSFont.systemFont(ofSize: 43, weight: .bold),
            .foregroundColor: color(0.0, 0.88, 1)
        ]
    )

    let rule = NSBezierPath()
    rule.move(to: NSPoint(x: 107, y: 265))
    rule.line(to: NSPoint(x: 626, y: 265))
    stroke(rule, color: color(1, 0.16, 0.72, 0.86), width: 3)

    let handle = "@Crackerhacker451" as NSString
    handle.draw(
        at: NSPoint(x: 107, y: 222),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 27, weight: .semibold),
            .foregroundColor: color(0.83, 0.9, 1)
        ]
    )
    let descriptor = "CODE  /  CREATE  /  EXPLORE" as NSString
    descriptor.draw(
        at: NSPoint(x: 107, y: 166),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 18, weight: .regular),
            .foregroundColor: color(0.59, 0.68, 0.82)
        ]
    )

    let avatarFrame = NSBezierPath(roundedRect: NSRect(x: 1032, y: 78, width: 446, height: 446), xRadius: 30, yRadius: 30)
    fill(avatarFrame, color: color(0.04, 0.035, 0.13, 0.9))
    stroke(avatarFrame, color: color(1, 0.16, 0.72, 0.8), width: 2)
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

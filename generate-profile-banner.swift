import AppKit
import Foundation

let width = 1600
let height = 600
let arguments = Array(CommandLine.arguments.dropFirst())
let outputPath = arguments.first ?? "profile-banner.png"
let avatarPath = arguments.dropFirst().first ?? "profile-avatar.png"

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
), let graphics = NSGraphicsContext(bitmapImageRep: bitmap) else {
    fatalError("Could not create the banner drawing context.")
}

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
}

func drawText(_ text: String, at point: NSPoint, font: NSFont, color: NSColor) {
    (text as NSString).draw(
        at: point,
        withAttributes: [
            .font: font,
            .foregroundColor: color
        ]
    )
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
graphics.imageInterpolation = .high

let canvas = NSRect(x: 0, y: 0, width: width, height: height)
color(0.025, 0.025, 0.065).setFill()
canvas.fill()
NSGradient(colors: [
    color(0.035, 0.025, 0.09),
    color(0.025, 0.045, 0.09),
    color(0.02, 0.025, 0.06)
])!.draw(in: canvas, angle: 0)

let grid = NSBezierPath()
grid.lineWidth = 1
for x in stride(from: 760, through: width, by: 48) {
    grid.move(to: NSPoint(x: x, y: 0))
    grid.line(to: NSPoint(x: x, y: height))
}
for y in stride(from: 24, through: height, by: 48) {
    grid.move(to: NSPoint(x: 760, y: y))
    grid.line(to: NSPoint(x: width, y: y))
}
color(0.15, 0.32, 0.55, 0.18).setStroke()
grid.stroke()

let frame = NSBezierPath(roundedRect: canvas.insetBy(dx: 22, dy: 22), xRadius: 22, yRadius: 22)
frame.lineWidth = 2
color(0.16, 0.85, 1, 0.65).setStroke()
frame.stroke()

let accent = NSBezierPath(roundedRect: NSRect(x: 94, y: 493, width: 12, height: 12), xRadius: 6, yRadius: 6)
color(0, 0.95, 1).setFill()
accent.fill()
drawText(
    "GITHUB PROFILE",
    at: NSPoint(x: 120, y: 489),
    font: .monospacedSystemFont(ofSize: 20, weight: .semibold),
    color: color(0.55, 0.9, 1)
)

drawText(
    "LALTESH CHAUDHARY",
    at: NSPoint(x: 92, y: 342),
    font: .systemFont(ofSize: 61, weight: .heavy),
    color: color(0.94, 0.96, 1)
)
drawText(
    "@Crackerhacker451",
    at: NSPoint(x: 98, y: 270),
    font: .monospacedSystemFont(ofSize: 31, weight: .medium),
    color: color(0.1, 0.9, 1)
)

let underline = NSBezierPath(roundedRect: NSRect(x: 98, y: 234, width: 270, height: 5), xRadius: 2.5, yRadius: 2.5)
color(1, 0.16, 0.72).setFill()
underline.fill()

drawText(
    "PROJECTS  /  CODE  /  EXPERIMENTS",
    at: NSPoint(x: 98, y: 176),
    font: .monospacedSystemFont(ofSize: 17, weight: .regular),
    color: color(0.66, 0.7, 0.82)
)

let panel = NSBezierPath(roundedRect: NSRect(x: 1050, y: 116, width: 402, height: 368), xRadius: 22, yRadius: 22)
color(0.04, 0.055, 0.12, 0.88).setFill()
panel.fill()
panel.lineWidth = 2
color(1, 0.16, 0.72, 0.7).setStroke()
panel.stroke()

let center = NSPoint(x: 1251, y: 300)
for (radius, strokeColor, lineWidth) in [
    (128.0, color(0.0, 0.9, 1, 0.28), 2.0),
    (94.0, color(1, 0.16, 0.72, 0.8), 3.0),
    (62.0, color(0.0, 0.9, 1, 0.75), 2.0)
] {
    let ring = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    ring.lineWidth = lineWidth
    strokeColor.setStroke()
    ring.stroke()
}

let crosshair = NSBezierPath()
crosshair.lineWidth = 2
crosshair.move(to: NSPoint(x: center.x - 160, y: center.y))
crosshair.line(to: NSPoint(x: center.x + 160, y: center.y))
crosshair.move(to: NSPoint(x: center.x, y: center.y - 160))
crosshair.line(to: NSPoint(x: center.x, y: center.y + 160))
color(0.2, 0.5, 0.8, 0.3).setStroke()
crosshair.stroke()

let core = NSBezierPath(ovalIn: NSRect(x: center.x - 12, y: center.y - 12, width: 24, height: 24))
color(0.95, 0.2, 0.75).setFill()
core.fill()

NSGraphicsContext.restoreGraphicsState()

guard let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not encode the banner as PNG.")
}
do {
    try png.write(to: URL(fileURLWithPath: outputPath))
} catch {
    fatalError("Could not write \(outputPath): \(error)")
}

let avatarSize = 512
guard let avatarBitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: avatarSize,
    pixelsHigh: avatarSize,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
), let avatarGraphics = NSGraphicsContext(bitmapImageRep: avatarBitmap) else {
    fatalError("Could not create the avatar drawing context.")
}

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = avatarGraphics
let avatarCanvas = NSRect(x: 0, y: 0, width: avatarSize, height: avatarSize)
NSGradient(colors: [
    color(0.025, 0.02, 0.075),
    color(0.055, 0.025, 0.12),
    color(0.015, 0.04, 0.09)
])!.draw(in: avatarCanvas, angle: 35)

let avatarCenter = NSPoint(x: 256, y: 256)
for (radius, strokeColor, lineWidth) in [
    (232.0, color(0.0, 0.9, 1, 0.42), 2.0),
    (212.0, color(1, 0.16, 0.72, 0.62), 2.0),
    (190.0, color(0.0, 0.9, 1, 0.25), 1.0)
] {
    let ring = NSBezierPath(ovalIn: NSRect(
        x: avatarCenter.x - radius,
        y: avatarCenter.y - radius,
        width: radius * 2,
        height: radius * 2
    ))
    ring.lineWidth = lineWidth
    strokeColor.setStroke()
    ring.stroke()
}

let stars: [(CGFloat, CGFloat, CGFloat)] = [
    (68, 362, 3), (107, 414, 2), (403, 395, 3), (447, 330, 2),
    (63, 214, 2), (439, 192, 3), (108, 95, 2), (387, 83, 3)
]
for (x, y, radius) in stars {
    let star = NSBezierPath(ovalIn: NSRect(x: x, y: y, width: radius * 2, height: radius * 2))
    color(0.45, 0.87, 1, 0.9).setFill()
    star.fill()
}

let skyline = NSBezierPath()
skyline.move(to: NSPoint(x: 52, y: 78))
skyline.line(to: NSPoint(x: 52, y: 135))
skyline.line(to: NSPoint(x: 78, y: 135))
skyline.line(to: NSPoint(x: 78, y: 112))
skyline.line(to: NSPoint(x: 98, y: 112))
skyline.line(to: NSPoint(x: 98, y: 153))
skyline.line(to: NSPoint(x: 119, y: 153))
skyline.line(to: NSPoint(x: 119, y: 99))
skyline.line(to: NSPoint(x: 143, y: 99))
skyline.line(to: NSPoint(x: 143, y: 78))
skyline.move(to: NSPoint(x: 369, y: 78))
skyline.line(to: NSPoint(x: 369, y: 121))
skyline.line(to: NSPoint(x: 393, y: 121))
skyline.line(to: NSPoint(x: 393, y: 94))
skyline.line(to: NSPoint(x: 416, y: 94))
skyline.line(to: NSPoint(x: 416, y: 143))
skyline.line(to: NSPoint(x: 437, y: 143))
skyline.line(to: NSPoint(x: 437, y: 78))
skyline.lineWidth = 2
color(0.0, 0.9, 1, 0.48).setStroke()
skyline.stroke()

for (x, y) in [(61.0, 92.0), (87.0, 126.0), (128.0, 112.0), (402.0, 105.0), (426.0, 119.0)] {
    let window = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: 5, height: 8), xRadius: 2, yRadius: 2)
    color(1, 0.16, 0.72, 0.9).setFill()
    window.fill()
}

let hood = NSBezierPath()
hood.move(to: NSPoint(x: 112, y: 104))
hood.curve(to: NSPoint(x: 126, y: 359), controlPoint1: NSPoint(x: 73, y: 188), controlPoint2: NSPoint(x: 83, y: 315))
hood.curve(to: NSPoint(x: 256, y: 440), controlPoint1: NSPoint(x: 150, y: 441), controlPoint2: NSPoint(x: 203, y: 440))
hood.curve(to: NSPoint(x: 386, y: 359), controlPoint1: NSPoint(x: 309, y: 440), controlPoint2: NSPoint(x: 362, y: 438))
hood.curve(to: NSPoint(x: 400, y: 104), controlPoint1: NSPoint(x: 429, y: 315), controlPoint2: NSPoint(x: 439, y: 185))
hood.close()
NSGradient(colors: [color(0.13, 0.1, 0.28), color(0.035, 0.045, 0.12)])!.draw(in: hood, angle: 90)
hood.lineWidth = 4
color(1, 0.16, 0.72, 0.92).setStroke()
hood.stroke()

let hoodRim = NSBezierPath()
hoodRim.move(to: NSPoint(x: 126, y: 164))
hoodRim.curve(to: NSPoint(x: 256, y: 420), controlPoint1: NSPoint(x: 125, y: 300), controlPoint2: NSPoint(x: 170, y: 410))
hoodRim.curve(to: NSPoint(x: 386, y: 164), controlPoint1: NSPoint(x: 342, y: 410), controlPoint2: NSPoint(x: 387, y: 300))
hoodRim.lineWidth = 3
color(0, 0.9, 1, 0.82).setStroke()
hoodRim.stroke()

let face = NSBezierPath()
face.move(to: NSPoint(x: 159, y: 312))
face.curve(to: NSPoint(x: 181, y: 207), controlPoint1: NSPoint(x: 153, y: 259), controlPoint2: NSPoint(x: 165, y: 225))
face.line(to: NSPoint(x: 221, y: 170))
face.curve(to: NSPoint(x: 291, y: 170), controlPoint1: NSPoint(x: 240, y: 158), controlPoint2: NSPoint(x: 272, y: 158))
face.line(to: NSPoint(x: 331, y: 207))
face.curve(to: NSPoint(x: 353, y: 312), controlPoint1: NSPoint(x: 347, y: 225), controlPoint2: NSPoint(x: 359, y: 259))
face.line(to: NSPoint(x: 330, y: 347))
face.line(to: NSPoint(x: 182, y: 347))
face.close()
NSGradient(colors: [color(0.08, 0.15, 0.27), color(0.025, 0.045, 0.12)])!.draw(in: face, angle: 90)
face.lineWidth = 2
color(0.0, 0.9, 1, 0.82).setStroke()
face.stroke()

let visor = NSBezierPath(roundedRect: NSRect(x: 147, y: 271, width: 218, height: 58), xRadius: 18, yRadius: 18)
NSGradient(colors: [color(0.0, 0.86, 1), color(0.55, 0.2, 1), color(1, 0.12, 0.62)])!.draw(in: visor, angle: 0)
visor.lineWidth = 2
color(0.8, 0.97, 1).setStroke()
visor.stroke()

for x in [193.0, 277.0] {
    let eye = NSBezierPath()
    eye.move(to: NSPoint(x: x - 22, y: 299))
    eye.line(to: NSPoint(x: x + 13, y: 299))
    eye.lineWidth = 5
    color(0.015, 0.035, 0.095).setStroke()
    eye.stroke()
    let eyeGlint = NSBezierPath(ovalIn: NSRect(x: x + 12, y: 296, width: 6, height: 6))
    color(0.92, 1, 1).setFill()
    eyeGlint.fill()
}

let nose = NSBezierPath()
nose.move(to: NSPoint(x: 256, y: 266))
nose.line(to: NSPoint(x: 244, y: 223))
nose.line(to: NSPoint(x: 256, y: 214))
nose.line(to: NSPoint(x: 268, y: 223))
nose.close()
color(0.03, 0.08, 0.15).setFill()
nose.fill()
color(1, 0.16, 0.72, 0.86).setStroke()
nose.lineWidth = 2
nose.stroke()

let mouth = NSBezierPath(roundedRect: NSRect(x: 221, y: 190, width: 70, height: 8), xRadius: 4, yRadius: 4)
color(0, 0.9, 1, 0.9).setFill()
mouth.fill()
for x in stride(from: 233.0, through: 277.0, by: 11.0) {
    let vent = NSBezierPath()
    vent.move(to: NSPoint(x: x, y: 187))
    vent.line(to: NSPoint(x: x, y: 179))
    vent.lineWidth = 2
    color(0.62, 0.72, 0.92, 0.74).setStroke()
    vent.stroke()
}

for side in [1.0, -1.0] {
    let ear = NSBezierPath(roundedRect: NSRect(x: side > 0 ? 372 : 122, y: 224, width: 24, height: 72), xRadius: 8, yRadius: 8)
    NSGradient(colors: [color(0.95, 0.12, 0.62), color(0.0, 0.9, 1)])!.draw(in: ear, angle: 90)
    ear.lineWidth = 2
    color(0.9, 0.97, 1, 0.9).setStroke()
    ear.stroke()
    let earLine = NSBezierPath()
    let earX = side > 0 ? 383.0 : 135.0
    earLine.move(to: NSPoint(x: earX, y: 235))
    earLine.line(to: NSPoint(x: earX, y: 285))
    earLine.lineWidth = 2
    color(0.025, 0.045, 0.12).setStroke()
    earLine.stroke()
}

let badge = NSBezierPath(roundedRect: NSRect(x: 214, y: 118, width: 84, height: 36), xRadius: 12, yRadius: 12)
color(0.025, 0.04, 0.11).setFill()
badge.fill()
badge.lineWidth = 2
color(1, 0.16, 0.72, 0.95).setStroke()
badge.stroke()
let initials = "LC" as NSString
let initialsFont = NSFont.monospacedSystemFont(ofSize: 23, weight: .bold)
let initialsAttributes: [NSAttributedString.Key: Any] = [
    .font: initialsFont,
    .foregroundColor: color(0.88, 0.98, 1)
]
let initialsSize = initials.size(withAttributes: initialsAttributes)
initials.draw(
    at: NSPoint(
        x: (CGFloat(avatarSize) - initialsSize.width) / 2,
        y: 125
    ),
    withAttributes: initialsAttributes
)

let antenna = NSBezierPath()
antenna.move(to: NSPoint(x: 256, y: 439))
antenna.line(to: NSPoint(x: 256, y: 468))
antenna.lineWidth = 3
color(0, 0.9, 1).setStroke()
antenna.stroke()
let antennaTip = NSBezierPath(ovalIn: NSRect(x: 248, y: 464, width: 16, height: 16))
color(1, 0.16, 0.72).setFill()
antennaTip.fill()

NSGraphicsContext.restoreGraphicsState()

guard let avatarPNG = avatarBitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not encode the avatar as PNG.")
}
do {
    try avatarPNG.write(to: URL(fileURLWithPath: avatarPath))
} catch {
    fatalError("Could not write \(avatarPath): \(error)")
}

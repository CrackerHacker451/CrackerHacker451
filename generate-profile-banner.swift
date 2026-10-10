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
color(0.025, 0.025, 0.065).setFill()
avatarCanvas.fill()
NSGradient(colors: [
    color(0.035, 0.025, 0.09),
    color(0.025, 0.045, 0.09)
])!.draw(in: avatarCanvas, angle: 0)

for (radius, strokeColor, lineWidth) in [
    (220.0, color(0.0, 0.9, 1, 0.7), 3.0),
    (182.0, color(1, 0.16, 0.72, 0.85), 4.0),
    (144.0, color(0.0, 0.9, 1, 0.8), 3.0)
] {
    let ring = NSBezierPath(ovalIn: NSRect(
        x: CGFloat(avatarSize) / 2 - radius,
        y: CGFloat(avatarSize) / 2 - radius,
        width: radius * 2,
        height: radius * 2
    ))
    ring.lineWidth = lineWidth
    strokeColor.setStroke()
    ring.stroke()
}

let initials = "LC" as NSString
let initialsFont = NSFont.systemFont(ofSize: 132, weight: .heavy)
let initialsAttributes: [NSAttributedString.Key: Any] = [
    .font: initialsFont,
    .foregroundColor: color(0.94, 0.96, 1)
]
let initialsSize = initials.size(withAttributes: initialsAttributes)
initials.draw(
    at: NSPoint(
        x: (CGFloat(avatarSize) - initialsSize.width) / 2,
        y: (CGFloat(avatarSize) - initialsSize.height) / 2
    ),
    withAttributes: initialsAttributes
)
NSGraphicsContext.restoreGraphicsState()

guard let avatarPNG = avatarBitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not encode the avatar as PNG.")
}
do {
    try avatarPNG.write(to: URL(fileURLWithPath: avatarPath))
} catch {
    fatalError("Could not write \(avatarPath): \(error)")
}

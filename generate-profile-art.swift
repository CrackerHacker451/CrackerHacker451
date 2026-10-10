import AppKit
import Foundation

let outputDirectory = CommandLine.arguments.dropFirst().first ?? "."
let width = 1000
let height = 560

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
}

func applyCrimsonPalette(_ bitmap: NSBitmapImageRep) {
    for y in 0..<bitmap.pixelsHigh {
        for x in 0..<bitmap.pixelsWide {
            guard let source = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else {
                fatalError("Could not read artwork pixel at \(x), \(y).")
            }
            let luminance = 0.2126 * source.redComponent
                + 0.7152 * source.greenComponent
                + 0.0722 * source.blueComponent
            let red = min(1, 0.025 + luminance * 1.08)
            let green = luminance > 0.72 ? 0.42 + (luminance - 0.72) * 0.8 : luminance * 0.075
            let blue = luminance > 0.72 ? 0.12 : luminance * 0.09
            bitmap.setColor(
                color(red, green, blue, source.alphaComponent),
                atX: x,
                y: y
            )
        }
    }
}

func line(_ from: NSPoint, _ to: NSPoint, color: NSColor, width: CGFloat = 1) -> NSBezierPath {
    let path = NSBezierPath()
    path.move(to: from)
    path.line(to: to)
    path.lineWidth = width
    color.setStroke()
    path.stroke()
    return path
}

func drawText(
    _ text: String,
    x: CGFloat,
    y: CGFloat,
    size: CGFloat,
    color: NSColor,
    weight: NSFont.Weight = .regular
) {
    (text as NSString).draw(
        at: NSPoint(x: x, y: y),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: size, weight: weight),
            .foregroundColor: color
        ]
    )
}

func drawCanvas(_ title: String, _ subtitle: String, _ content: (NSRect) -> Void) -> NSBitmapImageRep {
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
        fatalError("Could not create artwork drawing context.")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    let canvas = NSRect(x: 0, y: 0, width: width, height: height)
    NSGradient(colors: [color(0.008, 0.018, 0.025), color(0.025, 0.012, 0.035), color(0.005, 0.03, 0.025)])!
        .draw(in: canvas, angle: 0)

    let grid = NSBezierPath()
    for x in stride(from: 0, through: width, by: 40) {
        grid.move(to: NSPoint(x: x, y: 0))
        grid.line(to: NSPoint(x: x, y: height))
    }
    for y in stride(from: 0, through: height, by: 40) {
        grid.move(to: NSPoint(x: 0, y: y))
        grid.line(to: NSPoint(x: width, y: y))
    }
    grid.lineWidth = 1
    color(0.15, 0.7, 0.38, 0.13).setStroke()
    grid.stroke()

    let border = NSBezierPath(roundedRect: canvas.insetBy(dx: 18, dy: 18), xRadius: 18, yRadius: 18)
    border.lineWidth = 2
    color(0.19, 1, 0.42, 0.64).setStroke()
    border.stroke()

    drawText(title, x: 54, y: 489, size: 25, color: color(0.74, 1, 0.77), weight: .bold)
    drawText(subtitle, x: 56, y: 458, size: 13, color: color(0.38, 0.75, 0.48))
    content(canvas)
    NSGraphicsContext.restoreGraphicsState()
    return bitmap
}

func save(_ bitmap: NSBitmapImageRep, name: String) {
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not encode \(name).")
    }
    do {
        try data.write(to: URL(fileURLWithPath: outputDirectory).appendingPathComponent(name))
    } catch {
        fatalError("Could not write \(name): \(error)")
    }
}

let network = drawCanvas("01 / NEURAL TOPOLOGY", "A SIGNAL MAP THROUGH THE DIGITAL WILDERNESS") { _ in
    let nodes: [(CGFloat, CGFloat, CGFloat, String)] = [
        (177, 315, 12, "ROOT"), (306, 376, 8, "A1"), (389, 272, 11, "451"),
        (255, 183, 9, "NODE"), (488, 396, 8, "GATE"), (540, 165, 12, "CORE"),
        (626, 335, 8, "ECHO"), (737, 250, 11, "KEY"), (840, 364, 9, "VOID"),
        (793, 150, 8, "SYNC"), (352, 105, 7, "GHOST"), (680, 106, 7, "PORT")
    ]
    let edges = [(0,1),(1,2),(2,3),(1,4),(4,5),(5,6),(6,7),(7,8),(7,9),(3,10),(5,11),(2,4),(2,6),(4,6),(6,11)]
    for (a,b) in edges {
        let p = NSPoint(x: nodes[a].0, y: nodes[a].1)
        let q = NSPoint(x: nodes[b].0, y: nodes[b].1)
        let edge = NSBezierPath()
        edge.move(to: p)
        edge.line(to: q)
        edge.lineWidth = 2
        color(0.17, 0.9, 0.42, 0.48).setStroke()
        edge.stroke()
        let midpoint = NSPoint(x: (p.x + q.x) / 2, y: (p.y + q.y) / 2)
        let pulse = NSBezierPath(ovalIn: NSRect(x: midpoint.x - 3, y: midpoint.y - 3, width: 6, height: 6))
        color(0.73, 1, 0.16).setFill()
        pulse.fill()
    }
    for (index, node) in nodes.enumerated() {
        let (x, y, radius, label) = node
        let glow = NSBezierPath(ovalIn: NSRect(x: x - radius - 8, y: y - radius - 8, width: 2 * radius + 16, height: 2 * radius + 16))
        color(0.08, 1, 0.38, 0.08).setFill()
        glow.fill()
        let disk = NSBezierPath(ovalIn: NSRect(x: x - radius, y: y - radius, width: 2 * radius, height: 2 * radius))
        (index == 4 || index == 7 ? color(0.8, 1, 0.12) : color(0.02, 0.1, 0.06)).setFill()
        disk.fill()
        disk.lineWidth = 2
        color(0.32, 1, 0.48).setStroke()
        disk.stroke()
        drawText(label, x: x + radius + 7, y: y - 5, size: 10, color: color(0.54, 0.91, 0.61), weight: .medium)
    }
    let radar = NSBezierPath()
    radar.appendArc(withCenter: NSPoint(x: 540, y: 275), radius: 178, startAngle: 15, endAngle: 162)
    radar.appendArc(withCenter: NSPoint(x: 540, y: 275), radius: 178, startAngle: 195, endAngle: 345)
    radar.lineWidth = 1
    color(0.1, 0.88, 0.38, 0.28).setStroke()
    radar.stroke()
    drawText("12 NODES // 15 ROUTES", x: 620, y: 68, size: 12, color: color(0.36, 0.74, 0.47))
}

let terminal = drawCanvas("02 / AFTER HOURS", "A LITTLE WINDOW INTO THE MACHINE") { _ in
    let panel = NSBezierPath(roundedRect: NSRect(x: 74, y: 72, width: 852, height: 336), xRadius: 16, yRadius: 16)
    color(0.005, 0.018, 0.015, 0.96).setFill()
    panel.fill()
    panel.lineWidth = 2
    color(0.18, 0.93, 0.34, 0.72).setStroke()
    panel.stroke()
    let top = NSBezierPath(roundedRect: NSRect(x: 75, y: 370, width: 850, height: 37), xRadius: 14, yRadius: 14)
    color(0.035, 0.12, 0.067).setFill()
    top.fill()
    for (i, c) in [color(1,0.28,0.23), color(1,0.76,0.18), color(0.2,1,0.38)].enumerated() {
        let dot = NSBezierPath(ovalIn: NSRect(x: 98 + i * 22, y: 383, width: 9, height: 9))
        c.setFill()
        dot.fill()
    }
    drawText("root@crackerhacker451: ~", x: 190, y: 380, size: 13, color: color(0.5, 0.91, 0.58))

    let commands: [(String, String, NSColor)] = [
        ("$ whoami", "Laltesh Chaudhary", color(0.78, 1, 0.8)),
        ("$ uname -s", "CURIOUS / CREATIVE / ALWAYS LEARNING", color(0.3, 0.96, 0.48)),
        ("$ ls ./interests", "code   security   systems   strange_ideas", color(0.4, 0.83, 0.52)),
        ("$ echo $STATUS", "building something cool...", color(0.73, 1, 0.18))
    ]
    for (index, entry) in commands.enumerated() {
        let y = CGFloat(322 - index * 62)
        drawText(entry.0, x: 110, y: y, size: 16, color: color(0.28, 1, 0.45), weight: .bold)
        drawText(entry.1, x: 300, y: y, size: 15, color: entry.2)
    }
    let cursor = NSBezierPath(rect: NSRect(x: 110, y: 91, width: 11, height: 19))
    color(0.47, 1, 0.4).setFill()
    cursor.fill()
    drawText("SESSION 451  /  ENCRYPTED IN IMAGINATION", x: 612, y: 91, size: 10, color: color(0.32, 0.7, 0.42))
    for i in 0..<15 {
        let x = CGFloat(785 + (i % 5) * 20)
        let y = CGFloat(138 + (i / 5) * 23)
        let pixel = NSBezierPath(rect: NSRect(x: x, y: y, width: 8, height: 8))
        color(0.19, 1, 0.37, 0.16 + CGFloat((i * 7) % 8) * 0.09).setFill()
        pixel.fill()
    }
}

let sigil = drawCanvas("03 / SIGNAL NOISE", "FIND THE PATTERN. BECOME THE PATTERN.") { _ in
    let center = NSPoint(x: 506, y: 274)
    for radius in stride(from: 42.0, through: 210.0, by: 28.0) {
        let ring = NSBezierPath(ovalIn: NSRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        ring.lineWidth = radius == 154 ? 3 : 1
        (radius == 154 ? color(1, 0.04, 0.6, 0.9) : color(0.13, 0.87, 0.48, 0.4)).setStroke()
        ring.stroke()
    }
    let rays = NSBezierPath()
    for degree in stride(from: 0.0, through: 360.0, by: 15.0) {
        let angle = degree * .pi / 180
        let inner: CGFloat = degree.truncatingRemainder(dividingBy: 45) == 0 ? 82 : 155
        let outer: CGFloat = 226
        rays.move(to: NSPoint(x: center.x + cos(angle) * inner, y: center.y + sin(angle) * inner))
        rays.line(to: NSPoint(x: center.x + cos(angle) * outer, y: center.y + sin(angle) * outer))
    }
    rays.lineWidth = 1.3
    color(0.64, 1, 0.18, 0.66).setStroke()
    rays.stroke()

    let diamond = NSBezierPath()
    diamond.move(to: NSPoint(x: center.x, y: center.y + 130))
    diamond.line(to: NSPoint(x: center.x + 95, y: center.y))
    diamond.line(to: NSPoint(x: center.x, y: center.y - 130))
    diamond.line(to: NSPoint(x: center.x - 95, y: center.y))
    diamond.close()
    color(0.06, 0.12, 0.08, 0.82).setFill()
    diamond.fill()
    diamond.lineWidth = 3
    color(0.05, 0.97, 0.55).setStroke()
    diamond.stroke()

    let core = NSBezierPath(ovalIn: NSRect(x: center.x - 57, y: center.y - 57, width: 114, height: 114))
    color(0.01, 0.035, 0.025).setFill()
    core.fill()
    core.lineWidth = 3
    color(0.76, 1, 0.16).setStroke()
    core.stroke()
    let label = "451" as NSString
    label.draw(
        at: NSPoint(x: center.x - 27, y: center.y - 13),
        withAttributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 28, weight: .bold),
            .foregroundColor: color(0.78, 1, 0.56)
        ]
    )

    let scanline = NSBezierPath()
    scanline.move(to: NSPoint(x: 82, y: 201))
    scanline.line(to: NSPoint(x: 250, y: 201))
    scanline.move(to: NSPoint(x: 775, y: 333))
    scanline.line(to: NSPoint(x: 928, y: 333))
    scanline.move(to: NSPoint(x: 123, y: 160))
    scanline.line(to: NSPoint(x: 201, y: 160))
    scanline.move(to: NSPoint(x: 814, y: 368))
    scanline.line(to: NSPoint(x: 902, y: 368))
    scanline.lineWidth = 5
    color(1, 0.04, 0.57, 0.85).setStroke()
    scanline.stroke()
    drawText("GLITCH IS A FEATURE", x: 370, y: 49, size: 13, color: color(0.46, 0.9, 0.55), weight: .bold)
}

for (bitmap, name) in [
    (network, "network-map.png"),
    (terminal, "after-hours-terminal.png"),
    (sigil, "signal-noise.png")
] {
    applyCrimsonPalette(bitmap)
    save(bitmap, name: name)
}

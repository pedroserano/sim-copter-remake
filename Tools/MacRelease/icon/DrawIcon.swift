// Draws the Mac app icon for the SimCopter Remake port: a rescue helicopter with its searchlight
// on, over a night city skyline. Original artwork drawn here in code; it copies nothing from the
// 1996 game. Usage: swift DrawIcon.swift <out.png>   (writes a 1024x1024 PNG)

import AppKit
import CoreGraphics

let S: CGFloat = 1024
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon_1024.png"

let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: Int(S), height: Int(S), bitsPerComponent: 8, bytesPerRow: 0,
                    space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat((hex >> 16) & 0xff) / 255, green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255, alpha: a)
}
// Work in top-left coordinates, like the design sketch.
ctx.translateBy(x: 0, y: S)
ctx.scaleBy(x: 1, y: -1)

// macOS icon grid: an 824pt rounded square centred in the 1024 canvas.
let body = CGRect(x: 100, y: 100, width: 824, height: 824)
let squircle = CGPath(roundedRect: body, cornerWidth: 185, cornerHeight: 185, transform: nil)

// Drop shadow under the tile.
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: rgb(0x000000, 0.35))
ctx.addPath(squircle); ctx.setFillColor(rgb(0x1a1440)); ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(squircle); ctx.clip()

// Dusk sky.
let sky = CGGradient(colorsSpace: cs, colors: [rgb(0x0d1b4a), rgb(0x2b2a7a), rgb(0x8a3d8f), rgb(0xf08a4b)] as CFArray,
                     locations: [0, 0.45, 0.75, 1])!
ctx.drawLinearGradient(sky, start: CGPoint(x: 0, y: 100), end: CGPoint(x: 0, y: 760), options: [])

// Stars.
var seed: UInt32 = 7
func rnd() -> CGFloat { seed = seed &* 1664525 &+ 1013904223; return CGFloat(seed >> 8) / CGFloat(1 << 24) }
for _ in 0..<45 {
    let x = 110 + rnd() * 800, y = 110 + rnd() * 330, r = 1.5 + rnd() * 2.5
    ctx.setFillColor(rgb(0xffffff, 0.35 + rnd() * 0.5))
    ctx.fillEllipse(in: CGRect(x: x, y: y, width: r, height: r))
}

// Searchlight cone, drawn before the city so the buildings sit in it.
let lampX: CGFloat = 560, lampY: CGFloat = 470
ctx.saveGState()
let cone = CGMutablePath()
cone.move(to: CGPoint(x: lampX - 8, y: lampY))
cone.addLine(to: CGPoint(x: lampX + 8, y: lampY))
cone.addLine(to: CGPoint(x: 720, y: 930))
cone.addLine(to: CGPoint(x: 400, y: 930))
cone.closeSubpath()
ctx.addPath(cone); ctx.clip()
let beam = CGGradient(colorsSpace: cs, colors: [rgb(0xfff6c0, 0.85), rgb(0xffe27a, 0.18)] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(beam, start: CGPoint(x: 0, y: lampY), end: CGPoint(x: 0, y: 930), options: [])
ctx.restoreGState()

// City skyline: back row then front row.
struct B { var x, w, h: CGFloat }
let ground: CGFloat = 930
func drawRow(_ rows: [B], fill: CGColor, window: CGColor, litChance: CGFloat) {
    for b in rows {
        let r = CGRect(x: b.x, y: ground - b.h, width: b.w, height: b.h)
        ctx.setFillColor(fill); ctx.fill(r)
        var wy = r.minY + 18
        while wy < ground - 24 {
            var wx = r.minX + 12
            while wx + 12 < r.maxX - 8 {
                if rnd() < litChance { ctx.setFillColor(window); ctx.fill(CGRect(x: wx, y: wy, width: 12, height: 16)) }
                wx += 24
            }
            wy += 30
        }
    }
}
drawRow([B(x: 90, w: 110, h: 250), B(x: 200, w: 80, h: 320), B(x: 300, w: 120, h: 230),
         B(x: 440, w: 90, h: 360), B(x: 540, w: 130, h: 270), B(x: 690, w: 90, h: 340), B(x: 790, w: 150, h: 260)],
        fill: rgb(0x2a1f55), window: rgb(0xffd36b, 0.55), litChance: 0.35)
drawRow([B(x: 90, w: 150, h: 150), B(x: 250, w: 100, h: 210), B(x: 360, w: 170, h: 130),
         B(x: 545, w: 110, h: 190), B(x: 670, w: 160, h: 140), B(x: 840, w: 100, h: 200)],
        fill: rgb(0x150f33), window: rgb(0xffc94a, 0.9), litChance: 0.45)

// Helicopter, side view, nose to the right, tilted a little forward.
ctx.saveGState()
ctx.translateBy(x: 540, y: 380)
ctx.rotate(by: 0.12)

let red = rgb(0xe23b2e), darkRed = rgb(0x9e1f1a), white = rgb(0xf4f4f0), glass = rgb(0x7fd3f0)

// Tail boom and fin.
let tail = CGMutablePath()
tail.move(to: CGPoint(x: -60, y: -18)); tail.addLine(to: CGPoint(x: -290, y: -40))
tail.addLine(to: CGPoint(x: -290, y: -22)); tail.addLine(to: CGPoint(x: -60, y: 22)); tail.closeSubpath()
ctx.addPath(tail); ctx.setFillColor(red); ctx.fillPath()
let fin = CGMutablePath()
fin.move(to: CGPoint(x: -300, y: -24)); fin.addLine(to: CGPoint(x: -330, y: -100))
fin.addLine(to: CGPoint(x: -300, y: -100)); fin.addLine(to: CGPoint(x: -265, y: -36)); fin.closeSubpath()
ctx.addPath(fin); ctx.setFillColor(darkRed); ctx.fillPath()
// Tail rotor disc.
ctx.setFillColor(rgb(0xffffff, 0.28)); ctx.fillEllipse(in: CGRect(x: -335, y: -78, width: 46, height: 46))

// Cabin.
let cabin = CGPath(roundedRect: CGRect(x: -110, y: -70, width: 250, height: 130), cornerWidth: 62, cornerHeight: 62, transform: nil)
ctx.addPath(cabin); ctx.setFillColor(red); ctx.fillPath()
// White stripe.
ctx.saveGState(); ctx.addPath(cabin); ctx.clip()
ctx.setFillColor(white); ctx.fill(CGRect(x: -120, y: 4, width: 280, height: 20))
ctx.restoreGState()
// Windscreen.
let ws = CGMutablePath()
ws.move(to: CGPoint(x: 40, y: -60)); ws.addQuadCurve(to: CGPoint(x: 138, y: -6), control: CGPoint(x: 120, y: -58))
ws.addLine(to: CGPoint(x: 40, y: -6)); ws.closeSubpath()
ctx.addPath(ws); ctx.setFillColor(glass); ctx.fillPath()
ctx.setFillColor(rgb(0xffffff, 0.6)); ctx.fill(CGRect(x: 58, y: -48, width: 10, height: 34))
// Side window.
ctx.addPath(CGPath(roundedRect: CGRect(x: -50, y: -54, width: 70, height: 44), cornerWidth: 10, cornerHeight: 10, transform: nil))
ctx.setFillColor(glass); ctx.fillPath()
// Red cross on the door.
ctx.setFillColor(white); ctx.fill(CGRect(x: -90, y: -40, width: 30, height: 10)); ctx.fill(CGRect(x: -80, y: -50, width: 10, height: 30))

// Rotor mast and spinning blades.
ctx.setFillColor(rgb(0x3a3a46)); ctx.fill(CGRect(x: 4, y: -96, width: 18, height: 28))
ctx.setFillColor(rgb(0xffffff, 0.22)); ctx.fillEllipse(in: CGRect(x: -250, y: -112, width: 520, height: 34))
ctx.setFillColor(rgb(0x2c2c36)); ctx.fill(CGRect(x: -230, y: -100, width: 480, height: 9))

// Skids.
ctx.setStrokeColor(rgb(0x2c2c36)); ctx.setLineWidth(9); ctx.setLineCap(.round)
for x in [CGFloat(-50), 80] { ctx.move(to: CGPoint(x: x, y: 58)); ctx.addLine(to: CGPoint(x: x - 10, y: 88)) }
ctx.move(to: CGPoint(x: -100, y: 88)); ctx.addLine(to: CGPoint(x: 140, y: 88))
ctx.addArc(center: CGPoint(x: 140, y: 74), radius: 14, startAngle: .pi / 2, endAngle: -0.2, clockwise: true)
ctx.strokePath()

// Searchlight lamp under the nose.
ctx.setFillColor(rgb(0xfff6c0)); ctx.fillEllipse(in: CGRect(x: 6, y: 56, width: 26, height: 22))
ctx.restoreGState()

// Soft top highlight on the tile.
let gloss = CGGradient(colorsSpace: cs, colors: [rgb(0xffffff, 0.14), rgb(0xffffff, 0)] as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(gloss, start: CGPoint(x: 0, y: 100), end: CGPoint(x: 0, y: 420), options: [])
ctx.restoreGState()

let img = ctx.makeImage()!
let rep = NSBitmapImageRep(cgImage: img)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("wrote \(out)")

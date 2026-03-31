import CoreGraphics
import CoreText
import Foundation

private let canvasSize = CGSize(width: 100, height: 100)
private let glyphPadding: CGFloat = 14

@main
struct GenerateLetterSVGs {
    static func main() throws {
        let outputRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("Design/LetterSVGs", isDirectory: true)
        let allLetters: [(category: String, symbol: String, romanization: String, strokes: [GuideStroke])] =
            CanonicalLetterTemplates.consonants.map { ("consonants", $0.symbol, $0.romanization, $0.strokes) } +
            CanonicalLetterTemplates.vowels.map { ("vowels", $0.symbol, $0.romanization, $0.strokes) }

        try FileManager.default.createDirectory(at: outputRoot, withIntermediateDirectories: true)

        for letter in allLetters {
            let categoryURL = outputRoot.appendingPathComponent(letter.category, isDirectory: true)
            try FileManager.default.createDirectory(at: categoryURL, withIntermediateDirectories: true)

            let svg = makeSVG(symbol: letter.symbol, romanization: letter.romanization, strokes: letter.strokes)
            let fileURL = categoryURL.appendingPathComponent("\(letter.symbol).svg")
            try svg.write(to: fileURL, atomically: true, encoding: .utf8)
        }

        print("Generated \(allLetters.count) SVG files in \(outputRoot.path)")
    }
}

private func makeSVG(symbol: String, romanization: String, strokes: [GuideStroke]) -> String {
    let glyphPathData = glyphPath(for: symbol).map(svgPathData) ?? ""
    let strokeElements = strokes
        .map(svgStrokeElement)
        .joined(separator: "\n  ")

    return """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" data-symbol="\(symbol.xmlEscaped)" data-romanization="\(romanization.xmlEscaped)">
      <title>\(symbol.xmlEscaped)</title>
      <desc>Full glyph outline and ordered stroke paths for \(symbol.xmlEscaped).</desc>
      <g id="glyph-outline">
        <path d="\(glyphPathData)" fill="#dfe9e3"/>
      </g>
      <g id="stroke-paths" fill="none" stroke="#4a916b">
      \(strokeElements)
      </g>
    </svg>
    """
}

private func svgStrokeElement(_ stroke: GuideStroke) -> String {
    let path = stroke.path.cgPath(in: canvasSize)
    let cap = stroke.cgLineCap == .round ? "round" : "square"
    let join = stroke.cgLineJoin == .round ? "round" : "miter"

    return """
    <path id="stroke-\(stroke.order)" data-order="\(stroke.order)" data-direction="\(stroke.directionHint.rawValue)" d="\(svgPathData(path))" stroke-width="\((stroke.lineWidth * min(canvasSize.width, canvasSize.height)).svgNumber)" stroke-linecap="\(cap)" stroke-linejoin="\(join)"/>
    """
}

private func glyphPath(for symbol: String) -> CGPath? {
    guard let scalar = symbol.unicodeScalars.first else { return nil }
    var character = UniChar(scalar.value)

    for fontName in ["AppleSDGothicNeo-Regular", "Apple SD Gothic Neo", "AppleGothic"] {
        let font = CTFontCreateWithName(fontName as CFString, 1, nil)
        var glyph: CGGlyph = 0

        guard CTFontGetGlyphsForCharacters(font, &character, &glyph, 1), glyph != 0,
              let rawPath = CTFontCreatePathForGlyph(font, glyph, nil) else {
            continue
        }

        var translateTransform = CGAffineTransform(
            translationX: -rawPath.boundingBoxOfPath.minX,
            y: -rawPath.boundingBoxOfPath.minY
        )
        let translated = rawPath.copy(using: &translateTransform) ?? rawPath

        var uprightTransform = CGAffineTransform(
            translationX: 0,
            y: translated.boundingBoxOfPath.height
        ).scaledBy(x: 1, y: -1)
        let upright = translated.copy(using: &uprightTransform) ?? translated

        let bounds = upright.boundingBoxOfPath
        guard bounds.width > 0, bounds.height > 0 else { continue }

        let target = CGRect(origin: .zero, size: canvasSize).insetBy(dx: glyphPadding, dy: glyphPadding)
        let scale = min(target.width / bounds.width, target.height / bounds.height)
        let fittedOrigin = CGPoint(
            x: target.midX - (bounds.width * scale / 2),
            y: target.midY - (bounds.height * scale / 2)
        )

        var fitTransform = CGAffineTransform.identity
            .translatedBy(x: fittedOrigin.x, y: fittedOrigin.y)
            .scaledBy(x: scale, y: scale)

        return upright.copy(using: &fitTransform)
    }

    return nil
}

private func svgPathData(_ path: CGPath) -> String {
    var commands: [String] = []

    path.applyWithBlock { pointer in
        let element = pointer.pointee
        let points = element.points

        switch element.type {
        case .moveToPoint:
            commands.append("M \(points[0].x.svgNumber) \(points[0].y.svgNumber)")
        case .addLineToPoint:
            commands.append("L \(points[0].x.svgNumber) \(points[0].y.svgNumber)")
        case .addQuadCurveToPoint:
            commands.append("Q \(points[0].x.svgNumber) \(points[0].y.svgNumber) \(points[1].x.svgNumber) \(points[1].y.svgNumber)")
        case .addCurveToPoint:
            commands.append("C \(points[0].x.svgNumber) \(points[0].y.svgNumber) \(points[1].x.svgNumber) \(points[1].y.svgNumber) \(points[2].x.svgNumber) \(points[2].y.svgNumber)")
        case .closeSubpath:
            commands.append("Z")
        @unknown default:
            break
        }
    }

    return commands.joined(separator: " ")
}

private extension CGFloat {
    var svgNumber: String {
        String(format: "%.3f", Double(self))
            .replacingOccurrences(of: #"(\.\d*?[1-9])0+$"#, with: "$1", options: .regularExpression)
            .replacingOccurrences(of: #"\.0+$"#, with: "", options: .regularExpression)
    }
}

private extension String {
    var xmlEscaped: String {
        self
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}

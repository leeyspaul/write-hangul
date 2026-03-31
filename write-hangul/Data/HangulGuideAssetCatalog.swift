import CoreGraphics
import Foundation

struct HangulGuideManifestEntry: Decodable, Hashable {
    let slug: String
    let character: String
    let category: String
    let strokeCount: Int
    let file: String
}

struct HangulGuideStrokeAsset: Hashable {
    let order: Int
    let signature: String
    let path: CGPath
    let points: [CGPoint]
    let startPoint: CGPoint
    let lineWidth: CGFloat
    let lineCap: CGLineCap
    let lineJoin: CGLineJoin

    static func == (lhs: HangulGuideStrokeAsset, rhs: HangulGuideStrokeAsset) -> Bool {
        lhs.order == rhs.order &&
        lhs.signature == rhs.signature &&
        lhs.points == rhs.points &&
        lhs.startPoint == rhs.startPoint &&
        lhs.lineWidth == rhs.lineWidth &&
        lhs.lineCap == rhs.lineCap &&
        lhs.lineJoin == rhs.lineJoin
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(order)
        hasher.combine(signature)
        hasher.combine(points.count)
        hasher.combine(startPoint.x)
        hasher.combine(startPoint.y)
        hasher.combine(lineWidth)
        hasher.combine(lineCap.rawValue)
        hasher.combine(lineJoin.rawValue)
    }
}

struct HangulGuideAsset: Hashable {
    let manifest: HangulGuideManifestEntry
    let viewBox: CGRect
    let outlinePath: CGPath
    let strokes: [HangulGuideStrokeAsset]
}

enum HangulGuideAssetCatalog {
    static let shared = Loader()

    final class Loader {
        private var manifestCache: [HangulGuideManifestEntry]?
        private var assetCache: [String: HangulGuideAsset] = [:]

        func manifestEntries() -> [HangulGuideManifestEntry] {
            if let manifestCache { return manifestCache }
            guard let manifestURL = resourceRootURL()?.appendingPathComponent("manifest.json"),
                  let data = try? Data(contentsOf: manifestURL),
                  let manifest = try? JSONDecoder().decode([HangulGuideManifestEntry].self, from: data) else {
                manifestCache = []
                return []
            }

            manifestCache = manifest
            return manifest
        }

        func asset(for symbol: String) -> HangulGuideAsset? {
            if let cached = assetCache[symbol] {
                return cached
            }

            guard let manifest = manifestEntries().first(where: { $0.character == symbol }),
                  let rootURL = resourceRootURL() else {
                return nil
            }

            let fileURL = rootURL.appendingPathComponent("raw").appendingPathComponent(manifest.file)
            guard let svg = try? String(contentsOf: fileURL),
                  let asset = SVGHangulAssetParser.parse(svg: svg, manifest: manifest) else {
                return nil
            }

            assetCache[symbol] = asset
            return asset
        }

        private func resourceRootURL() -> URL? {
            let candidates: [URL?] = [
                Bundle.main.resourceURL?.appendingPathComponent("HangulGuides", isDirectory: true),
                Bundle(for: BundleMarker.self).resourceURL?.appendingPathComponent("HangulGuides", isDirectory: true),
                URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                    .appendingPathComponent("write-hangul/Assets/HangulGuides", isDirectory: true),
                URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                    .appendingPathComponent("Assets/HangulGuides", isDirectory: true)
            ]

            return candidates.first(where: { url in
                guard let url else { return false }
                return FileManager.default.fileExists(atPath: url.path)
            }) ?? nil
        }
    }
}

private final class BundleMarker {}

enum SVGHangulAssetParser {
    static func parse(svg: String, manifest: HangulGuideManifestEntry) -> HangulGuideAsset? {
        guard let viewBox = parseViewBox(from: svg),
              let outlineMatch = firstMatch(
                in: svg,
                pattern: #"<g id="glyph-outline"(?:[^>]*transform="([^"]+)")?[^>]*>\s*<path[^>]*d="([^"]+)""#
              ),
              let outlineDataRange = Range(outlineMatch.range(at: 2), in: svg) else {
            return nil
        }

        let transform = Range(outlineMatch.range(at: 1), in: svg).map { String(svg[$0]) } ?? ""
        let outlineData = String(svg[outlineDataRange])
        guard var outlinePath = SVGPathParser.parse(outlineData)?.cgPath else {
            return nil
        }

        if !transform.isEmpty {
            var cgTransform = parseTransform(transform)
            outlinePath = outlinePath.copy(using: &cgTransform) ?? outlinePath
        }

        let strokeMatches = matches(
            in: svg,
            pattern: #"<path id="stroke-(\d+)"[^>]*d="([^"]+)"[^>]*stroke-width="([^"]+)"[^>]*stroke-linecap="([^"]+)"[^>]*stroke-linejoin="([^"]+)""#
        )

        let strokes = strokeMatches.compactMap { match -> HangulGuideStrokeAsset? in
            guard let orderRange = Range(match.range(at: 1), in: svg),
                  let dataRange = Range(match.range(at: 2), in: svg),
                  let widthRange = Range(match.range(at: 3), in: svg),
                  let capRange = Range(match.range(at: 4), in: svg),
                  let joinRange = Range(match.range(at: 5), in: svg),
                  let order = Int(svg[orderRange]),
                  let lineWidth = Double(svg[widthRange]),
                  let pathData = Optional(String(svg[dataRange])),
                  let parsed = SVGPathParser.parse(pathData) else {
                return nil
            }

            return HangulGuideStrokeAsset(
                order: order,
                signature: pathData,
                path: parsed.cgPath,
                points: parsed.points,
                startPoint: parsed.startPoint,
                lineWidth: CGFloat(lineWidth),
                lineCap: lineCap(from: String(svg[capRange])),
                lineJoin: lineJoin(from: String(svg[joinRange]))
            )
        }
        .sorted { $0.order < $1.order }

        return HangulGuideAsset(
            manifest: manifest,
            viewBox: viewBox,
            outlinePath: outlinePath,
            strokes: strokes
        )
    }

    private static func parseViewBox(from svg: String) -> CGRect? {
        guard let match = firstMatch(in: svg, pattern: #"viewBox="([^"]+)""#),
              let range = Range(match.range(at: 1), in: svg) else {
            return nil
        }

        let components = svg[range]
            .split(separator: " ")
            .compactMap { Double($0) }

        guard components.count == 4 else { return nil }
        return CGRect(x: components[0], y: components[1], width: components[2], height: components[3])
    }

    private static func parseTransform(_ string: String) -> CGAffineTransform {
        var translate = CGPoint.zero
        var scale = CGPoint(x: 1, y: 1)

        for operation in string.split(separator: ")") {
            let trimmed = operation.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("translate(") {
                let values = trimmed
                    .replacingOccurrences(of: "translate(", with: "")
                    .split(separator: ",")
                    .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                if let x = values.first {
                    translate.x = CGFloat(x)
                    translate.y = CGFloat(values.count > 1 ? values[1] : 0)
                }
            } else if trimmed.hasPrefix("scale(") {
                let values = trimmed
                    .replacingOccurrences(of: "scale(", with: "")
                    .split(separator: ",")
                    .compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
                if let x = values.first {
                    scale.x = CGFloat(x)
                    scale.y = CGFloat(values.count > 1 ? values[1] : x)
                }
            }
        }

        return CGAffineTransform(a: scale.x, b: 0, c: 0, d: scale.y, tx: translate.x, ty: translate.y)
    }

    private static func lineCap(from value: String) -> CGLineCap {
        switch value {
        case "round":
            .round
        case "square":
            .square
        default:
            .butt
        }
    }

    private static func lineJoin(from value: String) -> CGLineJoin {
        switch value {
        case "round":
            .round
        case "bevel":
            .bevel
        default:
            .miter
        }
    }

    private static func firstMatch(in text: String, pattern: String) -> NSTextCheckingResult? {
        try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
            .firstMatch(in: text, range: NSRange(text.startIndex..., in: text))
    }

    private static func matches(in text: String, pattern: String) -> [NSTextCheckingResult] {
        (try? NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators]))?
            .matches(in: text, range: NSRange(text.startIndex..., in: text)) ?? []
    }
}

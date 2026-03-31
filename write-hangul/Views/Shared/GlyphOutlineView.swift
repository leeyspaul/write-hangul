import CoreText
import SwiftUI
import UIKit

struct GlyphOutlineView: View {
    let symbol: String
    var color: Color = .appGuide
    var paddingRatio: CGFloat = 0.18

    var body: some View {
        GeometryReader { geometry in
            if let path = GlyphOutline.path(for: symbol, in: geometry.size, paddingRatio: paddingRatio) {
                Path(path)
                    .fill(color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .allowsHitTesting(false)
    }
}

enum GlyphOutline {
    static func path(for symbol: String, in size: CGSize, paddingRatio: CGFloat) -> CGPath? {
        if let basePath = glyphPath(for: symbol) {
            let normalizedPath = normalized(path: basePath)
            let bounds = normalizedPath.boundingBoxOfPath
            guard bounds.width > 0, bounds.height > 0 else { return nil }

            let inset = min(size.width, size.height) * paddingRatio
            let targetRect = CGRect(origin: .zero, size: size).insetBy(dx: inset, dy: inset)
            guard targetRect.width > 0, targetRect.height > 0 else { return normalizedPath }

            let scale = min(targetRect.width / bounds.width, targetRect.height / bounds.height)
            let scaledWidth = bounds.width * scale
            let scaledHeight = bounds.height * scale
            let origin = CGPoint(
                x: targetRect.midX - (scaledWidth / 2),
                y: targetRect.midY - (scaledHeight / 2)
            )

            var transform = CGAffineTransform.identity
                .translatedBy(x: origin.x, y: origin.y)
                .scaledBy(x: scale, y: scale)

            return normalizedPath.copy(using: &transform)
        }

        if let asset = HangulGuideAssetCatalog.shared.asset(for: symbol) {
            return scaledAssetPath(asset.outlinePath, viewBox: asset.viewBox, in: size, paddingRatio: paddingRatio)
        }

        return nil
    }

    private static func glyphPath(for symbol: String) -> CGPath? {
        let utf16 = Array(symbol.utf16)
        guard let first = utf16.first else { return nil }

        let fontCandidates = [
            "AppleSDGothicNeo-Regular",
            "Apple SD Gothic Neo",
            "AppleGothic"
        ]

        for fontName in fontCandidates {
            let ctFont = CTFontCreateWithName(fontName as CFString, 1, nil)
            var character = UniChar(first)
            var glyph: CGGlyph = 0

            guard CTFontGetGlyphsForCharacters(ctFont, &character, &glyph, 1), glyph != 0 else {
                continue
            }

            if let path = CTFontCreatePathForGlyph(ctFont, glyph, nil) {
                return path
            }
        }

        return nil
    }

    private static func scaledAssetPath(_ path: CGPath, viewBox: CGRect, in size: CGSize, paddingRatio: CGFloat) -> CGPath? {
        let inset = min(size.width, size.height) * paddingRatio
        let targetRect = CGRect(origin: .zero, size: size).insetBy(dx: inset, dy: inset)
        guard targetRect.width > 0, targetRect.height > 0 else { return path }

        let normalizedPath = translatedAssetPath(path, viewBox: viewBox)
        let bounds = normalizedPath.boundingBoxOfPath
        guard bounds.width > 0, bounds.height > 0 else { return normalizedPath }

        let scale = min(targetRect.width / bounds.width, targetRect.height / bounds.height)
        let scaledWidth = bounds.width * scale
        let scaledHeight = bounds.height * scale
        let origin = CGPoint(
            x: targetRect.midX - (scaledWidth / 2),
            y: targetRect.midY - (scaledHeight / 2)
        )

        var transform = CGAffineTransform.identity
            .translatedBy(x: origin.x - (bounds.minX * scale), y: origin.y - (bounds.minY * scale))
            .scaledBy(x: scale, y: scale)
        return normalizedPath.copy(using: &transform)
    }

    private static func translatedAssetPath(_ path: CGPath, viewBox: CGRect) -> CGPath {
        var transform = CGAffineTransform(translationX: -viewBox.minX, y: -viewBox.minY)
        return path.copy(using: &transform) ?? path
    }

    private static func normalized(path: CGPath) -> CGPath {
        let translated = mutableCopy(of: path) { transform in
            transform = CGAffineTransform(translationX: -path.boundingBoxOfPath.minX, y: -path.boundingBoxOfPath.minY)
        } ?? path

        let translatedBounds = translated.boundingBoxOfPath
        return mutableCopy(of: translated) { transform in
            transform = CGAffineTransform(translationX: 0, y: translatedBounds.height).scaledBy(x: 1, y: -1)
        } ?? translated
    }

    private static func mutableCopy(of path: CGPath, update: (inout CGAffineTransform) -> Void) -> CGPath? {
        var transform = CGAffineTransform.identity
        update(&transform)
        return path.copy(using: &transform)
    }
}

struct LetterGlyphMarkView: View {
    let symbol: String
    let size: CGFloat
    var color: Color = .appInk
    var paddingRatio: CGFloat = 0.12

    var body: some View {
        GlyphOutlineView(symbol: symbol, color: color, paddingRatio: paddingRatio)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

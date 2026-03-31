import CoreGraphics
import Foundation

struct LetterRepository {
    let letters: [Letter]

    init() {
        letters = Self.buildLetters()
    }

    func letters(in category: LetterCategory) -> [Letter] {
        letters
            .filter { $0.category == category }
            .sorted { $0.orderIndex < $1.orderIndex }
    }

    func letter(id: String) -> Letter? {
        letters.first(where: { $0.id == id })
    }

    func adjacentLetter(to letter: Letter, direction: NavigationDirection) -> Letter? {
        let categoryLetters = letters(in: letter.category)
        guard let index = categoryLetters.firstIndex(of: letter) else { return nil }

        switch direction {
        case .previous:
            let previousIndex = categoryLetters.index(before: index)
            return index > categoryLetters.startIndex ? categoryLetters[previousIndex] : nil
        case .next:
            let nextIndex = categoryLetters.index(after: index)
            return nextIndex < categoryLetters.endIndex ? categoryLetters[nextIndex] : nil
        }
    }
}

enum NavigationDirection {
    case previous
    case next
}

private extension LetterRepository {
    static func buildLetters() -> [Letter] {
        let assetEntries = HangulGuideAssetCatalog.shared.manifestEntries()
        guard !assetEntries.isEmpty else {
            return buildFallbackLetters()
        }

        return assetEntries.enumerated().compactMap { index, entry in
            guard let category = LetterCategory(rawValue: entry.category),
                  let romanization = romanizationBySymbol[entry.character],
                  let asset = HangulGuideAssetCatalog.shared.asset(for: entry.character) else {
                return nil
            }

            let strokes = asset.strokes.map { stroke in
                let normalizedPoints = stroke.points.map {
                    CGPoint(
                        x: ($0.x - asset.viewBox.minX) / asset.viewBox.width,
                        y: ($0.y - asset.viewBox.minY) / asset.viewBox.height
                    )
                }

                let normalizedStartPoint = CGPoint(
                    x: (stroke.startPoint.x - asset.viewBox.minX) / asset.viewBox.width,
                    y: (stroke.startPoint.y - asset.viewBox.minY) / asset.viewBox.height
                )

                var normalizationTransform = CGAffineTransform.identity
                normalizationTransform = normalizationTransform.translatedBy(x: -asset.viewBox.minX, y: -asset.viewBox.minY)
                normalizationTransform = normalizationTransform.scaledBy(x: 1 / asset.viewBox.width, y: 1 / asset.viewBox.height)
                let normalizedPath = stroke.path.copy(using: &normalizationTransform) ?? stroke.path

                return GuideStroke(
                    order: stroke.order,
                    path: .vector(
                        NormalizedVectorPath(
                            signature: stroke.signature,
                            path: normalizedPath,
                            startPoint: normalizedStartPoint,
                            lineCap: stroke.lineCap,
                            lineJoin: stroke.lineJoin
                        )
                    ),
                    directionHint: directionHint(for: normalizedPoints),
                    lineWidth: stroke.lineWidth / min(asset.viewBox.width, asset.viewBox.height),
                    startPoint: normalizedStartPoint,
                    lineCap: stroke.lineCap,
                    lineJoin: stroke.lineJoin
                )
            }

            return Letter(
                id: "\(entry.category)-\(index)",
                symbol: entry.character,
                romanization: romanization,
                category: category,
                orderIndex: index,
                guideTemplate: .from(strokes)
            )
        }
    }

    static func buildFallbackLetters() -> [Letter] {
        let consonantLetters = CanonicalLetterTemplates.consonants.enumerated().map { index, item in
            Letter(
                id: "consonant-\(index)",
                symbol: item.symbol,
                romanization: item.romanization,
                category: .consonant,
                orderIndex: index,
                guideTemplate: .from(item.strokes)
            )
        }

        let vowelLetters = CanonicalLetterTemplates.vowels.enumerated().map { index, item in
            Letter(
                id: "vowel-\(index)",
                symbol: item.symbol,
                romanization: item.romanization,
                category: .vowel,
                orderIndex: index,
                guideTemplate: .from(item.strokes)
            )
        }

        return consonantLetters + vowelLetters
    }

    static func directionHint(for points: [CGPoint]) -> GuideStrokeDirection {
        guard let first = points.first, let last = points.last else { return .right }
        let deltaX = last.x - first.x
        let deltaY = last.y - first.y

        if hypot(deltaX, deltaY) < 0.02 {
            return .clockwiseLoop
        }

        switch (deltaX, deltaY) {
        case let (x, y) where abs(x) > abs(y) && x >= 0:
            return .right
        case let (x, y) where abs(x) > abs(y) && x < 0:
            return .left
        case let (x, y) where abs(y) > abs(x) && y >= 0:
            return .down
        case let (x, y) where abs(y) > abs(x) && y < 0:
            return .up
        case let (x, y) where x >= 0 && y >= 0:
            return .downRight
        case let (x, y) where x < 0 && y >= 0:
            return .downLeft
        case let (x, y) where x >= 0 && y < 0:
            return .upRight
        default:
            return .upLeft
        }
    }

    static let romanizationBySymbol: [String: String] = [
        "ㄱ": "g/k",
        "ㄴ": "n",
        "ㄷ": "d/t",
        "ㄹ": "r/l",
        "ㅁ": "m",
        "ㅂ": "b/p",
        "ㅅ": "s",
        "ㅇ": "ng",
        "ㅈ": "j",
        "ㅊ": "ch",
        "ㅋ": "k",
        "ㅌ": "t",
        "ㅍ": "p",
        "ㅎ": "h",
        "ㅏ": "a",
        "ㅑ": "ya",
        "ㅓ": "eo",
        "ㅕ": "yeo",
        "ㅗ": "o",
        "ㅛ": "yo",
        "ㅜ": "u",
        "ㅠ": "yu",
        "ㅡ": "eu",
        "ㅣ": "i"
    ]
}

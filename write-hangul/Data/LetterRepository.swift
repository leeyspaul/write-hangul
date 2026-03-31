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
        let consonants: [(String, String, [GuideStroke])] = [
            ("ㄱ", "g/k", [
                stroke(1, .right, width: 0.12, p(0.28, 0.24), p(0.66, 0.24), p(0.66, 0.68))
            ]),
            ("ㄴ", "n", [
                stroke(1, .down, width: 0.12, p(0.30, 0.22), p(0.30, 0.68), p(0.66, 0.68))
            ]),
            ("ㄷ", "d/t", [
                stroke(1, .right, width: 0.12, p(0.28, 0.24), p(0.66, 0.24), p(0.66, 0.68), p(0.30, 0.68))
            ]),
            ("ㄹ", "r/l", [
                stroke(1, .right, width: 0.12, p(0.28, 0.24), p(0.66, 0.24), p(0.66, 0.42), p(0.38, 0.42), p(0.38, 0.58), p(0.66, 0.58))
            ]),
            ("ㅁ", "m", [
                stroke(1, .right, width: 0.12, p(0.30, 0.24), p(0.66, 0.24), p(0.66, 0.66), p(0.30, 0.66), p(0.30, 0.24))
            ]),
            ("ㅂ", "b/p", [
                stroke(1, .right, width: 0.12, p(0.30, 0.22), p(0.66, 0.22)),
                stroke(2, .down, width: 0.12, p(0.30, 0.22), p(0.30, 0.68)),
                stroke(3, .down, width: 0.12, p(0.66, 0.22), p(0.66, 0.68)),
                stroke(4, .right, width: 0.12, p(0.30, 0.46), p(0.66, 0.46)),
                stroke(5, .right, width: 0.12, p(0.30, 0.68), p(0.66, 0.68))
            ]),
            ("ㅅ", "s", [
                stroke(1, .downRight, width: 0.11, p(0.38, 0.26), p(0.50, 0.58)),
                stroke(2, .downLeft, width: 0.11, p(0.62, 0.26), p(0.50, 0.58))
            ]),
            ("ㅇ", "ng", [
                loop(1, rect(0.30, 0.28, 0.40, 0.40), .clockwiseLoop, width: 0.11)
            ]),
            ("ㅈ", "j", [
                stroke(1, .right, width: 0.10, p(0.28, 0.22), p(0.72, 0.22)),
                stroke(2, .downRight, width: 0.11, p(0.38, 0.34), p(0.50, 0.60)),
                stroke(3, .downLeft, width: 0.11, p(0.62, 0.34), p(0.50, 0.60))
            ]),
            ("ㅊ", "ch", [
                stroke(1, .right, width: 0.09, p(0.40, 0.14), p(0.60, 0.14)),
                stroke(2, .right, width: 0.10, p(0.28, 0.26), p(0.72, 0.26)),
                stroke(3, .downRight, width: 0.11, p(0.38, 0.38), p(0.50, 0.62)),
                stroke(4, .downLeft, width: 0.11, p(0.62, 0.38), p(0.50, 0.62))
            ]),
            ("ㅋ", "k", [
                stroke(1, .right, width: 0.12, p(0.28, 0.22), p(0.66, 0.22), p(0.66, 0.66)),
                stroke(2, .right, width: 0.10, p(0.38, 0.46), p(0.62, 0.46)),
                stroke(3, .right, width: 0.12, p(0.30, 0.68), p(0.66, 0.68))
            ]),
            ("ㅌ", "t", [
                stroke(1, .right, width: 0.10, p(0.28, 0.22), p(0.72, 0.22)),
                stroke(2, .right, width: 0.10, p(0.36, 0.38), p(0.64, 0.38)),
                stroke(3, .down, width: 0.12, p(0.30, 0.22), p(0.30, 0.68)),
                stroke(4, .down, width: 0.12, p(0.66, 0.22), p(0.66, 0.68)),
                stroke(5, .right, width: 0.12, p(0.30, 0.68), p(0.66, 0.68))
            ]),
            ("ㅍ", "p", [
                stroke(1, .right, width: 0.10, p(0.28, 0.22), p(0.72, 0.22)),
                stroke(2, .down, width: 0.12, p(0.30, 0.22), p(0.30, 0.68)),
                stroke(3, .down, width: 0.12, p(0.66, 0.22), p(0.66, 0.68)),
                stroke(4, .right, width: 0.10, p(0.30, 0.44), p(0.66, 0.44)),
                stroke(5, .right, width: 0.12, p(0.30, 0.68), p(0.66, 0.68)),
                stroke(6, .right, width: 0.09, p(0.42, 0.80), p(0.54, 0.80))
            ]),
            ("ㅎ", "h", [
                stroke(1, .right, width: 0.09, p(0.40, 0.20), p(0.60, 0.20)),
                loop(2, rect(0.32, 0.34, 0.36, 0.28), .clockwiseLoop, width: 0.10),
                stroke(3, .right, width: 0.09, p(0.28, 0.64), p(0.72, 0.64))
            ])
        ]

        let vowels: [(String, String, [GuideStroke])] = [
            ("ㅏ", "a", [
                stroke(1, .down, width: 0.12, p(0.48, 0.16), p(0.48, 0.78)),
                stroke(2, .right, width: 0.10, p(0.48, 0.44), p(0.70, 0.44))
            ]),
            ("ㅑ", "ya", [
                stroke(1, .down, width: 0.12, p(0.48, 0.16), p(0.48, 0.78)),
                stroke(2, .right, width: 0.10, p(0.48, 0.34), p(0.70, 0.34)),
                stroke(3, .right, width: 0.10, p(0.48, 0.56), p(0.70, 0.56))
            ]),
            ("ㅓ", "eo", [
                stroke(1, .down, width: 0.12, p(0.52, 0.16), p(0.52, 0.78)),
                stroke(2, .left, width: 0.10, p(0.52, 0.44), p(0.30, 0.44))
            ]),
            ("ㅕ", "yeo", [
                stroke(1, .down, width: 0.12, p(0.52, 0.16), p(0.52, 0.78)),
                stroke(2, .left, width: 0.10, p(0.52, 0.34), p(0.30, 0.34)),
                stroke(3, .left, width: 0.10, p(0.52, 0.56), p(0.30, 0.56))
            ]),
            ("ㅗ", "o", [
                stroke(1, .down, width: 0.10, p(0.50, 0.18), p(0.50, 0.36)),
                stroke(2, .right, width: 0.12, p(0.24, 0.44), p(0.76, 0.44))
            ]),
            ("ㅛ", "yo", [
                stroke(1, .down, width: 0.10, p(0.38, 0.18), p(0.38, 0.34)),
                stroke(2, .down, width: 0.10, p(0.62, 0.18), p(0.62, 0.34)),
                stroke(3, .right, width: 0.12, p(0.24, 0.46), p(0.76, 0.46))
            ]),
            ("ㅜ", "u", [
                stroke(1, .right, width: 0.12, p(0.24, 0.44), p(0.76, 0.44)),
                stroke(2, .down, width: 0.10, p(0.50, 0.52), p(0.50, 0.72))
            ]),
            ("ㅠ", "yu", [
                stroke(1, .right, width: 0.12, p(0.24, 0.40), p(0.76, 0.40)),
                stroke(2, .down, width: 0.10, p(0.38, 0.48), p(0.38, 0.66)),
                stroke(3, .down, width: 0.10, p(0.62, 0.48), p(0.62, 0.66))
            ]),
            ("ㅡ", "eu", [
                stroke(1, .right, width: 0.12, p(0.20, 0.50), p(0.80, 0.50))
            ]),
            ("ㅣ", "i", [
                stroke(1, .down, width: 0.12, p(0.50, 0.16), p(0.50, 0.80))
            ])
        ]

        let consonantLetters = consonants.enumerated().map { index, item in
            Letter(
                id: "consonant-\(index)",
                symbol: item.0,
                romanization: item.1,
                category: .consonant,
                orderIndex: index,
                guideTemplate: .from(item.2)
            )
        }

        let vowelLetters = vowels.enumerated().map { index, item in
            Letter(
                id: "vowel-\(index)",
                symbol: item.0,
                romanization: item.1,
                category: .vowel,
                orderIndex: index,
                guideTemplate: .from(item.2)
            )
        }

        return consonantLetters + vowelLetters
    }

    static func stroke(
        _ order: Int,
        _ direction: GuideStrokeDirection,
        width: CGFloat = 0.12,
        _ points: CGPoint...
    ) -> GuideStroke {
        GuideStroke(
            order: order,
            path: .polyline(points),
            directionHint: direction,
            lineWidth: width
        )
    }

    static func loop(
        _ order: Int,
        _ rect: CGRect,
        _ direction: GuideStrokeDirection,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        GuideStroke(
            order: order,
            path: .ellipse(rect: rect, startAngle: -.pi / 2, endAngle: (.pi * 3) / 2, clockwise: direction == .clockwiseLoop),
            directionHint: direction,
            lineWidth: width
        )
    }

    static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    static func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

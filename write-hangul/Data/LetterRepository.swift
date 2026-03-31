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
        let consonants: [(String, String, [GuideRegion.Specification])] = [
            ("ㄱ", "g/k", [rr(0.25, 0.18, 0.12, 0.56), rr(0.25, 0.62, 0.46, 0.12)]),
            ("ㄴ", "n", [rr(0.28, 0.18, 0.12, 0.56), rr(0.28, 0.62, 0.42, 0.12)]),
            ("ㄷ", "d/t", [rr(0.24, 0.18, 0.12, 0.56), rr(0.24, 0.18, 0.46, 0.12), rr(0.24, 0.62, 0.46, 0.12)]),
            ("ㄹ", "r/l", [rr(0.24, 0.18, 0.46, 0.12), rr(0.24, 0.18, 0.12, 0.25), rr(0.24, 0.40, 0.38, 0.12), rr(0.50, 0.40, 0.12, 0.22), rr(0.24, 0.62, 0.46, 0.12)]),
            ("ㅁ", "m", [rr(0.24, 0.20, 0.46, 0.12), rr(0.24, 0.20, 0.12, 0.46), rr(0.58, 0.20, 0.12, 0.46), rr(0.24, 0.54, 0.46, 0.12)]),
            ("ㅂ", "b/p", [rr(0.24, 0.18, 0.46, 0.12), rr(0.24, 0.18, 0.12, 0.56), rr(0.58, 0.18, 0.12, 0.56), rr(0.24, 0.40, 0.46, 0.12), rr(0.24, 0.62, 0.46, 0.12)]),
            ("ㅅ", "s", [rr(0.27, 0.24, 0.14, 0.36), rr(0.57, 0.24, 0.14, 0.36), rr(0.41, 0.52, 0.14, 0.18)]),
            ("ㅇ", "ng", [ellipse(0.28, 0.26, 0.44, 0.44)]),
            ("ㅈ", "j", [rr(0.25, 0.20, 0.48, 0.12), rr(0.30, 0.30, 0.14, 0.32), rr(0.56, 0.30, 0.14, 0.32), rr(0.43, 0.54, 0.14, 0.18)]),
            ("ㅊ", "ch", [rr(0.37, 0.12, 0.24, 0.10), rr(0.25, 0.24, 0.48, 0.12), rr(0.30, 0.34, 0.14, 0.32), rr(0.56, 0.34, 0.14, 0.32), rr(0.43, 0.58, 0.14, 0.16)]),
            ("ㅋ", "k", [rr(0.24, 0.18, 0.12, 0.56), rr(0.24, 0.18, 0.46, 0.12), rr(0.32, 0.42, 0.32, 0.12), rr(0.24, 0.62, 0.46, 0.12)]),
            ("ㅌ", "t", [rr(0.24, 0.18, 0.46, 0.12), rr(0.32, 0.32, 0.30, 0.12), rr(0.24, 0.18, 0.12, 0.56), rr(0.58, 0.18, 0.12, 0.56), rr(0.24, 0.62, 0.46, 0.12)]),
            ("ㅍ", "p", [rr(0.24, 0.18, 0.46, 0.12), rr(0.24, 0.18, 0.12, 0.56), rr(0.58, 0.18, 0.12, 0.56), rr(0.24, 0.40, 0.46, 0.12), rr(0.24, 0.62, 0.46, 0.12), rr(0.40, 0.74, 0.14, 0.08)]),
            ("ㅎ", "h", [rr(0.37, 0.18, 0.20, 0.10), rr(0.28, 0.34, 0.44, 0.34), rr(0.24, 0.50, 0.52, 0.10)])
        ]

        let vowels: [(String, String, [GuideRegion.Specification])] = [
            ("ㅏ", "a", [rr(0.44, 0.16, 0.12, 0.60), rr(0.52, 0.38, 0.22, 0.12)]),
            ("ㅑ", "ya", [rr(0.44, 0.16, 0.12, 0.60), rr(0.52, 0.30, 0.22, 0.12), rr(0.52, 0.50, 0.22, 0.12)]),
            ("ㅓ", "eo", [rr(0.44, 0.16, 0.12, 0.60), rr(0.26, 0.38, 0.22, 0.12)]),
            ("ㅕ", "yeo", [rr(0.44, 0.16, 0.12, 0.60), rr(0.26, 0.30, 0.22, 0.12), rr(0.26, 0.50, 0.22, 0.12)]),
            ("ㅗ", "o", [rr(0.22, 0.34, 0.56, 0.12), rr(0.44, 0.16, 0.12, 0.22)]),
            ("ㅛ", "yo", [rr(0.22, 0.38, 0.56, 0.12), rr(0.34, 0.16, 0.12, 0.18), rr(0.54, 0.16, 0.12, 0.18)]),
            ("ㅜ", "u", [rr(0.22, 0.46, 0.56, 0.12), rr(0.44, 0.58, 0.12, 0.22)]),
            ("ㅠ", "yu", [rr(0.22, 0.42, 0.56, 0.12), rr(0.34, 0.54, 0.12, 0.18), rr(0.54, 0.54, 0.12, 0.18)]),
            ("ㅡ", "eu", [rr(0.18, 0.42, 0.64, 0.12)]),
            ("ㅣ", "i", [rr(0.44, 0.16, 0.12, 0.60)])
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

    static func rr(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> GuideRegion.Specification {
        GuideRegion.Specification(shape: .roundedRect, rect: CGRect(x: x, y: y, width: width, height: height))
    }

    static func ellipse(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> GuideRegion.Specification {
        GuideRegion.Specification(shape: .ellipse, rect: CGRect(x: x, y: y, width: width, height: height))
    }
}

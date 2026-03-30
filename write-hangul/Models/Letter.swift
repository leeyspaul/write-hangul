import Foundation

struct Letter: Identifiable, Hashable {
    let id: String
    let symbol: String
    let romanization: String
    let category: LetterCategory
    let orderIndex: Int
    let guideTemplate: LetterGuideTemplate
}

enum LetterCategory: String, Codable, CaseIterable, Hashable {
    case consonant
    case vowel

    var title: String {
        switch self {
        case .consonant:
            "Basic Consonants"
        case .vowel:
            "Basic Vowels"
        }
    }

    var subtitle: String {
        switch self {
        case .consonant:
            "Start with the core Hangul consonants."
        case .vowel:
            "Practice the simple vertical and horizontal vowels."
        }
    }
}

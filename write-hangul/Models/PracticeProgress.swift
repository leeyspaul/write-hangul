import Foundation

struct PracticeProgress: Codable, Equatable {
    let letterID: String
    var isCompleted: Bool
    var bestScore: Double
    var lastPracticedAt: Date?

    static func empty(for letterID: String) -> PracticeProgress {
        PracticeProgress(letterID: letterID, isCompleted: false, bestScore: 0, lastPracticedAt: nil)
    }
}

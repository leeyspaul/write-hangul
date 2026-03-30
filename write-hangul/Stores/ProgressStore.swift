import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var progressByLetterID: [String: PracticeProgress]

    private let userDefaults: UserDefaults
    private let storageKey: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard, storageKey: String = "practiceProgress") {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        progressByLetterID = [:]
        load()
    }

    func progress(for letterID: String) -> PracticeProgress {
        progressByLetterID[letterID] ?? .empty(for: letterID)
    }

    func saveResult(letterID: String, score: Double) {
        var progress = progress(for: letterID)
        progress.bestScore = max(progress.bestScore, score)
        progress.isCompleted = progress.isCompleted || score >= ScoringEngine.passThreshold
        progress.lastPracticedAt = Date()
        progressByLetterID[letterID] = progress
        persist()
    }

    func completionCount(in category: LetterCategory, repository: LetterRepository) -> Int {
        repository.letters(in: category)
            .filter { progress(for: $0.id).isCompleted }
            .count
    }

    private func load() {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? decoder.decode([String: PracticeProgress].self, from: data) else {
            progressByLetterID = [:]
            return
        }

        progressByLetterID = decoded
    }

    private func persist() {
        guard let data = try? encoder.encode(progressByLetterID) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}

extension ProgressStore {
    static var preview: ProgressStore {
        let defaults = UserDefaults(suiteName: "PreviewProgressStore")!
        defaults.removePersistentDomain(forName: "PreviewProgressStore")
        let store = ProgressStore(userDefaults: defaults)
        store.saveResult(letterID: "consonant-0", score: 0.88)
        store.saveResult(letterID: "vowel-0", score: 0.81)
        return store
    }
}

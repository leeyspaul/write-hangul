import XCTest
@testable import write_hangul

@MainActor
final class ProgressStoreTests: XCTestCase {
    func testSavingBetterScoreUpdatesBestScore() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = ProgressStore(userDefaults: defaults, storageKey: "progress")

        store.saveResult(letterID: "consonant-0", score: 0.4)
        store.saveResult(letterID: "consonant-0", score: 0.8)

        XCTAssertEqual(store.progress(for: "consonant-0").bestScore, 0.8, accuracy: 0.001)
    }

    func testSavingWorseScoreDoesNotLowerBestScore() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = ProgressStore(userDefaults: defaults, storageKey: "progress")

        store.saveResult(letterID: "consonant-0", score: 0.9)
        store.saveResult(letterID: "consonant-0", score: 0.6)

        XCTAssertEqual(store.progress(for: "consonant-0").bestScore, 0.9, accuracy: 0.001)
    }

    func testCompletionStatePersistsAcrossStoreInstances() {
        let suiteName = #function
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let firstStore = ProgressStore(userDefaults: defaults, storageKey: "progress")
        firstStore.saveResult(letterID: "vowel-0", score: 0.72)

        let secondStore = ProgressStore(userDefaults: defaults, storageKey: "progress")
        XCTAssertTrue(secondStore.progress(for: "vowel-0").isCompleted)
        XCTAssertEqual(secondStore.progress(for: "vowel-0").bestScore, 0.72, accuracy: 0.001)
    }
}

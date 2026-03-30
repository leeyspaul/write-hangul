import XCTest
@testable import write_hangul

final class LetterRepositoryTests: XCTestCase {
    func testBasicLetterCountsAreCorrect() {
        let repository = LetterRepository()

        XCTAssertEqual(repository.letters(in: .consonant).count, 14)
        XCTAssertEqual(repository.letters(in: .vowel).count, 10)
    }

    func testAdjacentNavigationStaysInsideCategory() {
        let repository = LetterRepository()
        let consonants = repository.letters(in: .consonant)

        XCTAssertNil(repository.adjacentLetter(to: consonants[0], direction: .previous))
        XCTAssertEqual(repository.adjacentLetter(to: consonants[0], direction: .next)?.symbol, "ㄴ")
        XCTAssertEqual(repository.adjacentLetter(to: consonants[13], direction: .previous)?.symbol, "ㅍ")
        XCTAssertNil(repository.adjacentLetter(to: consonants[13], direction: .next))
    }
}

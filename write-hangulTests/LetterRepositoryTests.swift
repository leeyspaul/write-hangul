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

    func testIeungUsesEllipseGuideRegion() {
        let repository = LetterRepository()
        let ieung = repository.letters(in: .consonant).first { $0.symbol == "ㅇ" }

        XCTAssertEqual(ieung?.guideTemplate.regions.count, 1)
        XCTAssertEqual(ieung?.guideTemplate.regions.first?.shape, .ellipse)
    }

    func testNonCircularGuidesStayRoundedRectByDefault() {
        let repository = LetterRepository()
        let giyeok = repository.letters(in: .consonant).first { $0.symbol == "ㄱ" }

        XCTAssertEqual(giyeok?.guideTemplate.regions.map(\.shape), [.roundedRect, .roundedRect])
    }
}

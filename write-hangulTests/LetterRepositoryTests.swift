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

    func testEverySupportedLetterHasOrderedStrokeData() {
        let repository = LetterRepository()

        for letter in repository.letters {
            XCTAssertFalse(letter.guideTemplate.strokes.isEmpty, "Missing strokes for \(letter.symbol)")

            let orders = letter.guideTemplate.strokes.map(\.order)
            XCTAssertEqual(orders, Array(1...letter.guideTemplate.strokes.count), "Stroke order should be contiguous for \(letter.symbol)")

            for stroke in letter.guideTemplate.strokes {
                XCTAssertGreaterThanOrEqual(stroke.startPoint.x, 0)
                XCTAssertLessThanOrEqual(stroke.startPoint.x, 1)
                XCTAssertGreaterThanOrEqual(stroke.startPoint.y, 0)
                XCTAssertLessThanOrEqual(stroke.startPoint.y, 1)
            }
        }
    }

    func testGiyeokUsesSingleCornerStroke() {
        let repository = LetterRepository()
        let giyeok = repository.letters(in: .consonant).first { $0.symbol == "ㄱ" }

        XCTAssertEqual(giyeok?.guideTemplate.strokes.count, 1)

        guard case let .polyline(points)? = giyeok?.guideTemplate.strokes.first?.path else {
            return XCTFail("Expected a polyline stroke for ㄱ")
        }

        XCTAssertEqual(points.count, 3)
        XCTAssertEqual(giyeok?.guideTemplate.strokes.first?.directionHint, .right)
    }

    func testIeungUsesClockwiseEllipseStroke() {
        let repository = LetterRepository()
        let ieung = repository.letters(in: .consonant).first { $0.symbol == "ㅇ" }

        XCTAssertEqual(ieung?.guideTemplate.strokes.count, 1)
        XCTAssertEqual(ieung?.guideTemplate.strokes.first?.directionHint, .clockwiseLoop)

        guard case .ellipse(_, _, _, _)? = ieung?.guideTemplate.strokes.first?.path else {
            return XCTFail("Expected an ellipse stroke for ㅇ")
        }
    }

    func testYaUsesThreeOrderedStrokes() {
        let repository = LetterRepository()
        let ya = repository.letters(in: .vowel).first { $0.symbol == "ㅑ" }

        XCTAssertEqual(ya?.guideTemplate.strokes.map(\.order), [1, 2, 3])
        XCTAssertEqual(ya?.guideTemplate.strokes.count, 3)
    }
}

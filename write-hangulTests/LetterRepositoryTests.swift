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

    func testCanonicalConsonantFamiliesUseExpectedStrokeStructure() {
        let repository = LetterRepository()

        XCTAssertEqual(repository.letter(id: "consonant-8")?.guideTemplate.strokes.count, 3, "ㅈ should be top bar plus two diagonal strokes")
        XCTAssertEqual(repository.letter(id: "consonant-9")?.guideTemplate.strokes.count, 4, "ㅊ should be two bars plus two diagonal strokes")
        XCTAssertEqual(repository.letter(id: "consonant-10")?.guideTemplate.strokes.count, 2, "ㅋ should be ㄱ plus one added bar")
        XCTAssertEqual(repository.letter(id: "consonant-11")?.guideTemplate.strokes.count, 2, "ㅌ should be ㄷ plus one added bar")
        XCTAssertEqual(repository.letter(id: "consonant-12")?.guideTemplate.strokes.count, 5, "ㅍ should be ㅂ plus one added bar")
        XCTAssertEqual(repository.letter(id: "consonant-13")?.guideTemplate.strokes.count, 3, "ㅎ should be top bar, loop, bottom bar")
    }

    func testJieutAndChieutDiagonalsBranchOutwardFromCenter() {
        let repository = LetterRepository()

        for symbol in ["ㅈ", "ㅊ"] {
            let letter = repository.letters.first { $0.symbol == symbol }
            let diagonalStrokes = Array(letter?.guideTemplate.strokes.dropFirst(symbol == "ㅈ" ? 1 : 2) ?? [])

            XCTAssertEqual(diagonalStrokes.count, 2)

            guard case let .polyline(leftPoints) = diagonalStrokes[0].path,
                  case let .polyline(rightPoints) = diagonalStrokes[1].path,
                  let leftStart = leftPoints.first,
                  let leftEnd = leftPoints.last,
                  let rightStart = rightPoints.first,
                  let rightEnd = rightPoints.last else {
                return XCTFail("Expected diagonal polylines for \(symbol)")
            }

            XCTAssertLessThan(leftStart.x, rightStart.x)
            XCTAssertGreaterThan(leftEnd.x, leftStart.x)
            XCTAssertLessThan(rightEnd.x, rightStart.x)
            XCTAssertGreaterThan(leftEnd.y, leftStart.y)
            XCTAssertGreaterThan(rightEnd.y, rightStart.y)
            XCTAssertEqual(leftEnd.x, rightEnd.x, accuracy: 0.001)
        }
    }

    func testTieutUsesDigeutOrientationWithOpenRightSide() {
        let repository = LetterRepository()
        let tieut = repository.letters.first { $0.symbol == "ㅌ" }

        guard case let .polyline(points)? = tieut?.guideTemplate.strokes.first?.path else {
            return XCTFail("Expected a polyline base stroke for ㅌ")
        }

        XCTAssertEqual(points.count, 4)
        XCTAssertGreaterThan(points[0].x, points[1].x)
        XCTAssertEqual(points[1].x, points[2].x, accuracy: 0.001)
        XCTAssertLessThan(points[2].y, points[3].y)
    }

    func testDigeutAndRieulUseLeftSideVerticalSpine() {
        let repository = LetterRepository()
        let digeut = repository.letters.first { $0.symbol == "ㄷ" }
        let rieul = repository.letters.first { $0.symbol == "ㄹ" }

        guard case let .polyline(digeutPoints)? = digeut?.guideTemplate.strokes.first?.path,
              case let .polyline(rieulPoints)? = rieul?.guideTemplate.strokes.first?.path else {
            return XCTFail("Expected polyline strokes for ㄷ and ㄹ")
        }

        XCTAssertEqual(digeutPoints[1].x, digeutPoints[2].x, accuracy: 0.001)
        XCTAssertLessThan(digeutPoints[1].x, digeutPoints[0].x)

        XCTAssertEqual(rieulPoints[1].x, rieulPoints[2].x, accuracy: 0.001)
        XCTAssertLessThan(rieulPoints[1].x, rieulPoints[0].x)
    }

    func testSiotFormsAnInvertedVShape() {
        let repository = LetterRepository()
        let siot = repository.letters.first { $0.symbol == "ㅅ" }

        XCTAssertEqual(siot?.guideTemplate.strokes.count, 2)

        guard case let .polyline(leftStroke)? = siot?.guideTemplate.strokes.first?.path,
              case let .polyline(rightStroke)? = siot?.guideTemplate.strokes.last?.path,
              let leftStart = leftStroke.first,
              let leftEnd = leftStroke.last,
              let rightStart = rightStroke.first,
              let rightEnd = rightStroke.last else {
            return XCTFail("Expected polyline strokes for ㅅ")
        }

        XCTAssertLessThan(leftStart.x, rightStart.x)
        XCTAssertGreaterThan(leftEnd.x, leftStart.x)
        XCTAssertLessThan(rightEnd.x, rightStart.x)
        XCTAssertEqual(leftEnd.x, rightEnd.x, accuracy: 0.001)
        XCTAssertGreaterThan(leftEnd.y, leftStart.y)
        XCTAssertGreaterThan(rightEnd.y, rightStart.y)
    }

    func testPieupUsesDetachedTopAndBottomBars() {
        let repository = LetterRepository()
        let pieup = repository.letters.first { $0.symbol == "ㅍ" }

        guard let strokes = pieup?.guideTemplate.strokes,
              case let .polyline(topBar) = strokes[0].path,
              case let .polyline(leftVertical) = strokes[1].path,
              case let .polyline(rightVertical) = strokes[2].path,
              case let .polyline(bottomBar) = strokes[4].path,
              let topBarY = topBar.first?.y,
              let leftVerticalBottom = leftVertical.last?.y,
              let rightVerticalBottom = rightVertical.last?.y,
              let bottomBarY = bottomBar.first?.y else {
            return XCTFail("Expected polyline strokes for ㅍ")
        }

        XCTAssertLessThan(topBarY, leftVerticalBottom)
        XCTAssertLessThan(rightVerticalBottom, bottomBarY)
    }
}

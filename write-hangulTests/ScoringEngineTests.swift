import PencilKit
import XCTest
@testable import write_hangul

final class ScoringEngineTests: XCTestCase {
    func testEmptyDrawingFails() {
        let repository = LetterRepository()
        let letter = repository.letters(in: .consonant)[0]
        let evaluation = ScoringEngine().evaluate(drawing: PKDrawing(), letter: letter, canvasSize: CGSize(width: 300, height: 300))

        XCTAssertFalse(evaluation.passed)
        XCTAssertEqual(evaluation.score, 0)
    }

    func testTinyOffTargetDrawingFails() {
        let repository = LetterRepository()
        let letter = repository.letters(in: .vowel)[0]
        let drawing = makeDrawing(from: [CGPoint(x: 10, y: 10), CGPoint(x: 12, y: 12)])

        let evaluation = ScoringEngine().evaluate(drawing: drawing, letter: letter, canvasSize: CGSize(width: 300, height: 300))

        XCTAssertFalse(evaluation.passed)
    }

    func testDrawingOverlappingGuidePasses() {
        let repository = LetterRepository()
        let letter = repository.letter(id: "vowel-9")!
        let drawing = makeDrawing(from: [CGPoint(x: 150, y: 60), CGPoint(x: 150, y: 240)])

        let evaluation = ScoringEngine().evaluate(drawing: drawing, letter: letter, canvasSize: CGSize(width: 300, height: 300))

        XCTAssertTrue(evaluation.passed)
        XCTAssertGreaterThan(evaluation.score, 0.58)
    }

    private func makeDrawing(from points: [CGPoint]) -> PKDrawing {
        let strokePoints = points.map { point in
            PKStrokePoint(
                location: point,
                timeOffset: 0,
                size: CGSize(width: 18, height: 18),
                opacity: 1,
                force: 1,
                azimuth: 0,
                altitude: .pi / 2
            )
        }

        let path = PKStrokePath(controlPoints: strokePoints, creationDate: Date())
        let stroke = PKStroke(ink: PKInk(.pen, color: .black), path: path)
        return PKDrawing(strokes: [stroke])
    }
}

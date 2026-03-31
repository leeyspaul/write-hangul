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
        XCTAssertGreaterThan(evaluation.score, 0.54)
    }

    func testCircularIeungDrawingPasses() {
        let repository = LetterRepository()
        let letter = repository.letters(in: .consonant).first { $0.symbol == "ㅇ" }!
        let drawing = makeClosedLoopDrawing(points: circlePoints(center: CGPoint(x: 150, y: 150), radius: 64, segments: 96))

        let evaluation = ScoringEngine().evaluate(drawing: drawing, letter: letter, canvasSize: CGSize(width: 300, height: 300))

        XCTAssertTrue(evaluation.passed)
        XCTAssertGreaterThan(evaluation.score, ScoringEngine.passThreshold)
    }

    func testBlockyIeungDrawingScoresWorseThanCircularDrawing() {
        let repository = LetterRepository()
        let letter = repository.letters(in: .consonant).first { $0.symbol == "ㅇ" }!
        let circularDrawing = makeClosedLoopDrawing(points: circlePoints(center: CGPoint(x: 150, y: 150), radius: 64, segments: 96))
        let blockyDrawing = makeDrawing(strokes: [
            [
                CGPoint(x: 82, y: 82),
                CGPoint(x: 218, y: 82),
                CGPoint(x: 218, y: 218),
                CGPoint(x: 82, y: 218)
            ],
            [
                CGPoint(x: 82, y: 116),
                CGPoint(x: 218, y: 116)
            ],
            [
                CGPoint(x: 82, y: 150),
                CGPoint(x: 218, y: 150)
            ],
            [
                CGPoint(x: 82, y: 184),
                CGPoint(x: 218, y: 184)
            ]
        ])

        let circularEvaluation = ScoringEngine().evaluate(drawing: circularDrawing, letter: letter, canvasSize: CGSize(width: 300, height: 300))
        let blockyEvaluation = ScoringEngine().evaluate(drawing: blockyDrawing, letter: letter, canvasSize: CGSize(width: 300, height: 300))

        XCTAssertGreaterThan(circularEvaluation.score, blockyEvaluation.score)
    }

    private func makeDrawing(from points: [CGPoint]) -> PKDrawing {
        makeDrawing(from: points, closesShape: false)
    }

    private func makeClosedLoopDrawing(points: [CGPoint]) -> PKDrawing {
        makeDrawing(from: points, closesShape: true)
    }

    private func makeDrawing(strokes: [[CGPoint]]) -> PKDrawing {
        PKDrawing(strokes: strokes.map { points in
            makeStroke(from: points, closesShape: points.count > 2)
        })
    }

    private func makeDrawing(from points: [CGPoint], closesShape: Bool) -> PKDrawing {
        PKDrawing(strokes: [makeStroke(from: points, closesShape: closesShape)])
    }

    private func makeStroke(from points: [CGPoint], closesShape: Bool) -> PKStroke {
        let drawingPoints = closesShape ? points + [points[0]] : points
        let strokePoints = drawingPoints.map { point in
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
        return PKStroke(ink: PKInk(.pen, color: .black), path: path)
    }

    private func circlePoints(center: CGPoint, radius: CGFloat, segments: Int) -> [CGPoint] {
        (0..<segments).map { index in
            let angle = (CGFloat(index) / CGFloat(segments)) * (.pi * 2)
            return CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
        }
    }
}

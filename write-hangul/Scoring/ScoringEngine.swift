import CoreGraphics
import PencilKit

struct ScoringEngine {
    static let passThreshold = 0.58

    func evaluate(drawing: PKDrawing, letter: Letter, canvasSize: CGSize) -> PracticeEvaluation {
        let drawingBounds = drawing.bounds.integral
        guard !drawingBounds.isNull, drawingBounds.width > 8, drawingBounds.height > 8,
              canvasSize.width > 0, canvasSize.height > 0 else {
            return PracticeEvaluation(score: 0.0, passed: false, message: "Try again")
        }

        let normalizedDrawing = CGRect(
            x: drawingBounds.minX / canvasSize.width,
            y: drawingBounds.minY / canvasSize.height,
            width: drawingBounds.width / canvasSize.width,
            height: drawingBounds.height / canvasSize.height
        )

        let templateBounds = letter.guideTemplate.regions
            .map(\.rect)
            .reduce(into: CGRect.null) { partialResult, rect in
                partialResult = partialResult.union(rect)
            }

        let overlapRatio = normalizedDrawing.intersection(templateBounds).area / max(normalizedDrawing.area, 0.0001)
        let templateCoverage = normalizedDrawing.intersection(templateBounds).area / max(templateBounds.area, 0.0001)

        let drawingAspect = normalizedDrawing.width / max(normalizedDrawing.height, 0.0001)
        let templateAspect = templateBounds.width / max(templateBounds.height, 0.0001)
        let aspectScore = max(0, 1 - min(abs(drawingAspect - templateAspect), 1))

        let centerDistance = normalizedDrawing.center.distance(to: templateBounds.center)
        let centerScore = max(0, 1 - (centerDistance * 1.8))

        let sizeScore = normalizedDrawing.area < templateBounds.area * 0.18 ? 0.25 : 1.0
        let rawScore = (overlapRatio * 0.42) + (templateCoverage * 0.28) + (aspectScore * 0.15) + (centerScore * 0.15)
        let finalScore = max(0, min(rawScore * sizeScore, 1))
        let passed = finalScore >= Self.passThreshold

        return PracticeEvaluation(
            score: finalScore,
            passed: passed,
            message: passed ? "Good job" : "Try again"
        )
    }
}

private extension CGRect {
    var area: CGFloat {
        guard !isNull, !isEmpty else { return 0 }
        return width * height
    }

    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let deltaX = x - point.x
        let deltaY = y - point.y
        return sqrt((deltaX * deltaX) + (deltaY * deltaY))
    }
}

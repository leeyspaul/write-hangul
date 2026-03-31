import CoreGraphics
import PencilKit
import UIKit

struct ScoringEngine {
    static let passThreshold = 0.54
    private let scoringGridSize = CGSize(width: 192, height: 192)

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

        let templateBounds = letter.guideTemplate.bounds
        let overlapMetrics = overlapMetrics(drawing: drawing, template: letter.guideTemplate, canvasSize: canvasSize)
        let templateCoverage = normalizedDrawing.intersection(templateBounds).area / max(templateBounds.area, 0.0001)
        let shapeScore = ellipseShapeScore(drawing: drawing, template: letter.guideTemplate, canvasSize: canvasSize) ?? overlapMetrics.overlapRatio

        let overlapRatio = overlapMetrics.overlapRatio

        let drawingAspect = normalizedDrawing.width / max(normalizedDrawing.height, 0.0001)
        let templateAspect = templateBounds.width / max(templateBounds.height, 0.0001)
        let aspectScore = max(0, 1 - min(abs(drawingAspect - templateAspect), 1))

        let centerDistance = normalizedDrawing.center.distance(to: templateBounds.center)
        let centerScore = max(0, 1 - (centerDistance * 1.8))

        let sizeScore = normalizedDrawing.area < templateBounds.area * 0.18 ? 0.25 : 1.0
        let rawScore = (overlapRatio * 0.34) + (templateCoverage * 0.28) + (aspectScore * 0.15) + (centerScore * 0.15) + (shapeScore * 0.08)
        let finalScore = max(0, min(rawScore * sizeScore, 1))
        let passed = finalScore >= Self.passThreshold

        return PracticeEvaluation(
            score: finalScore,
            passed: passed,
            message: passed ? "Good job" : "Try again"
        )
    }

    private func overlapMetrics(drawing: PKDrawing, template: LetterGuideTemplate, canvasSize: CGSize) -> OverlapMetrics {
        let templateMask = templateMask(for: template, canvasSize: scoringGridSize)
        let drawingMask = drawingMask(for: drawing, canvasSize: canvasSize, outputSize: scoringGridSize)

        guard !templateMask.isEmpty, templateMask.count == drawingMask.count else {
            return OverlapMetrics(overlapRatio: 0)
        }

        var drawingPixels = 0
        var overlapPixels = 0

        for index in templateMask.indices {
            let drawingFilled = drawingMask[index] > 0

            if drawingFilled {
                drawingPixels += 1
            }

            if templateMask[index] > 0 && drawingFilled {
                overlapPixels += 1
            }
        }

        return OverlapMetrics(overlapRatio: CGFloat(overlapPixels) / max(CGFloat(drawingPixels), 1))
    }

    private func templateMask(for template: LetterGuideTemplate, canvasSize: CGSize) -> [UInt8] {
        rasterizedMask(size: canvasSize) { context in
            context.setFillColor(UIColor.white.cgColor)

            for path in template.strokedPaths(in: canvasSize) {
                context.addPath(path)
                context.fillPath()
            }
        }
    }

    private func drawingMask(for drawing: PKDrawing, canvasSize: CGSize, outputSize: CGSize) -> [UInt8] {
        let drawingImage = drawing.image(from: CGRect(origin: .zero, size: canvasSize), scale: 1)
        guard let cgImage = drawingImage.cgImage else {
            return []
        }

        return rasterizedMask(size: outputSize) { context in
            context.interpolationQuality = .high
            context.draw(cgImage, in: CGRect(origin: .zero, size: outputSize))
        }
    }

    private func ellipseShapeScore(drawing: PKDrawing, template: LetterGuideTemplate, canvasSize: CGSize) -> CGFloat? {
        let ellipseStrokes = template.strokes.filter { $0.path.ellipseRect != nil }
        guard !ellipseStrokes.isEmpty else { return nil }

        let drawingMask = drawingMask(for: drawing, canvasSize: canvasSize, outputSize: scoringGridSize)
        guard !drawingMask.isEmpty else { return nil }

        let width = Int(scoringGridSize.width)
        let height = Int(scoringGridSize.height)
        var sampledPixels = 0
        var totalError: CGFloat = 0

        for y in 0..<height {
            for x in 0..<width {
                let index = (y * width) + x
                guard drawingMask[index] > 0 else { continue }

                let point = CGPoint(x: CGFloat(x) + 0.5, y: CGFloat(y) + 0.5)
                let minimumError = ellipseStrokes.reduce(CGFloat.greatestFiniteMagnitude) { best, stroke in
                    guard let rect = stroke.path.ellipseRect else { return best }
                    return min(best, ellipseBoundaryError(for: point, rect: rect, canvasSize: scoringGridSize))
                }

                totalError += minimumError
                sampledPixels += 1
            }
        }

        guard sampledPixels > 0 else { return nil }
        let averageError = totalError / CGFloat(sampledPixels)
        return max(0, 1 - min(averageError * 2.4, 1))
    }

    private func rasterizedMask(size: CGSize, draw: (CGContext) -> Void) -> [UInt8] {
        let width = max(Int(size.width.rounded(.toNearestOrAwayFromZero)), 1)
        let height = max(Int(size.height.rounded(.toNearestOrAwayFromZero)), 1)
        let bytesPerRow = width
        var bytes = [UInt8](repeating: 0, count: width * height)

        guard let context = CGContext(
            data: &bytes,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return []
        }

        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        draw(context)

        return bytes.map { $0 > 16 ? 255 : 0 }
    }
}

private struct OverlapMetrics {
    let overlapRatio: CGFloat
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

private func ellipseBoundaryError(for point: CGPoint, rect: CGRect, canvasSize: CGSize) -> CGFloat {
    let frame = CGRect(
        x: rect.origin.x * canvasSize.width,
        y: rect.origin.y * canvasSize.height,
        width: rect.width * canvasSize.width,
        height: rect.height * canvasSize.height
    )

    let radiusX = max(frame.width / 2, 0.0001)
    let radiusY = max(frame.height / 2, 0.0001)
    let normalizedX = (point.x - frame.midX) / radiusX
    let normalizedY = (point.y - frame.midY) / radiusY
    let radialDistance = sqrt((normalizedX * normalizedX) + (normalizedY * normalizedY))

    return abs(radialDistance - 1)
}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let deltaX = x - point.x
        let deltaY = y - point.y
        return sqrt((deltaX * deltaX) + (deltaY * deltaY))
    }
}

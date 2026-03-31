import CoreGraphics
import Foundation

struct LetterGuideTemplate: Hashable {
    let strokes: [GuideStroke]

    init(strokes: [GuideStroke]) {
        self.strokes = strokes.sorted { $0.order < $1.order }
    }

    static func from(_ strokes: [GuideStroke]) -> LetterGuideTemplate {
        LetterGuideTemplate(strokes: strokes)
    }

    var bounds: CGRect {
        strokes
            .map(\.normalizedBounds)
            .reduce(into: CGRect.null) { partialResult, rect in
                partialResult = partialResult.union(rect)
            }
    }

    func strokedPaths(in size: CGSize) -> [CGPath] {
        strokes.map { $0.strokedPath(in: size) }
    }

    func startPoints(in size: CGSize) -> [CGPoint] {
        strokes.map { $0.scaledStartPoint(in: size) }
    }
}

struct GuideStroke: Hashable, Identifiable {
    let order: Int
    let path: GuideStrokePath
    let startPoint: CGPoint
    let directionHint: GuideStrokeDirection
    let lineWidth: CGFloat

    var id: Int { order }

    init(
        order: Int,
        path: GuideStrokePath,
        directionHint: GuideStrokeDirection,
        lineWidth: CGFloat = 0.12,
        startPoint: CGPoint? = nil
    ) {
        self.order = order
        self.path = path
        self.directionHint = directionHint
        self.lineWidth = lineWidth
        self.startPoint = startPoint ?? path.startPoint
    }

    var normalizedBounds: CGRect {
        strokedPath(in: CGSize(width: 1, height: 1)).boundingBox
    }

    func strokedPath(in size: CGSize) -> CGPath {
        path.cgPath(in: size).copy(
            strokingWithWidth: lineWidth * min(size.width, size.height),
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 4
        )
    }

    func scaledStartPoint(in size: CGSize) -> CGPoint {
        CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height)
    }
}

enum GuideStrokeDirection: String, Hashable {
    case up
    case down
    case left
    case right
    case downLeft
    case downRight
    case upLeft
    case upRight
    case clockwiseLoop
    case counterclockwiseLoop
}

enum GuideStrokePath: Hashable {
    case polyline([CGPoint])
    case ellipse(rect: CGRect, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool)

    var startPoint: CGPoint {
        switch self {
        case let .polyline(points):
            return points.first ?? .zero
        case let .ellipse(rect, startAngle, _, _):
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radiusX = rect.width / 2
            let radiusY = rect.height / 2
            return CGPoint(
                x: center.x + cos(startAngle) * radiusX,
                y: center.y + sin(startAngle) * radiusY
            )
        }
    }

    var ellipseRect: CGRect? {
        switch self {
        case let .ellipse(rect, _, _, _):
            rect
        case .polyline:
            nil
        }
    }

    func cgPath(in size: CGSize) -> CGPath {
        switch self {
        case let .polyline(points):
            let mutablePath = CGMutablePath()
            guard let firstPoint = points.first else { return mutablePath }

            mutablePath.move(to: firstPoint.scaled(to: size))
            for point in points.dropFirst() {
                mutablePath.addLine(to: point.scaled(to: size))
            }
            return mutablePath
        case let .ellipse(rect, startAngle, endAngle, _):
            let mutablePath = CGMutablePath()
            let scaledRect = rect.scaled(to: size)
            let center = CGPoint(x: scaledRect.midX, y: scaledRect.midY)
            let radiusX = scaledRect.width / 2
            let radiusY = scaledRect.height / 2
            let segments = 96

            let firstPoint = ellipsePoint(
                center: center,
                radiusX: radiusX,
                radiusY: radiusY,
                angle: startAngle
            )
            mutablePath.move(to: firstPoint)

            for step in 1...segments {
                let progress = CGFloat(step) / CGFloat(segments)
                let angle = startAngle + ((endAngle - startAngle) * progress)
                mutablePath.addLine(
                    to: ellipsePoint(
                        center: center,
                        radiusX: radiusX,
                        radiusY: radiusY,
                        angle: angle
                    )
                )
            }

            mutablePath.closeSubpath()
            return mutablePath
        }
    }
}

private func ellipsePoint(center: CGPoint, radiusX: CGFloat, radiusY: CGFloat, angle: CGFloat) -> CGPoint {
    CGPoint(
        x: center.x + cos(angle) * radiusX,
        y: center.y + sin(angle) * radiusY
    )
}

private extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        CGPoint(x: x * size.width, y: y * size.height)
    }
}

private extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        CGRect(
            x: origin.x * size.width,
            y: origin.y * size.height,
            width: width * size.width,
            height: height * size.height
        )
    }
}

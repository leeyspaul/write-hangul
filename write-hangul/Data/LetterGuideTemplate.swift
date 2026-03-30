import CoreGraphics
import Foundation

struct LetterGuideTemplate: Hashable {
    let regions: [GuideRegion]
    let demoStrokes: [DemoStroke]

    static func from(_ rects: [CGRect]) -> LetterGuideTemplate {
        LetterGuideTemplate(regions: rects.map(GuideRegion.init(rect:)), demoStrokes: [])
    }

    static func from(_ rects: [CGRect], demoStrokes: [DemoStroke]) -> LetterGuideTemplate {
        LetterGuideTemplate(regions: rects.map(GuideRegion.init(rect:)), demoStrokes: demoStrokes)
    }
}

struct DemoStroke: Hashable {
    let points: [DemoPoint]

    init(points: [DemoPoint]) {
        self.points = points
    }

    var endPoint: DemoPoint {
        points.last ?? DemoPoint(x: 0.5, y: 0.5)
    }

    var arrowAngleRadians: CGFloat {
        guard points.count >= 2 else { return 0 }
        let penultimate = points[points.count - 2]
        let last = points[points.count - 1]
        let deltaX = last.x - penultimate.x
        let deltaY = last.y - penultimate.y
        return atan2(deltaY, deltaX)
    }
}

struct DemoPoint: Hashable {
    let x: CGFloat
    let y: CGFloat

    var point: CGPoint {
        CGPoint(x: x, y: y)
    }
}

struct GuideRegion: Hashable {
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    init(rect: CGRect) {
        self.init(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
    }

    var rect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }

    var orientation: GuideOrientation {
        width >= height ? .horizontal : .vertical
    }

    var arrowSymbolName: String {
        switch orientation {
        case .horizontal:
            "arrow.right"
        case .vertical:
            "arrow.down"
        }
    }

    var startPoint: CGPoint {
        switch orientation {
        case .horizontal:
            CGPoint(x: rect.minX, y: rect.midY)
        case .vertical:
            CGPoint(x: rect.midX, y: rect.minY)
        }
    }

    var endPoint: CGPoint {
        switch orientation {
        case .horizontal:
            CGPoint(x: rect.maxX, y: rect.midY)
        case .vertical:
            CGPoint(x: rect.midX, y: rect.maxY)
        }
    }
}

enum GuideOrientation: Hashable {
    case horizontal
    case vertical
}

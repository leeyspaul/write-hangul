import CoreGraphics
import Foundation

struct LetterGuideTemplate: Hashable {
    let regions: [GuideRegion]

    static func from(_ rects: [CGRect]) -> LetterGuideTemplate {
        LetterGuideTemplate(regions: rects.map(GuideRegion.init(rect:)))
    }

    static func from(_ specifications: [GuideRegion.Specification]) -> LetterGuideTemplate {
        LetterGuideTemplate(regions: specifications.map(GuideRegion.init(specification:)))
    }
}

struct GuideRegion: Hashable {
    enum Shape: String, Hashable {
        case roundedRect
        case ellipse
    }

    struct Specification: Hashable {
        let shape: Shape
        let rect: CGRect

        init(shape: Shape, rect: CGRect) {
            self.shape = shape
            self.rect = rect
        }
    }

    let shape: Shape
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat

    init(shape: Shape = .roundedRect, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.shape = shape
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    init(rect: CGRect) {
        self.init(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
    }

    init(specification: Specification) {
        self.init(
            shape: specification.shape,
            x: specification.rect.origin.x,
            y: specification.rect.origin.y,
            width: specification.rect.width,
            height: specification.rect.height
        )
    }

    var rect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

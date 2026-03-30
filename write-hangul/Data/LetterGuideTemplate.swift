import CoreGraphics
import Foundation

struct LetterGuideTemplate: Hashable {
    let regions: [GuideRegion]

    static func from(_ rects: [CGRect]) -> LetterGuideTemplate {
        LetterGuideTemplate(regions: rects.map(GuideRegion.init(rect:)))
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
}

import CoreGraphics

enum CanonicalLetterTemplates {
    static let consonants: [(symbol: String, romanization: String, strokes: [GuideStroke])] = [
        ("ㄱ", "g/k", [
            cornerTopRight(order: 1, left: 0.30, top: 0.22, right: 0.68, bottom: 0.68)
        ]),
        ("ㄴ", "n", [
            cornerBottomRight(order: 1, left: 0.30, top: 0.22, right: 0.68, bottom: 0.68)
        ]),
        ("ㄷ", "d/t", [
            enclosureOpenRight(order: 1, left: 0.30, top: 0.22, right: 0.68, bottom: 0.68)
        ]),
        ("ㄹ", "r/l", [
            stroke(1, .right, width: 0.12, point(0.66, 0.24), point(0.30, 0.24), point(0.30, 0.40), point(0.58, 0.40)),
            stroke(2, .left, width: 0.12, point(0.58, 0.52), point(0.30, 0.52)),
            stroke(3, .downRight, width: 0.12, point(0.30, 0.52), point(0.30, 0.68), point(0.66, 0.68))
        ]),
        ("ㅁ", "m", [
            box(order: 1, left: 0.30, top: 0.24, right: 0.66, bottom: 0.66)
        ]),
        ("ㅂ", "b/p", [
            vertical(order: 1, x: 0.32, top: 0.22, bottom: 0.70),
            vertical(order: 2, x: 0.64, top: 0.22, bottom: 0.70),
            horizontal(order: 3, y: 0.46, left: 0.32, right: 0.64),
            horizontal(order: 4, y: 0.70, left: 0.32, right: 0.64)
        ]),
        ("ㅅ", "s", [
            stroke(1, .downRight, width: 0.11, point(0.40, 0.30), point(0.50, 0.58)),
            stroke(2, .upRight, width: 0.11, point(0.60, 0.30), point(0.50, 0.58))
        ]),
        ("ㅇ", "ng", [
            loop(1, rect(0.30, 0.28, 0.40, 0.40), .clockwiseLoop, width: 0.11)
        ]),
        ("ㅈ", "j", [
            horizontal(order: 1, y: 0.24, left: 0.30, right: 0.70, width: 0.10),
            stroke(2, .downRight, width: 0.11, point(0.40, 0.38), point(0.50, 0.62)),
            stroke(3, .upRight, width: 0.11, point(0.60, 0.38), point(0.50, 0.62))
        ]),
        ("ㅊ", "ch", [
            horizontal(order: 1, y: 0.14, left: 0.42, right: 0.58, width: 0.09),
            horizontal(order: 2, y: 0.26, left: 0.28, right: 0.72, width: 0.10),
            stroke(3, .downRight, width: 0.11, point(0.40, 0.40), point(0.50, 0.64)),
            stroke(4, .upRight, width: 0.11, point(0.60, 0.40), point(0.50, 0.64))
        ]),
        ("ㅋ", "k", [
            cornerTopRight(order: 1, left: 0.28, top: 0.22, right: 0.66, bottom: 0.68),
            horizontal(order: 2, y: 0.46, left: 0.36, right: 0.62, width: 0.10)
        ]),
        ("ㅌ", "t", [
            enclosureOpenRight(order: 1, left: 0.30, top: 0.22, right: 0.68, bottom: 0.68),
            horizontal(order: 2, y: 0.44, left: 0.36, right: 0.64, width: 0.10)
        ]),
        ("ㅍ", "p", [
            horizontal(order: 1, y: 0.22, left: 0.28, right: 0.72, width: 0.10),
            vertical(order: 2, x: 0.34, top: 0.34, bottom: 0.56),
            vertical(order: 3, x: 0.62, top: 0.34, bottom: 0.56),
            horizontal(order: 4, y: 0.46, left: 0.34, right: 0.62, width: 0.10),
            horizontal(order: 5, y: 0.68, left: 0.30, right: 0.66, width: 0.10)
        ]),
        ("ㅎ", "h", [
            horizontal(order: 1, y: 0.20, left: 0.40, right: 0.60, width: 0.09),
            loop(2, rect(0.32, 0.34, 0.36, 0.28), .clockwiseLoop, width: 0.10),
            horizontal(order: 3, y: 0.64, left: 0.28, right: 0.72, width: 0.09)
        ])
    ]

    static let vowels: [(symbol: String, romanization: String, strokes: [GuideStroke])] = [
        ("ㅏ", "a", [
            vertical(order: 1, x: 0.48, top: 0.16, bottom: 0.78),
            horizontal(order: 2, y: 0.44, left: 0.48, right: 0.70, width: 0.10)
        ]),
        ("ㅑ", "ya", [
            vertical(order: 1, x: 0.48, top: 0.16, bottom: 0.78),
            horizontal(order: 2, y: 0.34, left: 0.48, right: 0.70, width: 0.10),
            horizontal(order: 3, y: 0.56, left: 0.48, right: 0.70, width: 0.10)
        ]),
        ("ㅓ", "eo", [
            vertical(order: 1, x: 0.52, top: 0.16, bottom: 0.78),
            horizontal(order: 2, y: 0.44, left: 0.30, right: 0.52, width: 0.10)
        ]),
        ("ㅕ", "yeo", [
            vertical(order: 1, x: 0.52, top: 0.16, bottom: 0.78),
            horizontal(order: 2, y: 0.34, left: 0.30, right: 0.52, width: 0.10),
            horizontal(order: 3, y: 0.56, left: 0.30, right: 0.52, width: 0.10)
        ]),
        ("ㅗ", "o", [
            vertical(order: 1, x: 0.50, top: 0.18, bottom: 0.36, width: 0.10),
            horizontal(order: 2, y: 0.44, left: 0.24, right: 0.76)
        ]),
        ("ㅛ", "yo", [
            vertical(order: 1, x: 0.38, top: 0.18, bottom: 0.34, width: 0.10),
            vertical(order: 2, x: 0.62, top: 0.18, bottom: 0.34, width: 0.10),
            horizontal(order: 3, y: 0.46, left: 0.24, right: 0.76)
        ]),
        ("ㅜ", "u", [
            horizontal(order: 1, y: 0.44, left: 0.24, right: 0.76),
            vertical(order: 2, x: 0.50, top: 0.52, bottom: 0.72, width: 0.10)
        ]),
        ("ㅠ", "yu", [
            horizontal(order: 1, y: 0.40, left: 0.24, right: 0.76),
            vertical(order: 2, x: 0.38, top: 0.48, bottom: 0.66, width: 0.10),
            vertical(order: 3, x: 0.62, top: 0.48, bottom: 0.66, width: 0.10)
        ]),
        ("ㅡ", "eu", [
            horizontal(order: 1, y: 0.50, left: 0.20, right: 0.80)
        ]),
        ("ㅣ", "i", [
            vertical(order: 1, x: 0.50, top: 0.16, bottom: 0.80)
        ])
    ]
}

private extension CanonicalLetterTemplates {
    static func horizontal(
        order: Int,
        y: CGFloat,
        left: CGFloat,
        right: CGFloat,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        stroke(order, .right, width: width, point(left, y), point(right, y))
    }

    static func vertical(
        order: Int,
        x: CGFloat,
        top: CGFloat,
        bottom: CGFloat,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        stroke(order, .down, width: width, point(x, top), point(x, bottom))
    }

    static func cornerTopRight(
        order: Int,
        left: CGFloat,
        top: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        stroke(order, .right, width: width, point(left, top), point(right, top), point(right, bottom))
    }

    static func cornerBottomRight(
        order: Int,
        left: CGFloat,
        top: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        stroke(order, .down, width: width, point(left, top), point(left, bottom), point(right, bottom))
    }

    static func enclosureOpenLeft(
        order: Int,
        left: CGFloat,
        top: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        stroke(order, .right, width: width, point(left, top), point(right, top), point(right, bottom), point(left, bottom))
    }

    static func enclosureOpenRight(
        order: Int,
        left: CGFloat,
        top: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        stroke(order, .left, width: width, point(right, top), point(left, top), point(left, bottom), point(right, bottom))
    }

    static func box(
        order: Int,
        left: CGFloat,
        top: CGFloat,
        right: CGFloat,
        bottom: CGFloat,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        stroke(order, .right, width: width, point(left, top), point(right, top), point(right, bottom), point(left, bottom), point(left, top))
    }

    static func stroke(
        _ order: Int,
        _ direction: GuideStrokeDirection,
        width: CGFloat = 0.12,
        _ points: CGPoint...
    ) -> GuideStroke {
        GuideStroke(
            order: order,
            path: .polyline(points),
            directionHint: direction,
            lineWidth: width
        )
    }

    static func loop(
        _ order: Int,
        _ rect: CGRect,
        _ direction: GuideStrokeDirection,
        width: CGFloat = 0.12
    ) -> GuideStroke {
        GuideStroke(
            order: order,
            path: .ellipse(rect: rect, startAngle: -.pi / 2, endAngle: (.pi * 3) / 2, clockwise: direction == .clockwiseLoop),
            directionHint: direction,
            lineWidth: width
        )
    }

    static func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x, y: y)
    }

    static func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

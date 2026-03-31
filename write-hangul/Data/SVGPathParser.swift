import CoreGraphics
import Foundation

struct SVGParsedPath {
    let cgPath: CGPath
    let points: [CGPoint]
    let startPoint: CGPoint
}

enum SVGPathParser {
    static func parse(_ data: String) -> SVGParsedPath? {
        let tokens = tokenize(data)
        guard !tokens.isEmpty else { return nil }

        let path = CGMutablePath()
        var points: [CGPoint] = []
        var index = 0
        var command: Character = " "
        var currentPoint = CGPoint.zero
        var subpathStart = CGPoint.zero

        func nextNumber() -> CGFloat? {
            guard index < tokens.count, case let .number(value) = tokens[index] else { return nil }
            index += 1
            return value
        }

        while index < tokens.count {
            if case let .command(next) = tokens[index] {
                command = next
                index += 1
            }

            switch command {
            case "M":
                guard let x = nextNumber(), let y = nextNumber() else { return nil }
                currentPoint = CGPoint(x: x, y: y)
                subpathStart = currentPoint
                path.move(to: currentPoint)
                points.append(currentPoint)
                command = "L"
            case "L":
                guard let x = nextNumber(), let y = nextNumber() else { return nil }
                currentPoint = CGPoint(x: x, y: y)
                path.addLine(to: currentPoint)
                points.append(currentPoint)
            case "H":
                guard let x = nextNumber() else { return nil }
                currentPoint = CGPoint(x: x, y: currentPoint.y)
                path.addLine(to: currentPoint)
                points.append(currentPoint)
            case "V":
                guard let y = nextNumber() else { return nil }
                currentPoint = CGPoint(x: currentPoint.x, y: y)
                path.addLine(to: currentPoint)
                points.append(currentPoint)
            case "C":
                guard let x1 = nextNumber(), let y1 = nextNumber(),
                      let x2 = nextNumber(), let y2 = nextNumber(),
                      let x = nextNumber(), let y = nextNumber() else { return nil }
                let endPoint = CGPoint(x: x, y: y)
                path.addCurve(
                    to: endPoint,
                    control1: CGPoint(x: x1, y: y1),
                    control2: CGPoint(x: x2, y: y2)
                )
                currentPoint = endPoint
                points.append(endPoint)
            case "Z":
                path.closeSubpath()
                currentPoint = subpathStart
            default:
                return nil
            }
        }

        return SVGParsedPath(cgPath: path, points: points, startPoint: subpathStart)
    }

    private static func tokenize(_ data: String) -> [Token] {
        let pattern = #"[MLHVCZ]|-?\d*\.?\d+"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(data.startIndex..., in: data)

        return regex?.matches(in: data, range: range).compactMap { match in
            guard let tokenRange = Range(match.range, in: data) else { return nil }
            let token = String(data[tokenRange])
            if let command = token.first, token.count == 1, command.isLetter {
                return .command(command)
            }
            if let value = Double(token) {
                return .number(CGFloat(value))
            }
            return nil
        } ?? []
    }

    private enum Token {
        case command(Character)
        case number(CGFloat)
    }
}

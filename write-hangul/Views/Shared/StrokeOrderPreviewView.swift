import SwiftUI

struct StrokeOrderPreviewView: View {
    let symbol: String
    let template: LetterGuideTemplate
    let playbackTrigger: Int
    var onPlaybackStarted: (() -> Void)? = nil
    var onPlaybackFinished: (() -> Void)? = nil

    @State private var completedStrokeCount = 0
    @State private var activeStrokeIndex = 0
    @State private var activeStrokeProgress: CGFloat = 0
    @State private var isPlaybackActive = false

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                GlyphOutlineView(symbol: symbol, color: Color.appGuide.opacity(0.22), paddingRatio: 0.14)

                ForEach(Array(template.strokes.enumerated()), id: \.element.id) { index, stroke in
                    if index < completedStrokeCount {
                        previewPath(for: stroke, in: size)
                            .stroke(Color.appAccent, style: stroke.strokeStyle(in: size))
                    } else if isPlaybackActive, index == activeStrokeIndex {
                        previewPath(for: stroke, in: size)
                            .stroke(Color.appGuide.opacity(0.32), style: stroke.strokeStyle(in: size))

                        previewPath(for: stroke, in: size)
                            .trim(from: 0, to: activeStrokeProgress)
                            .stroke(Color.appAccent, style: stroke.strokeStyle(in: size))
                    }
                }

                if isPlaybackActive, let activeStroke = activeStroke {
                    Circle()
                        .fill(Color.appPreviewStart)
                        .frame(
                            width: max(activeStroke.scaledLineWidth(in: size) * 0.7, 12),
                            height: max(activeStroke.scaledLineWidth(in: size) * 0.7, 12)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.9), lineWidth: 2)
                        )
                        .position(activeStroke.scaledStartPoint(in: size))
                        .shadow(color: Color.appPreviewStart.opacity(0.25), radius: 8, y: 2)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task(id: playbackTrigger) {
            await playPreview()
        }
        .accessibilityLabel("Stroke order preview")
    }

    private var activeStroke: GuideStroke? {
        guard template.strokes.indices.contains(activeStrokeIndex),
              completedStrokeCount < template.strokes.count else {
            return nil
        }

        return template.strokes[activeStrokeIndex]
    }

    private func previewPath(for stroke: GuideStroke, in size: CGSize) -> Path {
        Path(stroke.path.cgPath(in: size))
    }

    @MainActor
    private func resetPlayback() {
        completedStrokeCount = 0
        activeStrokeIndex = 0
        activeStrokeProgress = 0
        isPlaybackActive = false
    }

    private func playPreview() async {
        await MainActor.run {
            resetPlayback()
        }

        guard !template.strokes.isEmpty else {
            await MainActor.run {
                onPlaybackFinished?()
            }
            return
        }

        await MainActor.run {
            isPlaybackActive = true
            onPlaybackStarted?()
        }

        let frameDelay: UInt64 = 18_000_000

        for index in template.strokes.indices {
            await MainActor.run {
                completedStrokeCount = index
                activeStrokeIndex = index
                activeStrokeProgress = 0
            }

            let stepCount = strokeStepCount(for: template.strokes[index])
            for step in 1...stepCount {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    activeStrokeProgress = CGFloat(step) / CGFloat(stepCount)
                }

                try? await Task.sleep(nanoseconds: frameDelay)
            }

            try? await Task.sleep(nanoseconds: 60_000_000)
        }

        guard !Task.isCancelled else { return }

        await MainActor.run {
            completedStrokeCount = template.strokes.count
            activeStrokeIndex = template.strokes.count
            activeStrokeProgress = 0
            isPlaybackActive = false
            onPlaybackFinished?()
        }
    }

    private func strokeStepCount(for stroke: GuideStroke) -> Int {
        switch stroke.path {
        case let .polyline(points):
            return max(8, points.count * 4)
        case .ellipse:
            return 18
        case let .vector(path):
            let bounds = path.path.boundingBoxOfPath
            let complexity = Int(((bounds.width + bounds.height) * 55).rounded())
            return max(10, complexity)
        }
    }
}

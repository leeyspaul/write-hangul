import PencilKit
import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    let repository: LetterRepository

    @State private var currentLetterID: String
    @State private var drawing = PKDrawing()
    @State private var canvasSize: CGSize = .zero
    @State private var feedback: PracticeEvaluation?
    @State private var clearTrigger = 0
    @State private var previewTrigger = 0
    @State private var isPreviewPlaying = false
    @State private var hasCompletedPreview = false

    private let scoringEngine = ScoringEngine()

    init(initialLetterID: String, repository: LetterRepository) {
        self.repository = repository
        _currentLetterID = State(initialValue: initialLetterID)
    }

    var body: some View {
        let letter = currentLetter

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PracticeHeaderView(letter: letter, progress: progressStore.progress(for: letter.id))

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white.opacity(0.94))

                    VStack(spacing: 18) {
                        ZStack {
                            GlyphOutlineView(symbol: letter.symbol)
                                .padding(28)

                            TracingCanvasView(
                                drawing: $drawing,
                                clearTrigger: clearTrigger,
                                canvasSize: $canvasSize
                            )
                            .padding(18)
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)

                        compactPreviewSection(for: letter)

                        PracticeControlsView(
                            canGoPrevious: repository.adjacentLetter(to: letter, direction: .previous) != nil,
                            canGoNext: repository.adjacentLetter(to: letter, direction: .next) != nil,
                            onClear: clearCanvas,
                            onPrevious: { move(.previous) },
                            onNext: { move(.next) },
                            onDone: evaluateCurrentDrawing
                        )
                    }
                    .padding(18)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.appCardBorder, lineWidth: 1)
                )

                if let feedback {
                    FeedbackBannerView(evaluation: feedback)
                }
            }
            .padding(20)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(letter.symbol)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentLetter: Letter {
        repository.letter(id: currentLetterID) ?? repository.letters[0]
    }

    private func clearCanvas() {
        drawing = PKDrawing()
        feedback = nil
        clearTrigger += 1
    }

    private func move(_ direction: NavigationDirection) {
        guard let adjacent = repository.adjacentLetter(to: currentLetter, direction: direction) else { return }
        currentLetterID = adjacent.id
        resetPreview()
        previewTrigger += 1
        clearCanvas()
    }

    private func evaluateCurrentDrawing() {
        let evaluation = scoringEngine.evaluate(drawing: drawing, letter: currentLetter, canvasSize: canvasSize)
        progressStore.saveResult(letterID: currentLetter.id, score: evaluation.score)
        feedback = evaluation
    }

    private func replayPreview() {
        resetPreview()
        previewTrigger += 1
    }

    private func resetPreview() {
        isPreviewPlaying = false
        hasCompletedPreview = false
    }

    @ViewBuilder
    private func compactPreviewSection(for letter: Letter) -> some View {
        HStack(spacing: 14) {
            StrokeOrderPreviewView(
                symbol: letter.symbol,
                template: letter.guideTemplate,
                playbackTrigger: previewTrigger,
                onPlaybackStarted: {
                    isPreviewPlaying = true
                    hasCompletedPreview = false
                },
                onPlaybackFinished: {
                    isPreviewPlaying = false
                    hasCompletedPreview = true
                }
            )
            .padding(12)
            .frame(width: 122, height: 122)
            .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text("Stroke order")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appInk)

                Text(previewStatusText)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appMuted)
                    .fixedSize(horizontal: false, vertical: true)

                Button(isPreviewPlaying ? "Playing..." : "Replay", action: replayPreview)
                    .buttonStyle(PreviewReplayButtonStyle())
                    .disabled(isPreviewPlaying)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appTile, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
    }

    private var previewStatusText: String {
        if isPreviewPlaying {
            return "Follow the highlighted stroke and start point."
        }

        if hasCompletedPreview {
            return "Preview finished. Replay it any time before tracing."
        }

        return "The preview will play each stroke in order."
    }
}

private struct PreviewReplayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.appTile.opacity(configuration.isPressed ? 0.72 : 1), in: Capsule())
            .foregroundStyle(Color.appInk)
    }
}

struct PracticeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PracticeView(initialLetterID: "consonant-0", repository: LetterRepository())
                .environmentObject(ProgressStore.preview)
        }
    }
}

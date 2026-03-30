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
                            Text(letter.symbol)
                                .font(.system(size: 230, weight: .regular, design: .rounded))
                                .foregroundStyle(Color.appAccent.opacity(0.16))

                            TracingCanvasView(
                                drawing: $drawing,
                                clearTrigger: clearTrigger,
                                canvasSize: $canvasSize
                            )
                            .padding(18)
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)

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
        clearCanvas()
    }

    private func evaluateCurrentDrawing() {
        let evaluation = scoringEngine.evaluate(drawing: drawing, letter: currentLetter, canvasSize: canvasSize)
        progressStore.saveResult(letterID: currentLetter.id, score: evaluation.score)
        feedback = evaluation
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

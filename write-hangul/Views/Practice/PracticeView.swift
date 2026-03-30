import PencilKit
import SwiftUI

struct PracticeView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    let repository: LetterRepository

    @State private var selectedPage = 0
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
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(selectedPage == 0 ? "Watch how to draw it" : "Trace it yourself")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.appInk)

                                Spacer()

                                Text(selectedPage == 0 ? "Swipe to practice" : "Swipe back to review")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.appMuted)
                            }

                            TabView(selection: $selectedPage) {
                                DemoPracticeCard(letter: letter)
                                    .tag(0)

                                TracePracticeCard(
                                    letter: letter,
                                    drawing: $drawing,
                                    clearTrigger: clearTrigger,
                                    canvasSize: $canvasSize
                                )
                                .tag(1)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)

                            HStack(spacing: 8) {
                                ForEach(0..<2, id: \.self) { index in
                                    Capsule()
                                        .fill(index == selectedPage ? Color.appAccent : Color.appCardBorder)
                                        .frame(width: index == selectedPage ? 24 : 8, height: 8)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        if selectedPage == 0 {
                            DemoControlsView(
                                canGoPrevious: repository.adjacentLetter(to: letter, direction: .previous) != nil,
                                canGoNext: repository.adjacentLetter(to: letter, direction: .next) != nil,
                                onPrevious: { move(.previous) },
                                onNext: { move(.next) },
                                onTryIt: { selectedPage = 1 }
                            )
                        } else {
                            PracticeControlsView(
                                canGoPrevious: repository.adjacentLetter(to: letter, direction: .previous) != nil,
                                canGoNext: repository.adjacentLetter(to: letter, direction: .next) != nil,
                                onClear: clearCanvas,
                                onPrevious: { move(.previous) },
                                onNext: { move(.next) },
                                onDone: evaluateCurrentDrawing
                            )
                        }
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
        selectedPage = 0
        clearCanvas()
    }

    private func evaluateCurrentDrawing() {
        let evaluation = scoringEngine.evaluate(drawing: drawing, letter: currentLetter, canvasSize: canvasSize)
        progressStore.saveResult(letterID: currentLetter.id, score: evaluation.score)
        feedback = evaluation
    }
}

private struct DemoPracticeCard: View {
    let letter: Letter

    @State private var activeStrokeIndex: Int?
    @State private var completedCount = 0
    @State private var activeProgress: CGFloat = 0
    @State private var hasFinishedDemo = false
    @State private var playbackTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Text(letter.symbol)
                    .font(.system(size: 230, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.appAccent.opacity(0.10))

                ForEach(Array(letter.guideTemplate.demoStrokes.enumerated()), id: \.offset) { index, stroke in
                    DemoStrokeShapeView(
                        stroke: stroke,
                        progress: activeStrokeIndex == index ? activeProgress : (index < completedCount ? 1 : 0),
                        isActive: activeStrokeIndex == index,
                        canvasSize: geometry.size
                    )
                }

                if hasFinishedDemo {
                    VStack {
                        Spacer()

                        Button {
                            startPlayback()
                        } label: {
                            Label("Replay demo", systemImage: "arrow.clockwise")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.95), in: Capsule())
                                .foregroundStyle(Color.appInk)
                        }
                        .padding(.bottom, 18)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appTile.opacity(0.35), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .task(id: letter.id) {
                startPlayback()
            }
            .onDisappear {
                playbackTask?.cancel()
            }
        }
    }

    private func startPlayback() {
        playbackTask?.cancel()
        activeStrokeIndex = nil
        completedCount = 0
        activeProgress = 0
        hasFinishedDemo = false

        playbackTask = Task {
            for index in letter.guideTemplate.demoStrokes.indices {
                if Task.isCancelled { return }

                await MainActor.run {
                    activeStrokeIndex = index
                    activeProgress = 0
                }

                await MainActor.run {
                    withAnimation(.easeInOut(duration: 1.2)) {
                        activeProgress = 1
                    }
                }

                try? await Task.sleep(for: .milliseconds(1450))
                if Task.isCancelled { return }

                await MainActor.run {
                    completedCount = index + 1
                    activeStrokeIndex = nil
                    activeProgress = 0
                }

                try? await Task.sleep(for: .milliseconds(220))
            }

            await MainActor.run {
                hasFinishedDemo = true
            }
        }
    }
}

private struct DemoStrokeShapeView: View {
    let stroke: DemoStroke
    let progress: CGFloat
    let isActive: Bool
    let canvasSize: CGSize

    var body: some View {
        ZStack {
            DemoStrokePath(stroke: stroke)
                .trim(from: 0, to: progress)
                .stroke(
                    isActive ? Color.appAccent : Color.appAccent.opacity(progress > 0 ? 0.65 : 0),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round)
                )

            if isActive {
                Image(systemName: "arrow.right")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.appAccent)
                    .position(
                        x: canvasSize.width * stroke.endPoint.x,
                        y: canvasSize.height * stroke.endPoint.y
                    )
                    .rotationEffect(.radians(stroke.arrowAngleRadians))
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

private struct DemoStrokePath: Shape {
    let stroke: DemoStroke

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = stroke.points.first else { return path }

        path.move(to: CGPoint(x: rect.width * first.x, y: rect.height * first.y))
        for point in stroke.points.dropFirst() {
            path.addLine(to: CGPoint(x: rect.width * point.x, y: rect.height * point.y))
        }

        return path
    }
}

private struct TracePracticeCard: View {
    let letter: Letter
    @Binding var drawing: PKDrawing
    let clearTrigger: Int
    @Binding var canvasSize: CGSize

    var body: some View {
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
        .background(Color.appTile.opacity(0.35), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
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

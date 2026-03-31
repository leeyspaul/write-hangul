import PencilKit
import SwiftUI

struct TracingCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let clearTrigger: Int
    @Binding var canvasSize: CGSize

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing, canvasSize: $canvasSize)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = MeasuringCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.alwaysBounceVertical = false
        canvasView.alwaysBounceHorizontal = false
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 14)
        canvasView.drawing = drawing
        canvasView.onBoundsChange = { size in
            context.coordinator.updateCanvasSize(size)
        }
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }

        if context.coordinator.lastClearTrigger != clearTrigger {
            uiView.drawing = PKDrawing()
            context.coordinator.lastClearTrigger = clearTrigger
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding private var drawing: PKDrawing
        @Binding private var canvasSize: CGSize
        var lastClearTrigger: Int

        init(drawing: Binding<PKDrawing>, canvasSize: Binding<CGSize>) {
            _drawing = drawing
            _canvasSize = canvasSize
            lastClearTrigger = 0
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
            updateCanvasSize(canvasView.bounds.size)
        }

        func updateCanvasSize(_ size: CGSize) {
            guard canvasSize != size else { return }
            canvasSize = size
        }
    }
}

private final class MeasuringCanvasView: PKCanvasView {
    var onBoundsChange: ((CGSize) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onBoundsChange?(bounds.size)
    }
}

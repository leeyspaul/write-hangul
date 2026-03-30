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
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.alwaysBounceVertical = false
        canvasView.alwaysBounceHorizontal = false
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 14)
        canvasView.drawing = drawing
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }

        if context.coordinator.lastClearTrigger != clearTrigger {
            uiView.drawing = PKDrawing()
            drawing = uiView.drawing
            context.coordinator.lastClearTrigger = clearTrigger
        }

        DispatchQueue.main.async {
            canvasSize = uiView.bounds.size
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
            canvasSize = canvasView.bounds.size
        }
    }
}

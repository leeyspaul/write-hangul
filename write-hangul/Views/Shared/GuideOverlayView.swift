import SwiftUI

struct GuideOverlayView: View {
    let template: LetterGuideTemplate

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(template.strokes) { stroke in
                    Path(stroke.path.cgPath(in: geometry.size))
                        .stroke(Color.appGuide, style: stroke.strokeStyle(in: geometry.size))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

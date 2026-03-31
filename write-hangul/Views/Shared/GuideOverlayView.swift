import SwiftUI

struct GuideOverlayView: View {
    let template: LetterGuideTemplate

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(template.strokes) { stroke in
                    Path(stroke.strokedPath(in: geometry.size))
                        .fill(Color.appGuide)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

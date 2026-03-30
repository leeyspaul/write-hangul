import SwiftUI

struct GuideOverlayView: View {
    let template: LetterGuideTemplate

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(template.regions.enumerated()), id: \.offset) { item in
                    let region = item.element
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.appGuide)
                        .frame(
                            width: geometry.size.width * region.width,
                            height: geometry.size.height * region.height
                        )
                        .position(
                            x: geometry.size.width * (region.x + (region.width / 2)),
                            y: geometry.size.height * (region.y + (region.height / 2))
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

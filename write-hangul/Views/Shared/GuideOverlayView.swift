import SwiftUI

struct GuideOverlayView: View {
    let template: LetterGuideTemplate
    private let roundedCornerRadius: CGFloat = 12
    private let ellipseStrokeFraction: CGFloat = 0.12

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(template.regions.enumerated()), id: \.offset) { item in
                    let region = item.element
                    guideView(for: region, in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func guideView(for region: GuideRegion, in size: CGSize) -> some View {
        let width = size.width * region.width
        let height = size.height * region.height
        let x = size.width * (region.x + (region.width / 2))
        let y = size.height * (region.y + (region.height / 2))

        switch region.shape {
        case .roundedRect:
            RoundedRectangle(cornerRadius: roundedCornerRadius, style: .continuous)
                .fill(Color.appGuide)
                .frame(width: width, height: height)
                .position(x: x, y: y)
        case .ellipse:
            let lineWidth = min(width, height) * ellipseStrokeFraction

            Ellipse()
                .stroke(Color.appGuide, lineWidth: lineWidth)
                .frame(width: width, height: height)
                .position(x: x, y: y)
        }
    }
}

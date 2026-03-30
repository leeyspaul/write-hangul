import SwiftUI

struct FeedbackBannerView: View {
    let evaluation: PracticeEvaluation

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: evaluation.passed ? "hand.thumbsup.fill" : "pencil.tip.crop.circle.badge.xmark")
                .font(.system(size: 24))
                .foregroundStyle(evaluation.passed ? Color.appAccent : Color.appWarning)

            VStack(alignment: .leading, spacing: 4) {
                Text(evaluation.message)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appInk)

                Text("Prototype score: \(Int(evaluation.score * 100))%")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appMuted)
            }

            Spacer()
        }
        .padding(16)
        .background((evaluation.passed ? Color.appSuccessWash : Color.appWarningWash), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

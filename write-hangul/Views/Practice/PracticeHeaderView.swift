import SwiftUI

struct PracticeHeaderView: View {
    let letter: Letter
    let progress: PracticeProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(letter.category == .consonant ? "Basic consonant" : "Basic vowel")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appMuted)

            HStack(alignment: .center, spacing: 10) {
                LetterGlyphMarkView(symbol: letter.symbol, size: 68, color: .appInk, paddingRatio: 0.08)

                Text(letter.romanization)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.appMuted)
            }

            Text(progress.isCompleted ? "Passed before with a best score of \(Int(progress.bestScore * 100))%." : "Trace the guide with your finger, then tap Done.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.appMuted)
        }
    }
}

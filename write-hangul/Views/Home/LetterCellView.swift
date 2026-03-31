import SwiftUI

struct LetterCellView: View {
    let letter: Letter
    let progress: PracticeProgress

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                if progress.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appAccent)
                }
            }

            LetterGlyphMarkView(symbol: letter.symbol, size: 46, color: .appInk, paddingRatio: 0.1)

            Text(letter.romanization)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.appMuted)

            Text(progress.bestScore > 0 ? "\(Int(progress.bestScore * 100))%" : "Start")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(progress.isCompleted ? Color.appAccent : Color.appMuted)
        }
        .frame(maxWidth: .infinity, minHeight: 118)
        .padding(14)
        .background(Color.appTile, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

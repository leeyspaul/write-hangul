import SwiftUI

struct LetterSectionView: View {
    @EnvironmentObject private var progressStore: ProgressStore

    let category: LetterCategory
    let letters: [Letter]
    let repository: LetterRepository

    private let columns = [GridItem(.adaptive(minimum: 90, maximum: 120), spacing: 14)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appInk)

                    Text(category.subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.appMuted)
                }

                Spacer()

                Text("\(progressStore.completionCount(in: category, repository: repository))/\(letters.count)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.appMuted)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.7), in: Capsule())
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(letters) { letter in
                    NavigationLink {
                        PracticeView(initialLetterID: letter.id, repository: repository)
                    } label: {
                        LetterCellView(letter: letter, progress: progressStore.progress(for: letter.id))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.9), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.appCardBorder, lineWidth: 1)
        )
    }
}

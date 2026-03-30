import SwiftUI

struct HomeView: View {
    let repository: LetterRepository

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                ForEach(LetterCategory.allCases, id: \.self) { category in
                    LetterSectionView(
                        category: category,
                        letters: repository.letters(in: category),
                        repository: repository
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Write Hangul")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Trace the Hangul basics")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.appInk)

            Text("Practice the core consonants and vowels one letter at a time.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color.appMuted)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(repository: LetterRepository())
                .environmentObject(ProgressStore.preview)
        }
    }
}

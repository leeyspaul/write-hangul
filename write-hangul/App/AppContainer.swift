import SwiftUI

struct AppContainer: View {
    var body: some View {
        NavigationStack {
            HomeView(repository: LetterRepository())
        }
    }
}

struct AppContainer_Previews: PreviewProvider {
    static var previews: some View {
        AppContainer()
            .environmentObject(ProgressStore.preview)
    }
}

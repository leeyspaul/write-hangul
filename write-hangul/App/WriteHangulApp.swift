import SwiftUI

@main
struct WriteHangulApp: App {
    @StateObject private var progressStore = ProgressStore()

    var body: some Scene {
        WindowGroup {
            AppContainer()
                .environmentObject(progressStore)
        }
    }
}

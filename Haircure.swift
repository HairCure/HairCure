import SwiftUI

@main
struct Hair12App: App {
    @State private var store = AppDataStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(store.hairInsightsStore)
                .environment(store.dietMateStore)
                .environment(store.mindEaseStore)
                .preferredColorScheme(.light)
        }
    }
}


import SwiftUI

// MARK: - Navigation Routes
enum AppRoute: Hashable {
    case auth
    case assessment
    case hairAnalysis
    case planResults
    case mainApp
}
// MARK: - Main Content Container
struct ContentView: View {
    @State private var route: AppRoute = .auth
    @State private var selectedTab = 0

    var body: some View {
        Group {
            switch route {
            case .auth:
                AuthLandingView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .assessment }
                }
            case .assessment:
                AssessmentView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .hairAnalysis }
                }
                .transition(.opacity)
            case .hairAnalysis:
                HairAnalysisView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .planResults }
                }
                .transition(.opacity)
            case .planResults:
                PlanResultsView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .mainApp }
                }
                .transition(.opacity)
            case .mainApp:
                
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab)
                        .tabItem { Label("Home", systemImage: "house.fill") }
                        .tag(0)

                    WellnessView()
                        .tabItem { Label("Wellness", systemImage: "heart.fill") }
                        .tag(1)

                    HairInsightsView()
                        .tabItem { Label("Hair Insights", systemImage: "lightbulb.fill") }
                        .tag(2)

                    ProfileView()
                        .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                        .tag(3)
                }
                .accentColor(Color.hcBrown)
                .transition(.opacity)
            }
        }
    }
}


#Preview {
    ContentView()
}


//  HairCureApp.swift
//  HairCure
//
//  @main entry point.
//
//  Navigation flow:
//    auth → assessment → hairAnalysis → planResults → mainApp
//
//
//  HairCureApp.swift
//  HairCure
//
//  Route order: auth → assessment → hairAnalysis → planResults → mainApp
//

import SwiftUI

@main
struct HairCureApp: App {
    @State private var store = AppDataStore()
    var body: some Scene {
        WindowGroup {
            ContentView().environment(store)
                .environment(store.hairInsightsStore)
               
        }
    }
}

enum AppRoute: Hashable {
    case auth
    case assessment
    case hairAnalysis
    case planResults
    case mainApp
}

struct ContentView: View {
    @State private var route: AppRoute = .auth

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
            case .hairAnalysis:
                HairAnalysisView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .planResults }
                }
            case .planResults:
                PlanResultsView {
                    withAnimation(.easeInOut(duration: 0.3)) { route = .mainApp }
                }
                .transition(.opacity)
            case .mainApp:
                MainTabView()
                    .transition(.opacity)
            }
        }
    }
}

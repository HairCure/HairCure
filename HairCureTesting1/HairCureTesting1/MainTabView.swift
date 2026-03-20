//
//  MainTabView.swift
//  HairCureTesting
//
//  Created by Abhinav Yadav on 19/03/26.
//


//
//  MainTabView.swift
//  HairCure
//
//  4-tab shell.
//  Actual tab content views will be built and swapped in
//  as each screen is completed.
//
//  Tabs:
//   0 — Home
//   1 — MindEase
//   2 — Wellness  (DietMate + Hair Insights)
//   3 — Profile
//
//
//import SwiftUI
//
//struct MainTabView: View {
//    @Environment(AppDataStore.self) private var store
//    @State private var selectedTab = 0
//
//    var body: some View {
//        TabView(selection: $selectedTab) {
//
//            // ── Tab 1: Home ──
//            PlaceholderTabView(title: "Home", icon: "house.fill")
//                .tabItem {
//                    Label("Home", systemImage: "house.fill")
//                }
//                .tag(0)
//
//            // ── Tab 2: MindEase ──
//            PlaceholderTabView(title: "MindEase", icon: "brain.head.profile")
//                .tabItem {
//                    Label("MindEase", systemImage: "brain.head.profile")
//                }
//                .tag(1)
//
//            // ── Tab 3: Wellness ──
//            PlaceholderTabView(title: "Wellness", icon: "leaf.fill")
//                .tabItem {
//                    Label("Wellness", systemImage: "leaf.fill")
//                }
//                .tag(2)
//
//            // ── Tab 4: Profile ──
//            PlaceholderTabView(title: "Profile", icon: "person.crop.circle.fill")
//                .tabItem {
//                    Label("Profile", systemImage: "person.crop.circle.fill")
//                }
//                .tag(3)
//        }
//        .accentColor(Color.hcBrown)
//    }
//}
//
//// ─────────────────────────────────────────────
//// MARK: Placeholder (replaced as each view is built)
//// ─────────────────────────────────────────────
//
//private struct PlaceholderTabView: View {
//    @Environment(AppDataStore.self) private var store
//    let title: String
//    let icon: String
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Image(systemName: icon)
//                .font(.system(size: 40))
//                .foregroundColor(Color.hcBrown)
//            Text(title)
//                .font(.system(size: 20, weight: .semibold))
//            if let plan = store.activePlan {
//                Text("Plan \(plan.planId) · Stage \(plan.stage)")
//                    .font(.system(size: 14))
//                    .foregroundColor(.secondary)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color(.systemBackground))
//    }
//}
//
////#Preview {
////    MainTabView()
////}

//
//
//  MainTabView.swift
//  HairCure
//
//  4 tabs:
//   0 — Home
//   1 — Wellness   (DietMate + MindEase sections)
//   2 — Hair Insights
//   3 — Profile
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppDataStore.self) private var store
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            PlaceholderTabView(title: "Home", icon: "house.fill", color: Color.hcBrown)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            WellnessView()
                .tabItem { Label("Wellness", systemImage: "leaf.fill") }
                .tag(1)

            PlaceholderTabView(title: "Hair Insights", icon: "lightbulb.fill", color: Color(red: 0.9, green: 0.58, blue: 0.18))
                .tabItem { Label("Insights", systemImage: "lightbulb.fill") }
                .tag(2)

            PlaceholderTabView(title: "Profile", icon: "person.crop.circle.fill", color: Color(.systemGray))
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .accentColor(Color.hcBrown)
    }
}

private struct PlaceholderTabView: View {
    @Environment(AppDataStore.self) private var store
    let title: String
    let icon:  String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 20, weight: .semibold))
            if let plan = store.activePlan {
                Text("Plan \(plan.planId) active")
                    .font(.system(size: 13)).foregroundColor(.secondary)
            }
            if title == "Wellness", let np = store.activeNutritionProfile {
                Text("TDEE \(Int(np.tdee)) kcal · Water \(Int(np.waterTargetML / 1000))L")
                    .font(.system(size: 12)).foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle(title)
    }
}

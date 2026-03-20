//
//  MainTabView.swift
//  HairCure
//
//  4 tabs: Home · Wellness · Hair Insights · Profile
//  selectedTab is @State here and passed as @Binding to HomeView
//  so HomeView can switch tabs programmatically.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppDataStore.self) private var store
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            WellnessView()
                .tabItem { Label("Wellness", systemImage: "leaf.fill") }
                .tag(1)

            HairInsightsView()
                .tabItem { Label("Insights", systemImage: "lightbulb.fill") }
                .tag(2)

            PlaceholderTab(title: "Profile", icon: "person.crop.circle.fill",
                           color: Color(.systemGray))
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(3)
        }
        .accentColor(Color.hcBrown)
    }
}

private struct PlaceholderTab: View {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

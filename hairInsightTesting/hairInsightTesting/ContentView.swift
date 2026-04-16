//
//  ContentView.swift
//  hairInsightTesting
//
//  Created by Avnish Singh on 4/16/26.
//


import SwiftUI

struct ContentView: View {
    @State private var vm  = HairInsightsViewModel()
    @State private var tab       = "insights"
    @State private var detailTip:     CareTip?     = nil
    @State private var detailRemedy:  HomeRemedy?  = nil
    @State private var detailRoutine: HairCareRoutine? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.hiBackground.ignoresSafeArea()

            // ── Tab Content ──
            Group {
                if tab == "insights" {
                    InsightsTab(vm: vm,
                                onTapTip:     { detailTip     = $0 },
                                onTapRemedy:  { detailRemedy  = $0 },
                                onTapRoutine: { detailRoutine = $0 })
                } else {
                    PlaceholderTab(label: tab.capitalized)
                }
            }
            .padding(.bottom, 82)

            // ── Tab Bar ──
            TabBarView(selected: $tab)
        }
        .task { await vm.load() }
        // Detail sheets
        .sheet(item: $detailTip)     { DetailTipView(tip: $0,     vm: vm) }
        .sheet(item: $detailRemedy)  { DetailRemedyView(remedy: $0, vm: vm) }
        .sheet(item: $detailRoutine) { DetailRoutineView(routine: $0, vm: vm) }
    }
}

// MARK: - Tab Bar
struct TabBarView: View {
    @Binding var selected: String

    private let tabs: [(id: String, label: String, icon: String)] = [
        ("home",     "Home",         "house"),
        ("wellness", "Wellness",     "heart.fill"),
        ("insights", "Hair Insights","lightbulb"),
        ("profile",  "Profile",      "person.circle"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.id) { t in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selected = t.id }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: t.icon)
                            .font(.system(size: 22, weight: .regular))
                        Text(t.label)
                            .font(.system(size: 10, weight: selected == t.id ? .semibold : .regular))
                    }
                    .foregroundColor(selected == t.id ? .hiInk : .hiMuted)
                    .padding(.vertical, 7)
                    .padding(.horizontal, selected == t.id ? 14 : 10)
                    .background(selected == t.id ? Color.hiWarm : Color.clear)
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 16)
        .frame(height: 82)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.hiBorder)
                .frame(height: 0.5)
        }
    }
}

// MARK: - Placeholder for other tabs
struct PlaceholderTab: View {
    let label: String
    var body: some View {
        VStack {
            Spacer()
            Text(label)
                .font(.title2)
                .foregroundColor(.hiMuted)
            Spacer()
        }
    }
}

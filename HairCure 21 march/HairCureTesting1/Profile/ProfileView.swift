//
//  ProfileView.swift
//  HairCureTesting1
//
//  Profile tab — matches the design:
//  • "My Progress" collapsible section with chevron
//    - Hair Progress (→ HairProgressView)
//    - Diet Mate Progress (placeholder)
//    - MindEase Progress (placeholder)
//    - Water Intake History (placeholder)
//    - Daily Sleep History (placeholder)
//  • Settings card: My Profile, Notifications, App Preferences, Help & Support, Terms & Policies
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppDataStore.self) private var store
    @State private var progressExpanded = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // ── My Progress collapsible section ──
                    progressSection

                    // ── Settings card ──
                    settingsCard

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .background(Color.hcCream.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.hcCream, for: .navigationBar)
            // NOTE: do NOT apply .toolbarBackground(.visible) here —
            // it suppresses the large title render on first appear
            // inside a TabView on some iOS 17 builds.
        }
    }

    // MARK: - My Progress Section

    private var progressSection: some View {
        VStack(spacing: 0) {

            // Header row — tap to expand / collapse
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    progressExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("My Progress")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .rotationEffect(.degrees(progressExpanded ? 0 : -90))
                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: progressExpanded)
                }
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if progressExpanded {
                // Card containing progress rows
                VStack(spacing: 0) {
                    NavigationLink(destination: HairProgressView()) {
                        ProfileRowView(title: "Hair Progress")
                    }
                    Divider().padding(.leading, 16)

                    NavigationLink(destination: DietMateProgressView()) {
                        ProfileRowView(title: "Diet Mate Progress")
                    }
                    Divider().padding(.leading, 16)

                    NavigationLink(destination: MindEaseProgressView()) {
                        ProfileRowView(title: "MindEase Progress")
                    }
                    Divider().padding(.leading, 16)

                    NavigationLink(destination: WaterIntakeHistoryView()) {
                        ProfileRowView(title: "Water Intake History")
                    }
                    Divider().padding(.leading, 16)

                    NavigationLink(destination: SleepHistoryView()) {
                        ProfileRowView(title: "Daily Sleep History")
                    }
                }
                .background(Color(UIColor.systemGray6).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Settings Card

    private var settingsCard: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: MyProfileView()) {
                ProfileRowView(title: "My Profile")
            }
            Divider().padding(.leading, 16)

            NavigationLink(destination: ProgressPlaceholderView(title: "Notifications")) {
                ProfileRowView(title: "Notifications")
            }
            Divider().padding(.leading, 16)

            NavigationLink(destination: ProgressPlaceholderView(title: "App Preferences")) {
                ProfileRowView(title: "App Preferences")
            }
            Divider().padding(.leading, 16)

            NavigationLink(destination: ProgressPlaceholderView(title: "Help & Support")) {
                ProfileRowView(title: "Help & Support")
            }
            Divider().padding(.leading, 16)

            NavigationLink(destination: ProgressPlaceholderView(title: "Terms & Policies")) {
                ProfileRowView(title: "Terms & Policies")
            }
        }
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Reusable row

private struct ProfileRowView: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

// MARK: - Placeholder for unbuilt screens

struct ProgressPlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 52))
                .foregroundColor(Color.hcBrown.opacity(0.5))
            Text(title)
                .font(.system(size: 20, weight: .semibold))
            Text("Coming soon")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environment(AppDataStore())
}

////
////  ProfileView.swift
////  HairCureTesting1
////
////  Profile tab — matches the design:
////  • "My Progress" collapsible section with chevron
////    - Hair Progress (→ HairProgressView)
////    - Diet Mate Progress (placeholder)
////    - MindEase Progress (placeholder)
////    - Water Intake History (placeholder)
////    - Daily Sleep History (placeholder)
////  • Settings card: My Profile, Notifications, App Preferences, Help & Support, Terms & Policies
////
//
//import SwiftUI
//
//struct ProfileView: View {
//    @Environment(AppDataStore.self) private var store
//    @State private var progressExpanded = true
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 16) {
//
//                    // ── My Progress collapsible section ──
//                    progressSection
//
//                    // ── Settings card ──
//                    settingsCard
//
//                    Spacer(minLength: 32)
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 8)
//            }
//            .background(Color.hcCream.ignoresSafeArea())
//            .navigationTitle("Profile")
//            .navigationBarTitleDisplayMode(.large)
//            .toolbarBackground(Color.hcCream, for: .navigationBar)
//            // NOTE: do NOT apply .toolbarBackground(.visible) here —
//            // it suppresses the large title render on first appear
//            // inside a TabView on some iOS 17 builds.
//        }
//    }
//
//    // MARK: - My Progress Section
//
//    private var progressSection: some View {
//        VStack(spacing: 0) {
//
//            // Header row — tap to expand / collapse
//            Button {
//                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
//                    progressExpanded.toggle()
//                }
//            } label: {
//                HStack {
//                    Text("My Progress")
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundColor(.primary)
//                    Spacer()
//                    Image(systemName: "chevron.down")
//                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundColor(.primary)
//                        .rotationEffect(.degrees(progressExpanded ? 0 : -90))
//                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: progressExpanded)
//                }
//                .padding(.vertical, 12)
//            }
//            .buttonStyle(.plain)
//
//            if progressExpanded {
//                // Card containing progress rows
//                VStack(spacing: 0) {
//                    NavigationLink(destination: HairProgressView()) {
//                        ProfileRowView(title: "Hair Progress")
//                    }
//                    Divider().padding(.leading, 16)
//
//                    NavigationLink(destination: DietMateProgressView()) {
//                        ProfileRowView(title: "Diet Mate Progress")
//                    }
//                    Divider().padding(.leading, 16)
//
//                    NavigationLink(destination: MindEaseProgressView()) {
//                        ProfileRowView(title: "MindEase Progress")
//                    }
//                    Divider().padding(.leading, 16)
//
//                    NavigationLink(destination: WaterIntakeHistoryView()) {
//                        ProfileRowView(title: "Water Intake History")
//                    }
//                    Divider().padding(.leading, 16)
//
//                    NavigationLink(destination: SleepHistoryView()) {
//                        ProfileRowView(title: "Daily Sleep History")
//                    }
//                }
//                .background(Color(UIColor.systemGray6).opacity(0.6))
//                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//                .transition(.opacity.combined(with: .move(edge: .top)))
//            }
//        }
//    }
//
//    // MARK: - Settings Card
//
//    private var settingsCard: some View {
//        VStack(spacing: 0) {
//            NavigationLink(destination: MyProfileView()) {
//                ProfileRowView(title: "My Profile")
//            }
//            Divider().padding(.leading, 16)
//
//            NavigationLink(destination: ProgressPlaceholderView(title: "Notifications")) {
//                ProfileRowView(title: "Notifications")
//            }
//            Divider().padding(.leading, 16)
//
//            NavigationLink(destination: ProgressPlaceholderView(title: "App Preferences")) {
//                ProfileRowView(title: "App Preferences")
//            }
//            Divider().padding(.leading, 16)
//
//            NavigationLink(destination: ProgressPlaceholderView(title: "Help & Support")) {
//                ProfileRowView(title: "Help & Support")
//            }
//            Divider().padding(.leading, 16)
//
//            NavigationLink(destination: ProgressPlaceholderView(title: "Terms & Policies")) {
//                ProfileRowView(title: "Terms & Policies")
//            }
//        }
//        .background(Color(UIColor.systemGray6).opacity(0.6))
//        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//    }
//}
//
//// MARK: - Reusable row
//
//private struct ProfileRowView: View {
//    let title: String
//
//    var body: some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 17, weight: .regular))
//                .foregroundColor(.primary)
//            Spacer()
//            Image(systemName: "chevron.right")
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(Color(UIColor.tertiaryLabel))
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 16)
//        .contentShape(Rectangle())
//    }
//}
//
//// MARK: - Placeholder for unbuilt screens
//
//struct ProgressPlaceholderView: View {
//    let title: String
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            Image(systemName: "clock.badge.questionmark")
//                .font(.system(size: 52))
//                .foregroundColor(Color.hcBrown.opacity(0.5))
//            Text(title)
//                .font(.system(size: 20, weight: .semibold))
//            Text("Coming soon")
//                .foregroundColor(.secondary)
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.hcCream.ignoresSafeArea())
//        .navigationTitle(title)
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    ProfileView()
//        .environment(AppDataStore())
//}
//
//  ProfileView.swift
//  HairCure
//
//  iOS 18+ Profile tab — Hair Progress is the hero.
//  Layout:
//    • Compact user identity header (name + plan badge)
//    • Hair Health Summary card (density ring + stage + scalp)
//    • Hair Progress CTA (full-width, prominent)
//    • Today's Stats strip (calories · water · mindful)
//    • My Progress section (collapsible)
//    • Settings section
//

//import SwiftUI
//
//struct ProfileView: View {
//    @Environment(AppDataStore.self) private var store
//    @State private var progressExpanded = true
//
//    private var user:    User?        { store.users.first(where: { $0.id == store.currentUserId }) }
//    private var plan:    UserPlan?    { store.activePlan }
//    private var report:  ScanReport? { store.latestScanReport }
//
//    var body: some View {
//        NavigationStack {
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 20) {
//
//                    // ── 1. Identity header ──
//                    identityHeader
//                        .padding(.top, 4)
//
//                    // ── 2. Hair Health hero card ──
//                    hairHealthHeroCard
//                        .padding(.horizontal, 20)
//
//                    // ── 3. Hair Progress CTA ──
//                    hairProgressCTA
//                        .padding(.horizontal, 20)
//
//                    // ── 4. Today's stats strip ──
//                    todayStatsStrip
//                        .padding(.horizontal, 20)
//
//                    // ── 5. My Progress section ──
//                    progressSection
//                        .padding(.horizontal, 20)
//
//                    // ── 6. Settings section ──
//                    settingsSection
//                        .padding(.horizontal, 20)
//
//                    Spacer(minLength: 40)
//                }
//                .padding(.bottom, 16)
//            }
//            .background(Color.hcCream.ignoresSafeArea())
//            .navigationTitle("Profile")
//            .navigationBarTitleDisplayMode(.large)
//            .toolbarBackground(Color.hcCream, for: .navigationBar)
//        }
//    }
//
//    // MARK: - 1. Identity Header
//
//    private var identityHeader: some View {
//        HStack(spacing: 14) {
//            // Avatar
//            ZStack {
//                Circle()
//                    .fill(Color.hcBrown.opacity(0.10))
//                    .frame(width: 56, height: 56)
//                Image(systemName: "person.fill")
//                    .font(.system(size: 28))
//                    .foregroundColor(Color.hcBrown.opacity(0.7))
//                    .offset(y: 3)
//            }
//
//            VStack(alignment: .leading, spacing: 3) {
//                Text(user?.name ?? "Your Profile")
//                    .font(.system(size: 18, weight: .bold))
//                    .foregroundColor(.primary)
//                Text(user?.email ?? "Tap to edit profile")
//                    .font(.system(size: 13))
//                    .foregroundColor(.secondary)
//                    .lineLimit(1)
//            }
//
//            Spacer()
//
//            // Plan badge
//            if let planId = plan?.planId {
//                NavigationLink(destination: MyProfileView()) {
//                    VStack(spacing: 2) {
//                        Text(planId.planDisplayName)
//                            .font(.system(size: 11, weight: .bold))
//                            .foregroundColor(.white)
//                            .lineLimit(1)
//                        Text("Active Plan")
//                            .font(.system(size: 9, weight: .medium))
//                            .foregroundColor(.white.opacity(0.75))
//                    }
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(Color.hcBrown)
//                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                }
//            }
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 12)
//        .background(Color.white)
//    }
//
//    // MARK: - 2. Hair Health Hero Card
//
//    private var hairHealthHeroCard: some View {
//        let density  = report?.hairDensityPercent ?? 52
//        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
//        let scalp    = report?.scalpCondition ?? plan?.scalpModifier ?? .dry
//        let progress = CGFloat(density) / 100.0
//
//        let ringColor: Color = density >= 80 ? .green
//                             : density >= 60 ? .orange
//                             : density >= 40 ? Color(red: 0.85, green: 0.45, blue: 0.1)
//                             : .red
//
//        return VStack(spacing: 0) {
//            // Card header
//            HStack {
//                Text("Hair Health")
//                    .font(.system(size: 17, weight: .bold))
//                Spacer()
//                Text("Last scan")
//                    .font(.system(size: 12))
//                    .foregroundColor(.secondary)
//            }
//            .padding(.horizontal, 18)
//            .padding(.top, 18)
//            .padding(.bottom, 14)
//
//            Divider().padding(.horizontal, 18)
//
//            HStack(spacing: 20) {
//                // Density ring
//                ZStack {
//                    Circle()
//                        .stroke(ringColor.opacity(0.15), lineWidth: 11)
//                    Circle()
//                        .trim(from: 0, to: progress)
//                        .stroke(ringColor, style: StrokeStyle(lineWidth: 11, lineCap: .round))
//                        .rotationEffect(.degrees(-90))
//                        .animation(.easeOut(duration: 0.8), value: progress)
//                    VStack(spacing: 1) {
//                        Text("\(Int(density))%")
//                            .font(.system(size: 22, weight: .bold))
//                            .foregroundColor(ringColor)
//                        Text("Density")
//                            .font(.system(size: 10, weight: .medium))
//                            .foregroundColor(.secondary)
//                    }
//                }
//                .frame(width: 88, height: 88)
//
//                // Metrics
//                VStack(alignment: .leading, spacing: 10) {
//                    metricRow(
//                        icon: "chart.bar.fill",
//                        iconColor: ringColor,
//                        label: "Stage",
//                        value: "Stage \(stage)"
//                    )
//                    Divider()
//                    metricRow(
//                        icon: "drop.fill",
//                        iconColor: Color(red: 0.15, green: 0.55, blue: 0.90),
//                        label: "Scalp",
//                        value: scalp.displayName
//                    )
//                    Divider()
//                    metricRow(
//                        icon: "person.fill",
//                        iconColor: Color.hcBrown,
//                        label: "Density Level",
//                        value: report?.hairDensityLevel.displayName ?? "Low"
//                    )
//                }
//                .frame(maxWidth: .infinity)
//            }
//            .padding(.horizontal, 18)
//            .padding(.vertical, 16)
//        }
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
//    }
//
//    private func metricRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
//        HStack(spacing: 10) {
//            Image(systemName: icon)
//                .font(.system(size: 12, weight: .semibold))
//                .foregroundColor(iconColor)
//                .frame(width: 18)
//            Text(label)
//                .font(.system(size: 13))
//                .foregroundColor(.secondary)
//            Spacer()
//            Text(value)
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(.primary)
//        }
//    }
//
//    // MARK: - 3. Hair Progress CTA
//
//    private var hairProgressCTA: some View {
//        NavigationLink(destination: HairProgressView()) {
//            HStack(spacing: 14) {
//                ZStack {
//                    Circle()
//                        .fill(Color.white.opacity(0.18))
//                        .frame(width: 46, height: 46)
//                    Image(systemName: "waveform.path.ecg")
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.white)
//                }
//
//                VStack(alignment: .leading, spacing: 3) {
//                    Text("Hair Progress")
//                        .font(.system(size: 17, weight: .bold))
//                        .foregroundColor(.white)
//                    Text("Track your recovery journey")
//                        .font(.system(size: 13))
//                        .foregroundColor(.white.opacity(0.80))
//                }
//
//                Spacer()
//
//                Image(systemName: "chevron.right")
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(.white.opacity(0.80))
//            }
//            .padding(.horizontal, 18)
//            .padding(.vertical, 16)
//            .background(
//                LinearGradient(
//                    colors: [Color.hcBrown, Color(red: 0.55, green: 0.22, blue: 0.22)],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//            .shadow(color: Color.hcBrown.opacity(0.35), radius: 10, x: 0, y: 4)
//        }
//        .buttonStyle(.plain)
//    }
//
//    // MARK: - 4. Today's Stats Strip
//
//    private var todayStatsStrip: some View {
//        HStack(spacing: 0) {
//            statCell(
//                icon: "flame.fill",
//                iconColor: .orange,
//                value: "\(Int(store.todaysTotalCalories()))",
//                label: "kcal"
//            )
//            statDivider
//            statCell(
//                icon: "drop.fill",
//                iconColor: Color(red: 0.15, green: 0.55, blue: 0.90),
//                value: String(format: "%.1f", store.todaysTotalWaterML() / 1000),
//                label: "L water"
//            )
//            statDivider
//            statCell(
//                icon: "figure.mind.and.body",
//                iconColor: Color(red: 0.55, green: 0.40, blue: 0.95),
//                value: "\(store.todaysMindfulMinutes())",
//                label: "min mind"
//            )
//        }
//        .padding(.vertical, 14)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//    }
//
//    private func statCell(icon: String, iconColor: Color, value: String, label: String) -> some View {
//        VStack(spacing: 5) {
//            Image(systemName: icon)
//                .font(.system(size: 15, weight: .semibold))
//                .foregroundColor(iconColor)
//            Text(value)
//                .font(.system(size: 18, weight: .bold, design: .rounded))
//                .foregroundColor(.primary)
//            Text(label)
//                .font(.system(size: 11))
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    private var statDivider: some View {
//        Rectangle()
//            .fill(Color(UIColor.separator).opacity(0.5))
//            .frame(width: 1, height: 40)
//    }
//
//    // MARK: - 5. My Progress Section
//
//    private var progressSection: some View {
//        VStack(spacing: 0) {
//            // Collapsible header
//            Button {
//                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
//                    progressExpanded.toggle()
//                }
//            } label: {
//                HStack {
//                    Image(systemName: "chart.bar.fill")
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundColor(Color.hcBrown)
//                    Text("My Progress")
//                        .font(.system(size: 17, weight: .bold))
//                        .foregroundColor(.primary)
//                    Spacer()
//                    Image(systemName: "chevron.down")
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundColor(.secondary)
//                        .rotationEffect(.degrees(progressExpanded ? 0 : -90))
//                        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: progressExpanded)
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 14)
//            }
//            .buttonStyle(.plain)
//
//            if progressExpanded {
//                Divider().padding(.horizontal, 16)
//
//                VStack(spacing: 0) {
//                    progressRow(title: "Hair Progress",        icon: "scissors",              iconColor: Color(red: 0.6, green: 0.3, blue: 0.1),  dest: AnyView(HairProgressView()))
//                    Divider().padding(.leading, 56)
//                    progressRow(title: "Diet Mate Progress",   icon: "fork.knife",            iconColor: Color(red: 0.2, green: 0.6, blue: 0.3),  dest: AnyView(DietMateProgressView()))
//                    Divider().padding(.leading, 56)
//                    progressRow(title: "MindEase Progress",    icon: "brain.head.profile",    iconColor: Color(red: 0.4, green: 0.3, blue: 0.8),  dest: AnyView(MindEaseProgressView()))
//                    Divider().padding(.leading, 56)
//                    progressRow(title: "Water Intake History", icon: "drop.fill",             iconColor: Color(red: 0.1, green: 0.5, blue: 0.9),  dest: AnyView(WaterIntakeHistoryView()))
//                    Divider().padding(.leading, 56)
//                    progressRow(title: "Sleep History",        icon: "moon.stars.fill",       iconColor: Color(red: 0.3, green: 0.2, blue: 0.7),  dest: AnyView(SleepHistoryView()), isLast: true)
//                }
//                .transition(.opacity.combined(with: .move(edge: .top)))
//            }
//        }
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//    }
//
//    // MARK: - 6. Settings Section
//
//    private var settingsSection: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Text("SETTINGS")
//                    .font(.system(size: 11, weight: .semibold))
//                    .foregroundColor(.secondary)
//                    .kerning(0.8)
//                Spacer()
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 14)
//            .padding(.bottom, 10)
//
//            VStack(spacing: 0) {
//                progressRow(title: "My Profile",       icon: "person.circle.fill",    iconColor: Color.hcBrown,                            dest: AnyView(MyProfileView()))
//                Divider().padding(.leading, 56)
//                progressRow(title: "Notifications",    icon: "bell.fill",             iconColor: .orange,                                  dest: AnyView(ProgressPlaceholderView(title: "Notifications")))
//                Divider().padding(.leading, 56)
//                progressRow(title: "App Preferences",  icon: "slider.horizontal.3",   iconColor: Color(red: 0.2, green: 0.55, blue: 0.9),  dest: AnyView(ProgressPlaceholderView(title: "App Preferences")))
//                Divider().padding(.leading, 56)
//                progressRow(title: "Help & Support",   icon: "questionmark.circle.fill", iconColor: Color(red: 0.0, green: 0.6, blue: 0.55), dest: AnyView(ProgressPlaceholderView(title: "Help & Support")))
//                Divider().padding(.leading, 56)
//                progressRow(title: "Terms & Policies", icon: "doc.text.fill",         iconColor: Color(red: 0.5, green: 0.5, blue: 0.54),  dest: AnyView(ProgressPlaceholderView(title: "Terms & Policies")), isLast: true)
//            }
//        }
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
//    }
//
//    // MARK: - Shared Row Builder
//
//    private func progressRow(title: String, icon: String, iconColor: Color, dest: AnyView, isLast: Bool = false) -> some View {
//        NavigationLink(destination: dest) {
//            HStack(spacing: 14) {
//                RoundedRectangle(cornerRadius: 8, style: .continuous)
//                    .fill(iconColor)
//                    .frame(width: 32, height: 32)
//                    .overlay(
//                        Image(systemName: icon)
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                    )
//                Text(title)
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.primary)
//                Spacer()
//                Image(systemName: "chevron.right")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundColor(Color(UIColor.tertiaryLabel))
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 13)
//            .contentShape(Rectangle())
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - Placeholder
//
//struct ProgressPlaceholderView: View {
//    let title: String
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//            Image(systemName: "clock.badge.questionmark")
//                .font(.system(size: 52))
//                .foregroundColor(Color.hcBrown.opacity(0.5))
//            Text(title).font(.system(size: 20, weight: .semibold))
//            Text("Coming soon").foregroundColor(.secondary)
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.hcCream.ignoresSafeArea())
//        .navigationTitle(title)
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    ProfileView().environment(AppDataStore())
//}
//
//
//  ProfileView.swift
//  HairCure
//
//  iOS 18+ Profile tab — Hero-first redesign
//  Hair Progress is the centrepiece; everything else supports it.
//
//  Design decisions:
//  • Floating glass-morphic identity card pinned at top
//  • Full-bleed gradient Hair Progress hero with live animated density ring
//  • Horizontally scrolling "Today's Metrics" strip using ScrollView(.horizontal)
//  • Collapsible My Progress uses DisclosureGroup for native feel
//  • Settings section uses grouped List style via Form-free VStack for full control
//  • All corner radii, shadows, and spacing follow iOS 18 conventions
//

import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @Environment(AppDataStore.self) private var store
    @State private var progressExpanded = false
    @State private var heroAppeared     = false

    private var user:   User?        { store.users.first(where: { $0.id == store.currentUserId }) }
    private var plan:   UserPlan?    { store.activePlan }
    private var report: ScanReport?  { store.latestScanReport }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: []) {

                    // 1 ── Identity header
                    identityHeader

                    VStack(spacing: 16) {

                        // 2 ── Hair Progress HERO (main card)
                        hairProgressHero
                            .scaleEffect(heroAppeared ? 1 : 0.94)
                            .opacity(heroAppeared ? 1 : 0)

                        // 3 ── Today metrics horizontal strip
                        todayMetricsStrip

                        // 4 ── My Progress collapsible
                        progressSection

                        // 5 ── Settings
                        settingsSection

                        Spacer(minLength: 48)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .background(backgroundLayer.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.hcCream, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.75).delay(0.1)) {
                    heroAppeared = true
                }
            }
        }
    }

    // MARK: Background

    private var backgroundLayer: some View {
        ZStack {
            Color.hcCream
            // Subtle warm radial accent behind the hero
            RadialGradient(
                colors: [Color.hcBrown.opacity(0.07), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 380
            )
        }
    }

    // MARK: 1 · Identity Header

    private var identityHeader: some View {
        HStack(spacing: 14) {
            // Avatar with subtle ring
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.hcBrown.opacity(0.18), Color.hcBrown.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(Color.hcBrown.opacity(0.22), lineWidth: 1.5))
                Image(systemName: "person.fill")
                    .font(.system(size: 25))
                    .foregroundColor(Color.hcBrown.opacity(0.75))
                    .offset(y: 2)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(user?.name ?? "Your Profile")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(user?.email ?? "Tap to edit profile")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Edit shortcut
            NavigationLink(destination: MyProfileView()) {
                Label("Edit", systemImage: "pencil")
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.hcBrown)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.hcBrown.opacity(0.10), in: Capsule())
                    .overlay(Capsule().stroke(Color.hcBrown.opacity(0.20), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.thinMaterial)
    }

    // MARK: 2 · Hair Progress Hero ─────────────────────────────────────────

    private var hairProgressHero: some View {
        let density  = report?.hairDensityPercent  ?? 52
        let stage    = report?.hairFallStage.intValue ?? plan?.stage ?? 2
        let progress = CGFloat(density) / 100.0

        let ringColor: Color = density >= 80 ? Color(red: 0.15, green: 0.72, blue: 0.35)
                             : density >= 60 ? Color(red: 0.95, green: 0.60, blue: 0.10)
                             : density >= 40 ? Color(red: 0.95, green: 0.38, blue: 0.12)
                             : Color(red: 0.90, green: 0.22, blue: 0.22)

        return VStack(spacing: 0) {

            // ── Top gradient band ──
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [
                        Color(red: 0.30, green: 0.12, blue: 0.08),
                        Color(red: 0.55, green: 0.22, blue: 0.14),
                        Color.hcBrown
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Decorative circle blur
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 180)
                    .blur(radius: 30)
                    .offset(x: 200, y: -20)

                HStack(alignment: .center, spacing: 18) {
                    // Animated density ring
                    ZStack {
                        // Track
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 10)
                        // Progress arc
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                ringColor,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .shadow(color: ringColor.opacity(0.6), radius: 6, x: 0, y: 0)
                            .animation(.spring(response: 1.1, dampingFraction: 0.7).delay(0.3), value: progress)
                        // Inner label
                        VStack(spacing: 0) {
                            Text("\(Int(density))%")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Text("density")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.65))
                                .textCase(.uppercase)
                                .kerning(0.5)
                        }
                    }
                    .frame(width: 96, height: 96)

                    // Stage + status text
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            // Stage pill
                            Text("Stage \(stage)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(red: 0.30, green: 0.12, blue: 0.08))
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.92), in: Capsule())

                            // Density level badge
                            Text(report?.hairDensityLevel.displayName ?? "Moderate")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(ringColor)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(ringColor.opacity(0.18), in: Capsule())
                                .overlay(Capsule().stroke(ringColor.opacity(0.35), lineWidth: 1))
                        }

                        Text("Hair Health Score")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(report.map { $0.scalpCondition.displayName + " Scalp" } ?? "Last scan available")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.72))
                    }

                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
            }
            .frame(minHeight: 148)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20,
                    style: .continuous
                )
            )

            // ── Bottom action strip ──
            NavigationLink(destination: HairProgressView()) {
                HStack(spacing: 12) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.hcBrown)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("View Hair Progress")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.primary)
//                        Text("Charts · Timeline · Comparison")
//                            .font(.system(size: 12))
//                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.hcBrown)
                        .symbolEffect(.pulse)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(Color.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 0,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.hcBrown.opacity(0.22), radius: 16, x: 0, y: 6)
    }

    // MARK: 3 · Today Metrics Strip

    private var todayMetricsStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                todayMetricTile(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: "\(Int(store.todaysTotalCalories()))",
                    unit: "kcal",
                    label: "Calories"
                )
                todayMetricTile(
                    icon: "drop.fill",
                    iconColor: Color(red: 0.15, green: 0.55, blue: 0.90),
                    value: String(format: "%.1f", store.todaysTotalWaterML() / 1000),
                    unit: "L",
                    label: "Hydration"
                )
                todayMetricTile(
                    icon: "brain.head.profile",
                    iconColor: Color(red: 0.50, green: 0.35, blue: 0.95),
                    value: "\(store.todaysMindfulMinutes())",
                    unit: "min",
                    label: "Mindful"
                )
                todayMetricTile(
                    icon: "moon.stars.fill",
                    iconColor: Color(red: 0.25, green: 0.20, blue: 0.60),
                    value: "7.2",
                    unit: "hrs",
                    label: "Sleep"
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
        }
        .padding(.horizontal, -16)
    }

    private func todayMetricTile(
        icon: String, iconColor: Color,
        value: String, unit: String, label: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(value)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(unit)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(width: 110)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: 4 · My Progress (Collapsible)

    private var progressSection: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                    progressExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    sectionIcon("chart.line.uptrend.xyaxis", color: Color.hcBrown)
                    Text("My Progress")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(progressExpanded ? 0 : -90))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if progressExpanded {
                Divider().padding(.leading, 16)

                VStack(spacing: 0) {
                    profileRow(title: "Diet Mate Progress",   icon: "fork.knife",            iconColor: Color(red: 0.20, green: 0.60, blue: 0.30),  dest: AnyView(DietMateProgressView()))
                    rowDivider
                    profileRow(title: "MindEase Progress",    icon: "brain.head.profile",    iconColor: Color(red: 0.45, green: 0.30, blue: 0.85),  dest: AnyView(MindEaseProgressView()))
                    rowDivider
                    profileRow(title: "Water Intake History", icon: "drop.fill",             iconColor: Color(red: 0.10, green: 0.52, blue: 0.92),  dest: AnyView(WaterIntakeHistoryView()))
                    rowDivider
                    profileRow(title: "Sleep History",        icon: "moon.stars.fill",       iconColor: Color(red: 0.28, green: 0.20, blue: 0.65),  dest: AnyView(SleepHistoryView()))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
    }

    // MARK: 5 · Settings

    private var settingsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("SETTINGS")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.secondary)
                    .kerning(1.2)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            VStack(spacing: 0) {
                profileRow(title: "My Profile",       icon: "person.crop.circle.fill", iconColor: Color.hcBrown,                              dest: AnyView(MyProfileView()))
                rowDivider
                profileRow(title: "Notifications",    icon: "bell.badge.fill",         iconColor: .orange,                                    dest: AnyView(ProgressPlaceholderView(title: "Notifications")))
                rowDivider
                profileRow(title: "App Preferences",  icon: "slider.horizontal.3",     iconColor: Color(red: 0.18, green: 0.52, blue: 0.90),  dest: AnyView(ProgressPlaceholderView(title: "App Preferences")))
                rowDivider
                profileRow(title: "Help & Support",   icon: "questionmark.bubble.fill", iconColor: Color(red: 0.0, green: 0.60, blue: 0.55),  dest: AnyView(ProgressPlaceholderView(title: "Help & Support")))
                rowDivider
                profileRow(title: "Terms & Policies", icon: "doc.plaintext.fill",       iconColor: Color(red: 0.45, green: 0.45, blue: 0.50), dest: AnyView(ProgressPlaceholderView(title: "Terms & Policies")))
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
    }

    // MARK: Shared helpers

    private var rowDivider: some View {
        Divider().padding(.leading, 58)
    }

    private func sectionIcon(_ name: String, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(color.opacity(0.12))
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color)
            )
    }

    private func profileRow(
        title: String,
        icon: String,
        iconColor: Color,
        dest: AnyView
    ) -> some View {
        NavigationLink(destination: dest) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(iconColor)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Placeholder

struct ProgressPlaceholderView: View {
    let title: String
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 52))
                .foregroundStyle(Color.hcBrown.opacity(0.45))
            Text(title).font(.system(size: 20, weight: .semibold))
            Text("Coming soon").foregroundStyle(.secondary)
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
    ProfileView().environment(AppDataStore())
}

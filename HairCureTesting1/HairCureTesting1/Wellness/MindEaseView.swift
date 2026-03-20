//
//  MindEaseView.swift
//  HairCureTesting1
//
//  MindEase main dashboard:
//  • Dynamic date header ("Today, 20 Mar 2026")
//  • Week ring calendar with purple rings tracking mindful minutes
//  • Horizontally scrollable category cards (Yoga / Meditation / Relaxing Sounds)  
//  • Today's Plan session list with Start button
//  All sections animate in via iOS 17 scrollTransition
//

import SwiftUI

// MARK: - Nav destination wrappers (distinct types avoid UUID conflicts)

struct MindEaseCategoryDest: Hashable { let id: UUID }
struct MindEaseContentDest:  Hashable { let id: UUID }

// MARK: - Main View

struct MindEaseView: View {
    @Environment(AppDataStore.self) private var store

    // Navigation state
    @State private var catDest:     MindEaseCategoryDest? = nil
    @State private var contentDest: MindEaseContentDest?  = nil

    // Dynamic week dates (Sun–Sat, current week)
    private var weekDates: [Date] {
        let cal     = Calendar.current
        let today   = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let offset  = -(weekday - 1)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: offset + $0, to: today) }
    }

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // Dynamic date
                Text("Today, \(todayDateString)")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 20)
                    .scrollTransition(.animated.threshold(.visible(0.3))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : -10)
                    }

                // Week ring calendar — purple
                weekCalendar
                    .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                        c.opacity(p.isIdentity ? 1 : 0.2).scaleEffect(p.isIdentity ? 1 : 0.94)
                    }

                // Categories
                categorySection

                // Today's Plan
                todaysPlanSection

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        // Category card tap → category list
        .navigationDestination(item: $catDest) { dest in
            if let cat = store.mindEaseCategories.first(where: { $0.id == dest.id }) {
                MindEaseCategoryListView(category: cat)
            }
        }
        // Today's Plan Start tap → player
        .navigationDestination(item: $contentDest) { dest in
            if let c = store.mindEaseCategoryContents.first(where: { $0.id == dest.id }) {
                MindEasePlayerView(content: c)
            }
        }
    }

    // MARK: - Week Calendar

    private var weekCalendar: some View {
        let cal        = Calendar.current
        let today      = cal.startOfDay(for: Date())
        let dayLetters = ["S", "M", "T", "W", "T", "F", "S"]
        let purple     = Color(red: 0.40, green: 0.30, blue: 0.85)
        let target     = Double(store.dailyMindfulTarget)

        func ringProgress(_ date: Date) -> Double {
            guard target > 0 else { return 0 }
            return min(Double(store.mindfulMinutes(for: date)) / target, 1.0)
        }

        return HStack(spacing: 0) {
            ForEach(Array(weekDates.enumerated()), id: \.offset) { _, date in
                let isToday = cal.startOfDay(for: date) == today
                let letterIdx = cal.component(.weekday, from: date) - 1
                let prog = ringProgress(date)

                VStack(spacing: 6) {
                    ZStack {
                        if isToday {
                            Circle().fill(purple).frame(width: 28, height: 28)
                        }
                        Text(dayLetters[letterIdx])
                            .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                            .foregroundColor(isToday ? .white : .secondary)
                    }
                    .frame(width: 28, height: 28)

                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            .frame(width: 36, height: 36)
                        if prog > 0 {
                            Circle()
                                .trim(from: 0, to: prog)
                                .stroke(
                                    purple,
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 36, height: 36)
                                .animation(.easeInOut(duration: 0.4), value: prog)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Categories

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Categories")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 20)
                .scrollTransition(.animated) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0).offset(x: p.isIdentity ? 0 : -20)
                }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.mindEaseCategories) { cat in
                        MindEaseCategoryCard(category: cat) {
                            catDest = MindEaseCategoryDest(id: cat.id)
                        }
                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.88)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Today's Plan

    private var todaysPlanSection: some View {
        let plans = store.todaysPlans
            .filter { $0.userId == store.currentUserId && Calendar.current.isDateInToday($0.planDate) }
            .sorted { $0.orderIndex < $1.orderIndex }

        return VStack(alignment: .leading, spacing: 14) {
            Text("Today's Plan")
                .font(.system(size: 22, weight: .bold))
                .padding(.horizontal, 20)
                .scrollTransition(.animated) { c, p in
                    c.opacity(p.isIdentity ? 1 : 0).offset(x: p.isIdentity ? 0 : -20)
                }

            VStack(spacing: 0) {
                ForEach(Array(plans.enumerated()), id: \.element.id) { idx, plan in
                    if let content = store.mindEaseCategoryContents.first(where: { $0.id == plan.contentId }) {
                        MindEasePlanRow(plan: plan, content: content) {
                            contentDest = MindEaseContentDest(id: content.id)
                        }
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 22)
                        }
                        if idx < plans.count - 1 {
                            Divider().padding(.leading, 96)
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Category Card

struct MindEaseCategoryCard: View {
    let category: MindEaseCategory
    let onTap: () -> Void

    private var gradient: LinearGradient {
        switch category.title {
        case "Yoga":
            return LinearGradient(
                colors: [Color(red: 0.15, green: 0.17, blue: 0.22), Color(red: 0.26, green: 0.20, blue: 0.16)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Meditation":
            return LinearGradient(
                colors: [Color(red: 0.25, green: 0.15, blue: 0.40), Color(red: 0.55, green: 0.32, blue: 0.12)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        default: // Relaxing Sounds
            return LinearGradient(
                colors: [Color(red: 0.08, green: 0.20, blue: 0.30), Color(red: 0.14, green: 0.30, blue: 0.22)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Layer 1: Gradient fallback (always visible)
                RoundedRectangle(cornerRadius: 16)
                    .fill(gradient)
                    .frame(width: 220, height: 145)

                // Layer 2: Real image — shows automatically when asset is added to catalog
                // The image key matches category.cardImageUrl ("yoga_card", "meditation_card", etc.)
                if let uiImage = UIImage(named: category.cardImageUrl) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 145)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Layer 3: Dark gradient overlay — keeps text readable over any image
                LinearGradient(
                    colors: [.clear, .black.opacity(0.62)],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(width: 220, height: 145)

                // Layer 4: Decorative icon (only when no real image)
                if UIImage(named: category.cardImageUrl) == nil {
                    Image(systemName: category.cardIconName)
                        .font(.system(size: 72))
                        .foregroundColor(.white.opacity(0.10))
                        .offset(x: 110, y: -16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }

                // Layer 5: Text overlay
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top) {
                        Text(category.title)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.65))
                    }
                    Text(category.categoryDescription)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.80))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
            }
            .frame(width: 220, height: 145)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Today's Plan Row

struct MindEasePlanRow: View {
    let plan: TodaysPlan
    let content: MindEaseCategoryContent
    let onStart: () -> Void

    private let purple = Color(red: 0.40, green: 0.30, blue: 0.85)

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 10)
                .fill(purple.opacity(0.12))
                .frame(width: 68, height: 68)
                .overlay(
                    Image(systemName: content.mediaType == "audio" ? "waveform" : "figure.mind.and.body")
                        .font(.system(size: 26))
                        .foregroundColor(purple)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.system(size: 16, weight: .semibold))
                HStack(spacing: 6) {
                    Text("\(content.durationMinutes) mins")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(purple)
                    Text(content.difficultyLevel.capitalized)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                }
            }

            Spacer()

            Button(action: onStart) {
                Text("Start")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 10)
                    .background(purple)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        MindEaseView()
            .environment(AppDataStore())
    }
}

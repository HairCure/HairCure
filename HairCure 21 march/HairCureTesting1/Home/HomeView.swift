//
//  HomeView.swift
//  HairCureTesting1
//
//  Created by Abhinav Yadav on 20/03/26.
//


//
//  HomeView.swift
//  HairCure
//
//  Home tab — entry point after onboarding.
//
//  Layout:
//   1. Large title header  "HairCure" + subtitle
//   2. Horizontal swipe cards (2 + page dots):
//      Card A — Hair Health Report  → View Details sheet
//      Card B — AI Hair Coach       → placeholder (connect later)
//   3. Feature cards stacked:
//      Nutrition Tracking    → Wellness tab
//      Yoga & Meditation     → Wellness tab
//      Hydration             → HydrationTrackerView sheet
//      Sleep Tracker         → SleepSetupView sheet
//

import SwiftUI

struct HomeView: View {
    // Binding to switch tabs from inside HomeView
    @Binding var selectedTab: Int

    @Environment(AppDataStore.self) private var store
    //Ai coach
    @State private var showCoach = false

    @State private var heroPage        = 0
    @State private var showPlanDetails = false
    @State private var showHydration   = false
    @State private var showSleep       = false
    @State private var isMealsExpanded = false

    private var report:    ScanReport?           { store.latestScanReport }
    private var plan:      UserPlan?             { store.activePlan }
    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hcCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        heroCardsSection
                        featureCardsSection
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("HairCure")
            .navigationBarTitleDisplayMode(.large)
        }
        // Plan Details sheet
        .sheet(isPresented: $showPlanDetails) {
            PlanResultsView(onStart: { showPlanDetails = false })
                .environment(store)
        }
        // Hydration sheet
        .sheet(isPresented: $showHydration) {
            HydrationTrackerView()
                .environment(store)
        }
        // Sleep sheet
        .sheet(isPresented: $showSleep) {
            SleepSetupView()
                .environment(store)
        }
        // Ai coach View.
        .sheet(isPresented: $showCoach) {
            CoachView(viewModel: CoachViewModel())
        }
    }

    // ─────────────────────────────────────
    // MARK: 1 — Header
    // ─────────────────────────────────────

    private var headerSection: some View {
        EmptyView()
    }

    // ─────────────────────────────────────
    // MARK: 2 — Hero Swipe Cards
    // ─────────────────────────────────────

    private var heroCardsSection: some View {
        VStack(spacing: 10) {
            TabView(selection: $heroPage) {
                aiCoachCard.tag(0)
                hairHealthCard.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)

            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { i in
                    Circle()
                        .fill(heroPage == i ? Color.hcBrown : Color(.systemGray4))
                        .frame(width: heroPage == i ? 10 : 7,
                               height: heroPage == i ? 10 : 7)
                        .animation(.easeInOut(duration: 0.2), value: heroPage)
                }
            }
        }
    }

    // Card A — Hair Health Report
    private var hairHealthCard: some View {
        let density = report?.hairDensityPercent ?? 52
        let stage   = report?.hairFallStage.intValue ?? plan?.stage ?? 2
        let _       = report?.scalpCondition ?? plan?.scalpModifier ?? .dry

        let densityColor: Color = {
            switch density {
            case 80...100: return .green
            case 60..<80:  return .orange
            case 40..<60:  return Color(red: 0.85, green: 0.45, blue: 0.1)
            default:       return .red
            }
        }()

        let stageColor: Color = stage == 1 ? .green : stage == 2 ? .orange
                              : stage == 3 ? Color(red: 0.85, green: 0.35, blue: 0.1) : .red

        let message: String = {
            switch stage {
            case 1: return "Follicle health and density metrics are looking good."
            case 2: return "Noticeable thinning — consistent care will reverse this."
            case 3: return "Significant thinning — intensive plan is active."
            default: return "Please consult a dermatologist."
            }
        }()

        return VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                // Avatar placeholder
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(.systemGray3))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Hair Density :")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                        Text("\(Int(density))%")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        Circle().fill(densityColor).frame(width: 9, height: 9)
                    }

                    HStack(spacing: 8) {
                        Text("Hairfall Stage \(stage)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        Circle().fill(stageColor).frame(width: 9, height: 9)
                    }

                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Button { showPlanDetails = true } label: {
                Text("Add Reminder")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color(red: 0.3, green: 0.18, blue: 0.15))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .buttonStyle(.plain)
        }
        .background(Color.white)
        .cornerRadius(18)
    }

    // Card B — AI Hair Coach
    private var aiCoachCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 42))
                .foregroundColor(Color.hcBrown)

            Text("Talk to Your AI Hair Coach")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Button {
                // TODO: Connect AI model here
                showCoach = true
            } label: {
                Text("Start Conversation")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color.hcBrown)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(18)
    }

    // ─────────────────────────────────────
    // MARK: 3 — Feature Cards
    // ─────────────────────────────────────

    private var featureCardsSection: some View {
        VStack(spacing: 20) {
            todaySection
            logMealsSection
            waterCardCompact
            sleepScheduleCardCompact
            dailyTipCard
        }
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.system(size: 22, weight: .bold))
                .padding(.bottom, 2)

            HStack(alignment: .top, spacing: 12) {
                // ── Calories Card (Apple Fitness style) ──
                NavigationLink(destination: CaloriesDetailView().environment(store)) {
                    fitnessCard(
                        title: "Calories",
                        icon: "flame.fill",
                        iconColor: Color.orange,
                        gradientColors: [Color(red: 0.13, green: 0.09, blue: 0.07),
                                         Color(red: 0.22, green: 0.10, blue: 0.04)],
                        current: Double(store.todaysTotalCalories()),
                        target:  Double(store.activeNutritionProfile?.tdee ?? 1500),
                        ringColor: .orange,
                        unitSuffix: "kcal"
                    )
                }
                .buttonStyle(.plain)

                // ── Mindful Minutes Card (Apple Fitness style) ──
                NavigationLink(destination: MindfulDetailView().environment(store)) {
                    fitnessCard(
                        title: "MindEase",
                        icon: "figure.mind.and.body",
                        iconColor: Color(red: 0.65, green: 0.55, blue: 1.0),
                        gradientColors: [Color(red: 0.18, green: 0.12, blue: 0.38),
                                         Color(red: 0.28, green: 0.18, blue: 0.55)],
                        current: Double(store.todaysMindfulMinutes()),
                        target:  Double(max(store.dailyMindfulTarget, 20)),
                        ringColor: Color(red: 0.40, green: 0.30, blue: 0.85),
                        unitSuffix: "min"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// Apple Fitness-style activity card with ring and gradient background.
    private func fitnessCard(
        title: String,
        icon: String,
        iconColor: Color,
        gradientColors: [Color],
        current: Double,
        target: Double,
        ringColor: Color,
        unitSuffix: String
    ) -> some View {
        let progress = min(current / max(target, 1), 1.0)
        let pct      = Int(progress * 100)

        return VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.75))
                Spacer()
            }
            .padding(.bottom, 14)

            // Ring
            ZStack {
                Circle()
                    .stroke(ringColor.opacity(0.18), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(ringColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.7), value: progress)
                VStack(spacing: 1) {
                    Text("\(pct)%")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("of goal")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
            .frame(width: 72, height: 72)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 14)

            // Stats
            VStack(alignment: .leading, spacing: 2) {
                Text(current < 1000
                     ? "\(Int(current)) \(unitSuffix)"
                     : String(format: "%.0f \(unitSuffix)", current))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("Goal \(Int(target)) \(unitSuffix)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(18)
    }

    private var logMealsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Header (tappable to expand / collapse) ──
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isMealsExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Log Meals")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isMealsExpanded ? 0 : -90))
                        .animation(.easeInOut(duration: 0.25), value: isMealsExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // ── Expandable meal rows ──
            if isMealsExpanded {
                Divider().padding(.horizontal, 16)
                VStack(spacing: 0) {
                    mealRow(title: "Breakfast", icon: "cup.and.saucer",              mealType: .breakfast)
                    Divider().padding(.leading, 56)
                    mealRow(title: "Lunch",     icon: "fork.knife",                  mealType: .lunch)
                    Divider().padding(.leading, 56)
                    mealRow(title: "Snack",     icon: "takeoutbag.and.cup.and.straw", mealType: .snack)
                    Divider().padding(.leading, 56)
                    mealRow(title: "Dinner",    icon: "moon.fill",                   mealType: .dinner)
                }
                .padding(.horizontal, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white)
        .cornerRadius(18)
        .clipped()
    }

    private func isMealLogged(_ type: MealType) -> Bool {
        store.todaysMealEntries().first(where: { $0.mealType == type })?.isLogged ?? false
    }

    private func mealRow(title: String, icon: String, mealType: MealType) -> some View {
        let logged = isMealLogged(mealType)
        return HStack(spacing: 14) {
            // Icon badge — green tint when logged
            ZStack {
                Circle()
                    .fill(logged
                          ? Color(red: 0.18, green: 0.78, blue: 0.38).opacity(0.15)
                          : Color(.systemGray6))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(logged
                                     ? Color(red: 0.18, green: 0.78, blue: 0.38)
                                     : Color(.systemGray))
            }
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            // Trailing indicator
            if logged {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color(red: 0.18, green: 0.78, blue: 0.38))
            } else {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(.systemGray3))
                }
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isMealLogged(mealType) {   // re-read at tap time
                selectedTab = 1
            }
        }
    }

    private var waterCardCompact: some View {
        let today  = store.todaysTotalWaterML()
        let target = store.activeNutritionProfile?.waterTargetML ?? 2500
        let progress = min(Double(today) / Double(max(target, 1)), 1.0)
        let todayL   = String(format: "%.1f", today  / 1000)
        let targetL  = String(format: "%.1f", target / 1000)

        return VStack(alignment: .leading, spacing: 10) {
            // ── Title row ──
            Button { showHydration = true } label: {
                HStack {
                    Text("Water Intake")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(todayL)/\(targetL)L")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .buttonStyle(.plain)

            // ── Progress bar ──
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.15, green: 0.55, blue: 0.95),
                                         Color(red: 0.0,  green: 0.75, blue: 0.95)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
                        .animation(.easeOut(duration: 0.4), value: today)
                }
            }
            .frame(height: 8)

            // ── Quick-add pills ──
            HStack(spacing: 10) {
                ForEach([(150, "+ 150 ml"), (250, "+ 250 ml"), (500, "+ 500 ml")], id: \.0) { ml, label in
                    Button {
                        store.logWaterIntake(cupSize: "custom", amountML: Float(ml))
                    } label: {
                        Text(label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color(red: 0.15, green: 0.45, blue: 0.85).opacity(0.10))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
    }

    private var sleepScheduleCardCompact: some View {
        let lastParams = store.sleepRecords.last { $0.userId == store.currentUserId }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let bedTimeStr = lastParams != nil ? formatter.string(from: lastParams!.bedTime) : "11:00 PM"
        let wakeTimeStr = lastParams != nil ? formatter.string(from: lastParams!.wakeTime) : "05:00 AM"

        return Button { showSleep = true } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Sleep Schedule")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(Color(red: 0.38, green: 0.35, blue: 0.8))
                            Text("Bedtime")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.38, green: 0.35, blue: 0.8))
                        }
                        Text(bedTimeStr)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Today")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "alarm")
                                .foregroundColor(.orange)
                            Text("Wake")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                        }
                        Text(wakeTimeStr)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Tomorrow")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }

    private var dailyTipCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Tips")
                .font(.system(size: 20, weight: .bold))
            
            HStack(spacing: 16) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.55, green: 0.40, blue: 0.30))
                Text("20 minutes walk improves blood flow to scalp .")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(16)
            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
            .cornerRadius(18)
        }
    }
}

// Reusable Ring display
struct CenterRingView: View {
    let progress: CGFloat
    let icon: String
    let iconColor: Color
    let trackColor: Color
    let text: String
    
    var body: some View {
        ZStack {
            Circle().stroke(trackColor.opacity(0.15), lineWidth: 14)
            Circle().trim(from: 0, to: progress)
                .stroke(trackColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
                Text(text)
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .frame(width: 80, height: 80)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

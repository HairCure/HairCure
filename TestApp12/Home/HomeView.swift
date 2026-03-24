
import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int

    @Environment(AppDataStore.self) private var store
    @Environment(DietmateDataStore.self) private var dietMateStore
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    @State private var showCoach       = false
    @State private var heroPage        = 0
    @State private var showPlanDetails = false
    @State private var showHydration   = false
    @State private var pushMealId: UUID? = nil   // drives push to AddMealView
    /// Meals beyond Breakfast that the user has tapped to expand
    @State private var expandedMeals: Set<MealType> = []

    private var report:    ScanReport?           { store.latestScanReport }
    private var plan:      UserPlan?             { store.activePlan }
    private var nutrition: UserNutritionProfile? { store.activeNutritionProfile }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hcCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        heroCardsSection
                        featureCardsSection
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            // Push to AddMealView when a meal row + is tapped
            .navigationDestination(item: $pushMealId) { mealId in
                AddMealView(mealEntryId: mealId)
            }
        }
        .sheet(isPresented: $showPlanDetails) {
            PlanResultsView(onStart: { showPlanDetails = false })
                .environment(store)
        }
        .sheet(isPresented: $showHydration) {
            HydrationTrackerView()
                .environment(store)
        }
        .sheet(isPresented: $showCoach) {
            CoachView(viewModel: CoachViewModel())
        }
    }

    // MARK: - Hero Swipe Cards

    private var heroCardsSection: some View {
        VStack(spacing: 10) {
            TabView(selection: $heroPage) {
                aiCoachCard.tag(0)
                hairHealthCard.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 200)

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

    // Card A — Hair Health
    private var hairHealthCard: some View {
        let density = report?.hairDensityPercent ?? 52
        let stage   = report?.hairFallStage.intValue ?? plan?.stage ?? 2

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
                ZStack {
                    Circle().fill(Color(.systemGray5)).frame(width: 80, height: 80)
                    Image(systemName: "person.fill")
                        .font(.system(size: 38)).foregroundColor(Color(.systemGray3))
                }
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Hair Density :")
                            .font(.system(size: 15)).foregroundColor(.primary)
                        Text("\(Int(density))%")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(.primary)
                        Circle().fill(densityColor).frame(width: 9, height: 9)
                    }
                    HStack(spacing: 8) {
                        Text("Hairfall Stage \(stage)")
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.primary)
                        Circle().fill(stageColor).frame(width: 9, height: 9)
                    }
                    Text(message)
                        .font(.system(size: 12)).foregroundColor(.secondary)
                        .lineSpacing(3).fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 12)

            Button { showPlanDetails = true } label: {
                Text("Add Reminder")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(Color(red: 0.3, green: 0.18, blue: 0.15)).cornerRadius(12)
                    .padding(.horizontal, 16).padding(.bottom, 16)
            }
            .buttonStyle(.plain)
        }
        .background(Color.white).cornerRadius(18)
    }

    // Card B — AI Coach
    private var aiCoachCard: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "brain.head.profile")
                .font(.system(size: 42)).foregroundColor(Color.hcBrown)
            Text("Talk to Your AI Hair Coach")
                .font(.system(size: 17, weight: .bold)).foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Button { showCoach = true } label: {
                Text("Start Conversation")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(Color.hcBrown).cornerRadius(12)
                    .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .background(Color.white).cornerRadius(18)
    }

    // MARK: - Feature Cards

    private var featureCardsSection: some View {
        VStack(spacing: 20) {
            todaySection
            logMealsSection       // ← redesigned Apple Health style
            waterCardCompact
            dailyTipCard
        }
    }

    // MARK: - Today (fitness rings)

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.system(size: 22, weight: .bold)).padding(.bottom, 2)

            HStack(alignment: .top, spacing: 12) {
                NavigationLink(destination: CaloriesDetailView().environment(store).environment(dietMateStore)) {
                    fitnessCard(
                        title: "Calories", icon: "flame.fill", iconColor: .orange,
                        gradientColors: [Color(red: 0.13, green: 0.09, blue: 0.07),
                                         Color(red: 0.22, green: 0.10, blue: 0.04)],
                        current: Double(dietMateStore.todaysTotalCalories()),
                        target:  Double(store.activeNutritionProfile?.tdee ?? 1500),
                        ringColor: .orange, unitSuffix: "kcal"
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: MindfulDetailView().environment(store).environment(mindEaseStore)) {
                    fitnessCard(
                        title: "MindEase", icon: "figure.mind.and.body",
                        iconColor: Color(red: 0.65, green: 0.55, blue: 1.0),
                        gradientColors: [Color(red: 0.18, green: 0.12, blue: 0.38),
                                         Color(red: 0.28, green: 0.18, blue: 0.55)],
                        current: Double(mindEaseStore.todaysMindfulMinutes()),
                        target:  Double(max(mindEaseStore.dailyMindfulTarget, 20)),
                        ringColor: Color(red: 0.40, green: 0.30, blue: 0.85),
                        unitSuffix: "min"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func fitnessCard(
        title: String, icon: String, iconColor: Color,
        gradientColors: [Color], current: Double, target: Double,
        ringColor: Color, unitSuffix: String
    ) -> some View {
        let progress = min(current / max(target, 1), 1.0)
        let pct      = Int(progress * 100)
        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: icon).font(.system(size: 14, weight: .bold)).foregroundColor(iconColor)
                Text(title).font(.system(size: 13, weight: .bold)).foregroundColor(.white.opacity(0.75))
                Spacer()
            }
            .padding(.bottom, 14)
            ZStack {
                Circle().stroke(ringColor.opacity(0.18), lineWidth: 10)
                Circle().trim(from: 0, to: CGFloat(progress))
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.7), value: progress)
                VStack(spacing: 1) {
                    Text("\(pct)%").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                    Text("of goal").font(.system(size: 9, weight: .medium)).foregroundColor(.white.opacity(0.55))
                }
            }
            .frame(width: 72, height: 72).frame(maxWidth: .infinity).padding(.bottom, 14)
            VStack(alignment: .leading, spacing: 2) {
                Text(current < 1000
                     ? "\(Int(current)) \(unitSuffix)"
                     : String(format: "%.0f \(unitSuffix)", current))
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Text("Goal \(Int(target)) \(unitSuffix)")
                    .font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(14).frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(18)
    }

    // MARK: - Log Meals — Apple Health "Today's Log" style
    // Breakfast is always expanded. Lunch / Snack / Dinner start collapsed (compact
    // single-line) and expand when tapped — keeping the card short on first load.

    private var logMealsSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Section header ──
            Text("Today's Log")
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider().padding(.horizontal, 16)

            let entries = dietMateStore.todaysMealEntries()
                .sorted { $0.mealType.displayOrder < $1.mealType.displayOrder }

            VStack(spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                    let isExpanded = entry.mealType == .breakfast
                                  || expandedMeals.contains(entry.mealType)
                                  || entry.caloriesConsumed > 0   // always expand logged meals

                    if isExpanded {
                        expandedMealRow(entry: entry)
                    } else {
                        compactMealRow(entry: entry)
                    }

                    if idx < entries.count - 1 {
                        Divider().padding(.leading, isExpanded ? 68 : 52)
                    }
                }
            }
            .padding(.bottom, 4)
        }
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    // ── Full-height row (Breakfast default, others when tapped) ──
    @ViewBuilder
    private func expandedMealRow(entry: MealEntry) -> some View {
        let isLogged  = entry.caloriesConsumed > 0
        let timeHint  = mealTimeHint(entry.mealType)
        let loggedStr = loggedTimeString(entry)

        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(entry.mealType.accentColor)
                    .frame(width: 44, height: 44)
                Image(systemName: mealIcon(entry.mealType))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.mealType.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Text(isLogged ? loggedStr : timeHint)
                    .font(.system(size: 13))
                    .foregroundColor(isLogged ? entry.mealType.accentColor : .secondary)
            }

            Spacer()

            if isLogged {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(entry.mealType.accentColor)
            } else {
                Button { pushMealId = entry.id } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(entry.mealType.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture { pushMealId = entry.id }
    }

    // ── Compact single-line row (Lunch / Snack / Dinner when not yet tapped) ──
    @ViewBuilder
    private func compactMealRow(entry: MealEntry) -> some View {
        HStack(spacing: 12) {
            // Small colored dot instead of full circle
            Circle()
                .fill(entry.mealType.accentColor)
                .frame(width: 10, height: 10)

            Text(entry.mealType.displayName)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)

            Spacer()

            Button { pushMealId = entry.id } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(entry.mealType.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                _ = expandedMeals.insert(entry.mealType)
            }
        }
    }

    // MARK: - Meal helpers

    private func mealIcon(_ type: MealType) -> String {
        switch type {
        case .breakfast: return "cup.and.saucer.fill"
        case .lunch:     return "fork.knife"
        case .snack:     return "takeoutbag.and.cup.and.straw.fill"
        case .dinner:    return "moon.fill"
        }
    }

    private func mealTimeHint(_ type: MealType) -> String {
        switch type {
        case .breakfast: return "Recommended · 7:00 – 9:00 AM"
        case .lunch:     return "Recommended · 12:00 – 2:00 PM"
        case .snack:     return "Recommended · 4:00 – 5:00 PM"
        case .dinner:    return "Recommended · 7:00 – 9:00 PM"
        }
    }

    private func loggedTimeString(_ entry: MealEntry) -> String {
        guard let loggedAt = entry.loggedAt else {
            return "Logged · \(Int(entry.caloriesConsumed)) kcal"
        }
        let f = DateFormatter(); f.dateFormat = "h:mm a"
        return "Logged at \(f.string(from: loggedAt)) · \(Int(entry.caloriesConsumed)) kcal"
    }

    // MARK: - Water Card

    private var waterCardCompact: some View {
        let today    = store.todaysTotalWaterML()
        let target   = store.activeNutritionProfile?.waterTargetML ?? 2500
        let progress = min(Double(today) / Double(max(target, 1)), 1.0)
        let todayL   = String(format: "%.1f", today  / 1000)
        let targetL  = String(format: "%.1f", target / 1000)

        return VStack(alignment: .leading, spacing: 10) {
            Button { showHydration = true } label: {
                HStack {
                    Text("Water Intake")
                        .font(.system(size: 17, weight: .bold)).foregroundColor(.primary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.secondary)
                    Spacer()
                    Text("\(todayL)/\(targetL)L")
                        .font(.system(size: 15, weight: .semibold)).foregroundColor(.primary)
                }
            }
            .buttonStyle(.plain)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5)).frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [Color(red: 0.15, green: 0.55, blue: 0.95),
                                     Color(red: 0.0,  green: 0.75, blue: 0.95)],
                            startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(progress), height: 8)
                        .animation(.easeOut(duration: 0.4), value: today)
                }
            }
            .frame(height: 8)

            HStack(spacing: 10) {
                ForEach([(150, "+ 150 ml"), (250, "+ 250 ml"), (500, "+ 500 ml")], id: \.0) { ml, label in
                    Button {
                        store.logWaterIntake(cupSize: "custom", amountML: Float(ml))
                    } label: {
                        Text(label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.15, green: 0.45, blue: 0.85))
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Color(red: 0.15, green: 0.45, blue: 0.85).opacity(0.10))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
        }
        .padding(16).background(Color.white).cornerRadius(18)
    }

    // MARK: - Daily Tip

    private var dailyTipCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Tips")
                .font(.system(size: 20, weight: .bold))
            HStack(spacing: 16) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 0.55, green: 0.40, blue: 0.30))
                Text("20 minutes walk improves blood flow to scalp.")
                    .font(.system(size: 15, weight: .medium)).foregroundColor(.black)
                Spacer()
            }
            .padding(16)
            .background(Color(red: 0.96, green: 0.95, blue: 0.93))
            .cornerRadius(18)
        }
    }
}

// MARK: - Reusable Ring

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
                Image(systemName: icon).font(.system(size: 18, weight: .semibold)).foregroundColor(iconColor)
                Text(text).font(.system(size: 10, weight: .bold))
            }
        }
        .frame(width: 80, height: 80).frame(maxWidth: .infinity, alignment: .center)
    }
}

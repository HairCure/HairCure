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
            .navigationBarHidden(true)
        }
        // Plan Details sheet
        .sheet(isPresented: $showPlanDetails) {
            PlanResultsView(onStart: { showPlanDetails = false }, isSheet: true)
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
        VStack(alignment: .leading, spacing: 6) {
            Text("HairCure")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            Text("Your Hair Health Report")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            Text("Here's a quick look at your hair health")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
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
        let scalp   = report?.scalpCondition ?? plan?.scalpModifier ?? .dry

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
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today")
                    .font(.system(size: 24, weight: .bold))
                Button { } label: {
                    Text("Inline Preview")
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                        .foregroundColor(.primary)
                }.padding(.leading, 8)
                Spacer()
            }
            Text(Date().formatted(.dateTime.day().month().year()))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .padding(.top, -10)
            
            HStack(spacing: 14) {
                // Calories Card
                NavigationLink(destination: CaloriesDetailView().environment(store)) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Calories Intake")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        
                        let target = store.activeNutritionProfile?.tdee ?? 1500
                        let current = store.todaysTotalCalories()
                        let progress = min(1.0, current / target)
                        
                        CenterRingView(progress: CGFloat(progress), 
                                       icon: "flame", iconColor: .orange, trackColor: .green, 
                                       text: "\(Int(current))/\(Int(target))")
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(18)
                }
                .buttonStyle(.plain)
                
                // Mindful Minutes Card
                NavigationLink(destination: MindfulDetailView().environment(store)) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Mindful Minutes")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        
                        let targetM = store.dailyMindfulTarget > 0 ? store.dailyMindfulTarget : 20
                        let currentM = store.todaysMindfulMinutes()
                        let progressM = min(1.0, Float(currentM) / Float(targetM))
                        
                        CenterRingView(progress: CGFloat(progressM), 
                                       icon: "wind", iconColor: .gray, trackColor: .blue, 
                                       text: "\(currentM)/\(targetM) min")
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(18)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var logMealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Log Meals")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(.top, 10)
            
            VStack(spacing: 0) {
                mealRow(title: "Breakfast", icon: "cup.and.saucer", isLogged: isMealLogged(.breakfast))
                Divider().padding(.leading, 40)
                mealRow(title: "Lunch", icon: "fork.knife", isLogged: isMealLogged(.lunch))
                Divider().padding(.leading, 40)
                mealRow(title: "Snack", icon: "takeoutbag.and.cup.and.straw", isLogged: isMealLogged(.snack))
                Divider().padding(.leading, 40)
                mealRow(title: "Dinner", icon: "moon.fill", isLogged: isMealLogged(.dinner))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
    }

    private func isMealLogged(_ type: MealType) -> Bool {
        store.todaysMealEntries().first(where: { $0.mealType == type })?.isLogged ?? false
    }

    private func mealRow(title: String, icon: String, isLogged: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.black)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16))
            Spacer()
            if isLogged {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(red: 0.15, green: 0.8, blue: 0.35))
                    .font(.system(size: 22))
            } else {
                Circle()
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(.vertical, 14)
        .contentShape(Rectangle())
        .onTapGesture { selectedTab = 1 } 
    }

    private var waterCardCompact: some View {
        let today  = store.todaysTotalWaterML()
        let target = store.activeNutritionProfile?.waterTargetML ?? 2500
        return Button { showHydration = true } label: {
            HStack(spacing: 16) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .frame(width: 36, height: 36)
                    .background(Color.cyan)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text("Water Intake")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("\(Int(today))/\(Int(target)) ml")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
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

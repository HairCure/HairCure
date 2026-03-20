//
//  DietMateView.swift
//  HairCureTesting1
//
//  Created by Abhinav Yadav on 20/03/26.
//


//
//  DietMateView.swift
//  HairCureTesting1
//
//  Main DietMate dashboard:
//  • Date header + 7-day ring calendar (rings fill as meals are logged)
//  • Daily Meals section — empty / logged meal cards
//

import SwiftUI

// MARK: - Colour theme per meal
extension MealType {
    var accentColor: Color {
        switch self {
        case .breakfast: return Color(red: 0.976, green: 0.451, blue: 0.086)  // orange
        case .lunch:     return Color(red: 0.937, green: 0.420, blue: 0.420)  // red-salmon
        case .snack:     return Color(red: 0.133, green: 0.773, blue: 0.369)  // green
        case .dinner:    return Color(red: 0.659, green: 0.333, blue: 0.969)  // purple
        }
    }

    var displayOrder: Int {
        switch self {
        case .breakfast: return 0
        case .lunch:     return 1
        case .snack:     return 2
        case .dinner:    return 3
        }
    }
}

// MARK: - Main View

struct DietMateView: View {
    @Environment(AppDataStore.self) private var store
    @State private var selectedDate: Date = Date()
    @State private var pushMealId: UUID? = nil      // drives NavigationLink push
    @State private var selectedFood: Food? = nil    // drives FoodDetailView sheet

    // Always show the current week (Mon-Sun, anchored to today)
    private var weekDates: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // Start from Sunday of the current week
        let weekday = cal.component(.weekday, from: today)
        let startOffset = -(weekday - 1)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: startOffset + $0, to: today) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                // ── Date Header ──
                dateHeader
                    .scrollTransition(.animated.threshold(.visible(0.3))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .offset(y: phase.isIdentity ? 0 : -12)
                    }

                // ── Ring Calendar ──
                ringCalendar
                    .scrollTransition(.animated.threshold(.visible(0.2))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.3)
                            .scaleEffect(phase.isIdentity ? 1 : 0.95)
                    }

                // ── Daily Meals ──
                Text("Daily Meals")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal, 20)
                    .scrollTransition(.animated) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .offset(x: phase.isIdentity ? 0 : -20)
                    }

                mealCards

                Spacer(minLength: 24)
            }
            .padding(.top, 8)
        }
        // iOS 17 — natural bounce based on content size
        .scrollBounceBehavior(.basedOnSize)
        .navigationDestination(item: $pushMealId) { mealId in
            AddMealView(mealEntryId: mealId)
        }
        .sheet(item: $selectedFood) { food in
            FoodDetailView(food: food)
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        let formatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "d MMM yyyy"
            return f
        }()
        return Text("Today, \(formatter.string(from: Date()))")
            .font(.system(size: 20, weight: .bold))
            .padding(.horizontal, 20)
    }

    // MARK: - Ring Calendar

    private var ringCalendar: some View {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let dayLetters = ["S", "M", "T", "W", "T", "F", "S"]

        // For each date compute ring fill = calories consumed / calorie target (capped at 1.0)
        // Falls back to 0 if no entries exist for that day.
        // Exceeded days (>100%) still show full ring in green.
        func fillProgress(for date: Date) -> Double {
            let target = store.totalCalorieTarget(for: date)
            guard target > 0 else { return 0 }
            let consumed = store.totalCalories(for: date)
            return min(Double(consumed / target), 1.0)
        }

        // Ring color: green when met, orange when fully exceeded
        func ringColor(for date: Date) -> Color {
            let target = store.totalCalorieTarget(for: date)
            guard target > 0 else { return .green }
            let consumed = store.totalCalories(for: date)
            return consumed > target * 1.10 ? Color.orange : Color.green
        }

        return HStack(spacing: 0) {
            ForEach(Array(weekDates.enumerated()), id: \.offset) { i, date in
                let isToday = cal.startOfDay(for: date) == today
                let dayIdx = cal.component(.weekday, from: date) - 1
                let progress = fillProgress(for: date)
                let color = ringColor(for: date)

                VStack(spacing: 6) {
                    // Day letter / today indicator
                    ZStack {
                        if isToday {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 28, height: 28)
                        }
                        Text(dayLetters[dayIdx])
                            .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                            .foregroundColor(isToday ? .white : .secondary)
                    }
                    .frame(width: 28, height: 28)

                    // Calorie ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            .frame(width: 32, height: 32)
                        if progress > 0 {
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    color,
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 32, height: 32)
                                .animation(.easeInOut(duration: 0.4), value: progress)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Meal Cards

    private var mealCards: some View {
        let entries = store.todaysMealEntries()
            .sorted(by: { $0.mealType.displayOrder < $1.mealType.displayOrder })

        return VStack(spacing: 14) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { idx, entry in
                Group {
                    if entry.caloriesConsumed > 0 {
                        LoggedMealCard(entry: entry, onEdit: {
                            pushMealId = entry.id
                        }, onFoodTap: { food in
                            selectedFood = food
                        })
                    } else {
                        EmptyMealCard(entry: entry) {
                            pushMealId = entry.id
                        }
                    }
                }
                // iOS 17 — each card slides up + fades in as it enters view
                .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0)
                        .scaleEffect(phase.isIdentity ? 1 : 0.96)
                        .offset(y: phase.isIdentity ? 0 : 24)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Empty Meal Card

private struct EmptyMealCard: View {
    let entry: MealEntry
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.mealType.displayName)
                .font(.system(size: 20, weight: .bold))
            Text(entry.mealType.recommendedPortionText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Button(action: onTap) {
                Text("Add \(entry.mealType.displayName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.hcBrown)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Logged Meal Card

private struct LoggedMealCard: View {
    @Environment(AppDataStore.self) private var store
    let entry: MealEntry
    let onEdit: () -> Void
    let onFoodTap: (Food) -> Void

    private var foods: [(food: Food, mealFood: MealFood)] {
        store.mealFoods
            .filter { $0.mealEntryId == entry.id }
            .compactMap { mf -> (Food, MealFood)? in
                guard let food = store.foods.first(where: { $0.id == mf.foodId }) else { return nil }
                return (food, mf)
            }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(entry.mealType.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(entry.mealType.accentColor)
                Spacer()
                Button(action: onEdit) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18))
                        .foregroundColor(entry.mealType.accentColor)
                }
            }

            // Calorie summary
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(Int(entry.caloriesConsumed))")
                    .font(.system(size: 22, weight: .bold))
                Text("/\(Int(entry.calorieTarget)) kcal")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Divider()

            // Food list
            VStack(spacing: 8) {
                ForEach(foods, id: \.mealFood.id) { pair in
                    let avgCal = (pair.food.totalCaloriesMin + pair.food.totalCaloriesMax) / 2
                    Button(action: { onFoodTap(pair.food) }) {
                        HStack {
                            Circle()
                                .fill(entry.mealType.accentColor)
                                .frame(width: 8, height: 8)
                            Text(pair.food.name)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            Spacer()
                            HStack(spacing: 4) {
                                Text("\(Int(avgCal * pair.mealFood.quantity)) kcal")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(entry.mealType.accentColor, lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    DietMateView()
        .environment(AppDataStore())
}
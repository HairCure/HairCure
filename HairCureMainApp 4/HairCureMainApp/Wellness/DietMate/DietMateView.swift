import SwiftUI

// ────────────────────────────────────────────────────────────────────────────
// MARK: - SwiftUI-only Extensions (Color — cannot live in DataStore)
// ────────────────────────────────────────────────────────────────────────────

extension MealType {
    var accentColor: Color {
        switch self {
        case .breakfast: return Color(red: 1.00, green: 0.60, blue: 0.20)
        case .lunch:     return Color(red: 0.20, green: 0.75, blue: 0.35)
        case .snack:     return Color(red: 0.60, green: 0.35, blue: 0.90)
        case .dinner:    return Color(red: 0.20, green: 0.50, blue: 0.95)
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - GoalStatusStyle  (uses Color — lives here, not in DataStore)
// ────────────────────────────────────────────────────────────────────────────

struct GoalStatusStyle {
    let color:           Color
    let icon:            String
    let backgroundColor: Color

    static func of(_ status: MealGoalStatus) -> GoalStatusStyle {
        switch status {
        case .under:
            return GoalStatusStyle(color: .red,    icon: "exclamationmark.triangle.fill",
                                   backgroundColor: Color.red.opacity(0.10))
        case .met:
            return GoalStatusStyle(color: .green,  icon: "checkmark.circle.fill",
                                   backgroundColor: Color.green.opacity(0.10))
        case .exceeded:
            return GoalStatusStyle(color: .orange, icon: "exclamationmark.circle.fill",
                                   backgroundColor: Color.orange.opacity(0.12))
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - Shared Sub-Views
// ────────────────────────────────────────────────────────────────────────────

private struct CalorieProgressBar: View {
    let consumed: Float
    let target:   Float
    let color:    Color
    let height:   CGFloat

    var body: some View {
        GeometryReader { geo in
            let fraction = min(CGFloat(consumed / max(target, 1)), 1.0)
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: height)
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geo.size.width * fraction, height: height)
                    .animation(.easeOut(duration: 0.4), value: fraction)
            }
        }
        .frame(height: height)
    }
}

// Uses food.imageURL from the model directly — no property re-declaration.
private struct FoodImageView: View {
    let food:         Food
    let tint:         Color
    let height:       CGFloat
    let width:        CGFloat?
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            if let name = food.imageURL, !name.isEmpty {
                Image(name).resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                tint.opacity(0.12)
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: height * 0.4))
                    .foregroundColor(tint.opacity(0.5))
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private struct MacroRow: View {
    let color:    Color
    let label:    String
    let fraction: Double
    let showBar:  Bool

    init(color: Color, label: String, fraction: Double = 0, showBar: Bool = true) {
        self.color = color; self.label = label
        self.fraction = fraction; self.showBar = showBar
    }

    var body: some View {
        if showBar {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(color.opacity(0.15)).frame(height: 28)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: geo.size.width * min(fraction, 1.0), height: 28)
                        .animation(.easeOut(duration: 0.5), value: fraction)
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(fraction > 0.4 ? .white : color)
                        .padding(.leading, 10)
                }
            }
            .frame(height: 28)
        } else {
            HStack(spacing: 10) {
                Circle().fill(color).frame(width: 10, height: 10)
                Text(label).font(.system(size: 15))
            }
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - DietMateView
// ────────────────────────────────────────────────────────────────────────────

struct DietMateView: View {
    @Environment(AppDataStore.self)      private var store
    @Environment(DietmateDataStore.self) private var dietMateStore

    @State private var selectedDate  = Calendar.current.startOfDay(for: Date())
    @State private var showCalendar  = false
    @State private var pushMealId:   UUID? = nil
    @State private var selectedFood: Food? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                DateHeader(selectedDate: selectedDate) { showCalendar = true }
                WeekRingStrip(selectedDate: $selectedDate, store: dietMateStore)
                SectionHeading(selectedDate: selectedDate) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedDate = Calendar.current.startOfDay(for: Date())
                    }
                }
                MealListSection(
                    selectedDate: selectedDate,
                    store:        dietMateStore,
                    onAdd:        { pushMealId = $0 },
                    onFoodTap:    { selectedFood = $0 }
                )
                Spacer(minLength: 24)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .sheet(isPresented: $showCalendar)        { CalendarSheet(selectedDate: $selectedDate, show: $showCalendar) }
        .navigationDestination(item: $pushMealId) { AddMealView(mealEntryId: $0) }
        .sheet(item: $selectedFood)               { FoodDetailView(food: $0) }
    }
}

// MARK: - DateHeader

private struct DateHeader: View {
    let selectedDate:  Date
    let onCalendarTap: () -> Void

    var body: some View {
        HStack {
            Text(selectedDate.dietMateDateTitle)
                .font(.system(size: 20, weight: .bold))
                .animation(.easeInOut(duration: 0.2), value: selectedDate)
            Spacer()
            Button(action: onCalendarTap) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.hcBrown)
                    .padding(8)
                    .background(Color.hcBrown.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - CalendarSheet

private struct CalendarSheet: View {
    @Binding var selectedDate: Date
    @Binding var show:         Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { show = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium)).padding(10)
                }
                Spacer()
                Text("Pick a Date").font(.system(size: 17, weight: .semibold))
                Spacer()
                Button("Today") {
                    withAnimation { selectedDate = Calendar.current.startOfDay(for: Date()) }
                    show = false
                }
                .padding(10)
            }
            .padding(.horizontal, 4).padding(.top, 8)

            Divider()

            DatePicker(
                "",
                selection: Binding(
                    get: { selectedDate },
                    set: { newValue in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedDate = Calendar.current.startOfDay(for: newValue)
                        }
                        show = false
                    }
                ),
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.horizontal, 16)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - WeekRingStrip

private struct WeekRingStrip: View {
    @Binding var selectedDate: Date
    let store: DietmateDataStore

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(store.currentWeekDates().enumerated()), id: \.offset) { _, date in
                WeekDayCell(date: date, selectedDate: $selectedDate, store: store)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - WeekDayCell

private struct WeekDayCell: View {
    let date:              Date
    @Binding var selectedDate: Date
    let store:             DietmateDataStore

    private let letters = ["S","M","T","W","T","F","S"]

    var body: some View {
        let cal        = Calendar.current
        let today      = cal.startOfDay(for: Date())
        let dayStart   = cal.startOfDay(for: date)
        let isToday    = dayStart == today
        let isSelected = dayStart == cal.startOfDay(for: selectedDate)
        let isFuture   = dayStart > today
        let idx        = cal.component(.weekday, from: date) - 1
        let target     = store.totalCalorieTarget(for: date)
        let consumed   = store.totalCalories(for: date)
        // Only show ring progress for days that actually have logged calories
        let progress   = (target > 0 && consumed > 0) ? min(Double(consumed / target), 1.0) : 0.0
        let ringColor: Color = consumed > target * 1.10 ? .orange : .green

        VStack(spacing: 6) {
            ZStack {
                if isToday { Circle().fill(Color.green).frame(width: 28, height: 28) }
                Text(letters[idx])
                    .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                    .foregroundColor(isToday ? .white : (isSelected ? .primary : .secondary))
            }
            .frame(width: 28, height: 28)

            ZStack {
                Circle().stroke(Color.gray.opacity(0.18), lineWidth: 4)
                if progress > 0 {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            isFuture ? Color.gray.opacity(0.3) : ringColor,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: progress)
                }
                if isSelected && !isToday {
                    Circle().fill(Color.hcBrown).frame(width: 6, height: 6)
                }
            }
            .frame(width: 32, height: 32)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            guard !isFuture else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedDate = dayStart }
        }
    }
}

// MARK: - SectionHeading

private struct SectionHeading: View {
    let selectedDate:  Date
    let onBackToToday: () -> Void

    var body: some View {
        HStack {
            Text(selectedDate.isToday
                 ? "Daily Meals"
                 : "\(selectedDate.formatted(.dateTime.day().month())) (Meals)")
                .font(.system(size: 22, weight: .bold))
                .animation(.easeInOut(duration: 0.2), value: selectedDate)
            Spacer()
            if !selectedDate.isToday {
                Button(action: onBackToToday) {
                    Label("Today", systemImage: "arrow.uturn.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.hcBrown)
                        .clipShape(Capsule())
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - MealListSection

private struct MealListSection: View {
    let selectedDate: Date
    let store:        DietmateDataStore
    let onAdd:        (UUID) -> Void
    let onFoodTap:    (Food) -> Void

    var body: some View {
        let entries = store.mealEntries(for: selectedDate)
        let isPast  = !selectedDate.isToday

        VStack(spacing: 14) {
            if entries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 44))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No meal data for this day")
                        .font(.system(size: 16)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40)
            } else {
                ForEach(entries) { entry in
                    MealCard(
                        entry:     entry,
                        isPast:    isPast,
                        onAdd:     { onAdd(entry.id) },
                        onFoodTap: onFoodTap
                    )
                    .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.96)
                            .offset(y: phase.isIdentity ? 0 : 24)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .id(selectedDate)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

// MARK: - MealCard

private struct MealCard: View {
    @Environment(DietmateDataStore.self) private var store

    let entry:     MealEntry
    let isPast:    Bool
    let onAdd:     () -> Void
    let onFoodTap: (Food) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.mealType.displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(entry.hasCalories ? entry.mealType.accentColor : .primary)
                    Text(entry.mealType.recommendedPortionText)
                        .font(.system(size: 13)).foregroundColor(.secondary)
                }
                Spacer()
                MealCardBadge(entry: entry, isPast: isPast, onEdit: onAdd)
            }

            if entry.hasCalories {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(Int(entry.caloriesConsumed))").font(.system(size: 22, weight: .bold))
                    Text("/\(Int(entry.calorieTarget)) kcal")
                        .font(.system(size: 14)).foregroundColor(.secondary)
                }

                CalorieProgressBar(consumed: entry.caloriesConsumed, target: entry.calorieTarget,
                                   color: entry.mealType.accentColor, height: 5)

                let loggedFoods = store.linkedFoods(for: entry.id)
                if !loggedFoods.isEmpty {
                    MealFoodList(foods: loggedFoods, accentColor: entry.mealType.accentColor, onTap: onFoodTap)
                }
            }

            if !isPast && !entry.hasCalories {
                Button(action: onAdd) {
                    Text("Add \(entry.mealType.displayName)")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(Color.hcBrown).cornerRadius(12)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .overlay {
            if entry.hasCalories {
                RoundedRectangle(cornerRadius: 16).stroke(entry.mealType.accentColor, lineWidth: 1.5)
            }
        }
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - MealCardBadge

private struct MealCardBadge: View {
    let entry:  MealEntry
    let isPast: Bool
    let onEdit: () -> Void

    var body: some View {
        if entry.hasCalories && !isPast {
            Button(action: onEdit) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18)).foregroundColor(entry.mealType.accentColor)
            }
        } else if entry.hasCalories {
            Text("History")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(entry.mealType.accentColor)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(entry.mealType.accentColor.opacity(0.12))
                .clipShape(Capsule())
        } else if isPast {
            Image(systemName: "minus.circle").foregroundColor(.secondary.opacity(0.4))
        }
    }
}

// MARK: - MealFoodList

private struct MealFoodList: View {
    let foods:       [(mealFood: MealFood, food: Food)]
    let accentColor: Color
    let onTap:       (Food) -> Void

    var body: some View {
        VStack(spacing: 8) {
            Divider()
            ForEach(foods, id: \.mealFood.id) { pair in
                Button { onTap(pair.food) } label: {
                    HStack {
                        Circle().fill(accentColor).frame(width: 8, height: 8)
                        Text(pair.food.name)
                            .font(.system(size: 14)).foregroundColor(.primary).lineLimit(2)
                        if pair.mealFood.quantity > 1 {
                            Text("×\(Int(pair.mealFood.quantity))")
                                .font(.system(size: 12)).foregroundColor(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Text("\(Int(pair.food.averageCalories * pair.mealFood.quantity)) kcal")
                                .font(.system(size: 14)).foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10)).foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - AddMealView
// ────────────────────────────────────────────────────────────────────────────
// NOTE: Internal (not private) so that HomeView can push it via
//       .navigationDestination(item: $pushMealId). HomeView must have
//       DietmateDataStore in its environment for this view to function.

struct AddMealView: View {
    @Environment(AppDataStore.self)      private var store
    @Environment(DietmateDataStore.self) private var dietMateStore
    @Environment(\.dismiss)             private var dismiss

    let mealEntryId: UUID

    @State private var searchText    = ""
    @State private var selectedFood: Food? = nil

    var body: some View {
        let entry     = dietMateStore.mealEntry(id: mealEntryId)
        let mealColor = entry?.mealType.accentColor ?? .hcBrown

        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium)).foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.8)).clipShape(Circle())
                }
                Spacer()
                Text(entry?.mealType.displayName ?? "Meal").font(.system(size: 20, weight: .semibold))
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
            .background(Color.hcCream)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    SearchBar(text: $searchText)

                    if let e = entry {
                        PortionSection(entry: e, mealColor: mealColor)
                        if e.caloriesConsumed > 0 {
                            WarningBanner(entry: e)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    let addedFoods = dietMateStore.linkedFoods(for: mealEntryId)
                    if !addedFoods.isEmpty {
                        AddedFoodsSection(
                            addedFoods:  addedFoods,
                            mealColor:   mealColor,
                            mealEntryId: mealEntryId,
                            store:       dietMateStore
                        )
                    }

                    SuggestedSection(
                        foods:       dietMateStore.suggestedFoods(
                                         for: entry?.mealType ?? .breakfast,
                                         searchText: searchText),
                        mealColor:   mealColor,
                        showHeading: searchText.isEmpty,
                        onAdd:       { dietMateStore.addOrIncrementFood($0, to: mealEntryId) },
                        onTap:       { selectedFood = $0 }
                    )

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20).padding(.top, 16)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(item: $selectedFood) { FoodDetailView(food: $0) }
    }
}

// MARK: - SearchBar

private struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundColor(.secondary)
            TextField("Search for a meal", text: $text).font(.system(size: 16))
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "mic.fill").foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - PortionSection

private struct PortionSection: View {
    let entry:     MealEntry
    let mealColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended portion: \(entry.mealType.calorieRangeText)")
                .font(.system(size: 15)).foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(Int(entry.caloriesConsumed))").font(.system(size: 28, weight: .bold))
                Text("/\(Int(entry.calorieTarget)) kcal").font(.system(size: 15)).foregroundColor(.secondary)
            }
            CalorieProgressBar(consumed: entry.caloriesConsumed, target: entry.calorieTarget,
                               color: mealColor, height: 8)
        }
    }
}

// MARK: - WarningBanner

private struct WarningBanner: View {
    let entry: MealEntry

    var body: some View {
        let result = RecommendationEngine.checkCalorieGoal(
            consumed: entry.caloriesConsumed, target: entry.calorieTarget)
        let style  = GoalStatusStyle.of(result.goalStatus)

        HStack(spacing: 10) {
            Image(systemName: style.icon)
                .font(.system(size: 18, weight: .semibold)).foregroundColor(style.color)
                .contentTransition(.symbolEffect(.replace))
            Text(result.message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(style.color.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(style.backgroundColor))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(style.color.opacity(0.25), lineWidth: 1))
        .animation(.easeInOut(duration: 0.3), value: entry.caloriesConsumed)
    }
}

// MARK: - AddedFoodsSection

private struct AddedFoodsSection: View {
    let addedFoods:  [(mealFood: MealFood, food: Food)]
    let mealColor:   Color
    let mealEntryId: UUID
    let store:       DietmateDataStore

    var body: some View {
        VStack(spacing: 10) {
            ForEach(addedFoods, id: \.mealFood.id) { pair in
                HStack(spacing: 12) {
                    FoodImageView(food: pair.food, tint: mealColor, height: 60, width: 60, cornerRadius: 10)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pair.food.name).font(.system(size: 15, weight: .medium)).lineLimit(2)
                        Text("\(Int(pair.food.averageCalories * pair.mealFood.quantity)) kcal")
                            .font(.system(size: 13)).foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 12) {
                        Button {
                            store.decrementOrRemoveFood(mealFoodId: pair.mealFood.id, mealEntryId: mealEntryId)
                        } label: {
                            Image(systemName: "minus.circle").font(.system(size: 22)).foregroundColor(.secondary)
                        }
                        Text("\(Int(pair.mealFood.quantity))")
                            .font(.system(size: 16, weight: .semibold)).frame(minWidth: 20)
                        Button {
                            store.incrementFood(mealFoodId: pair.mealFood.id, mealEntryId: mealEntryId)
                        } label: {
                            Image(systemName: "plus.circle").font(.system(size: 22)).foregroundColor(mealColor)
                        }
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14).fill(mealColor.opacity(0.06)))
            }
        }
    }
}

// MARK: - SuggestedSection

private struct SuggestedSection: View {
    let foods:       [Food]
    let mealColor:   Color
    let showHeading: Bool
    let onAdd:       (Food) -> Void
    let onTap:       (Food) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if showHeading {
                Text("Suggested Meals").font(.system(size: 20, weight: .bold))
            }
            if foods.isEmpty {
                Text("No meals found").foregroundColor(.secondary).font(.system(size: 15))
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(foods) { food in
                        FoodGridCard(food: food, mealColor: mealColor,
                                     onAdd: { onAdd(food) }, onTap: { onTap(food) })
                            .scrollTransition(.animated.threshold(.visible(0.05))) { content, phase in
                                content.opacity(phase.isIdentity ? 1 : 0)
                                    .scaleEffect(phase.isIdentity ? 1 : 0.88)
                            }
                    }
                }
            }
        }
    }
}

// MARK: - FoodGridCard

private struct FoodGridCard: View {
    let food:      Food
    let mealColor: Color
    let onAdd:     () -> Void
    let onTap:     () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            FoodImageView(food: food, tint: mealColor, height: 110, width: nil, cornerRadius: 12)
                .overlay(alignment: .topTrailing) {
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            .frame(width: 26, height: 26)
                            .background(Color.green).clipShape(Circle())
                    }
                    .padding(6)
                }
                .overlay(alignment: .bottomLeading) {
                    HStack(spacing: 3) {
                        Text("🔥").font(.system(size: 11))
                        Text("\(Int(food.averageCalories))")
                            .font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Color.black.opacity(0.55)).cornerRadius(8)
                    .padding(6).allowsHitTesting(false)
                }
                .contentShape(Rectangle())
                .onTapGesture { onTap() }

            Button(action: onTap) {
                Text(food.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(2).foregroundColor(.primary).padding(.horizontal, 2)
            }
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - FoodDetailView
// ────────────────────────────────────────────────────────────────────────────

private struct FoodDetailView: View {
    let food: Food
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    if let name = food.imageURL, !name.isEmpty {
                        Image(name).resizable().aspectRatio(contentMode: .fill)
                            .frame(height: 280).frame(maxWidth: .infinity).clipped()
                    } else {
                        Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 280)
                            .overlay {
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 100, weight: .light))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                    }
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color.black.opacity(0.35)).clipShape(Circle())
                    }
                    .padding(.leading, 20).padding(.top, 56)
                }

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.name).font(.system(size: 26, weight: .bold))
                        Text("Nutrition information")
                            .font(.system(size: 17, weight: .semibold)).foregroundColor(.secondary)
                        Text("Per serving (\(Int(food.servingSizeGrams))g)")
                            .font(.system(size: 14)).foregroundColor(.secondary)
                    }
                    .scrollTransition(.animated.threshold(.visible(0.2))) { content, phase in
                        content.opacity(phase.isIdentity ? 1 : 0).offset(y: phase.isIdentity ? 0 : 16)
                    }

                    NutritionCard(food: food)
                        .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                            content.opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.95)
                                .offset(y: phase.isIdentity ? 0 : 20)
                        }

                    if !food.hairNutrients.isEmpty {
                        HairNutrientsCard(nutrients: food.hairNutrients)
                            .scrollTransition(.animated.threshold(.visible(0.1))) { content, phase in
                                content.opacity(phase.isIdentity ? 1 : 0)
                                    .offset(x: phase.isIdentity ? 0 : 30)
                            }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20).padding(.top, 24)
            }
        }
        .ignoresSafeArea(edges: .top)
        .scrollBounceBehavior(.basedOnSize)
    }
}

// MARK: - NutritionCard

private struct NutritionCard: View {
    let food: Food

    private static let protein = Color(red: 0.20, green: 0.78, blue: 0.35)
    private static let fat     = Color(red: 0.98, green: 0.76, blue: 0.18)
    private static let carbs   = Color(red: 0.18, green: 0.80, blue: 0.88)

    var body: some View {
        let pr = food.macroDisplayInfo(value: food.totalProteinsInGm)
        let fr = food.macroDisplayInfo(value: food.totalFatInGm)
        let cr = food.macroDisplayInfo(value: food.totalCarbsInGm)

        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Calories :").font(.system(size: 18, weight: .bold))
                Text("\(Int(food.totalCaloriesMin)) – \(Int(food.totalCaloriesMax))")
                    .font(.system(size: 18, weight: .bold))
                Text("🔥").font(.system(size: 18))
            }

            VStack(spacing: 10) {
                MacroRow(color: Self.protein, label: pr.label, fraction: pr.fraction)
                MacroRow(color: Self.fat,     label: fr.label, fraction: fr.fraction)
                MacroRow(color: Self.carbs,   label: cr.label, fraction: cr.fraction)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                MacroRow(color: Self.protein, label: "Proteins",      showBar: false)
                MacroRow(color: Self.fat,     label: "Fats",          showBar: false)
                MacroRow(color: Self.carbs,   label: "Carbohydrates", showBar: false)
            }
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

// MARK: - HairNutrientsCard

private struct HairNutrientsCard: View {
    let nutrients: [String]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(nutrients.enumerated()), id: \.offset) { i, name in
                HStack {
                    Image(systemName: "info.circle.fill").font(.system(size: 16)).foregroundColor(.secondary)
                    Text(name).font(.system(size: 16))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.15, green: 0.76, blue: 0.37))
                        .symbolEffect(.bounce, value: i)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                if i < nutrients.count - 1 { Divider().padding(.horizontal, 16) }
            }
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    let appStore      = AppDataStore()
    let dietMateStore = DietmateDataStore(currentUserId: appStore.currentUserId)
    dietMateStore.seedAll(userId: appStore.currentUserId, nutritionProfile: nil)
    return NavigationStack {
        DietMateView()
            .environment(appStore)
            .environment(dietMateStore)
    }
}

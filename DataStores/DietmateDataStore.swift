import Foundation
import Observation


extension MealType {

    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .snack:     return "Snacks"
        case .dinner:    return "Dinner"
        }
    }

    var caloriePercent: Float {
        switch self {
        case .breakfast: return 0.25
        case .lunch:     return 0.35
        case .snack:     return 0.15
        case .dinner:    return 0.25
        }
    }

    var recommendedPortionText: String {
        switch self {
        case .breakfast: return "Recommended portion : 25% of daily consumption"
        case .lunch:     return "Recommended portion : 35% of daily consumption"
        case .snack:     return "Recommended portion : 20% of daily consumption"
        case .dinner:    return "Recommended portion : 20% of daily consumption"
        }
    }

    var calorieRangeText: String {
        switch self {
        case .breakfast: return "300 – 510 kcal"
        case .lunch:     return "500 – 713 kcal"
        case .snack:     return "200 – 306 kcal"
        case .dinner:    return "400 – 510 kcal"
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

// ────────────────────────────────────────────────────────────────────────────
// MARK: - MealGoalStatus Extensions
// ────────────────────────────────────────────────────────────────────────────

extension MealGoalStatus {
    var label: String {
        switch self {
        case .met:      return "Goal met"
        case .exceeded: return "Exceeded"
        case .under:    return "Under"
        }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - MealEntry Extensions
// ────────────────────────────────────────────────────────────────────────────

extension MealEntry {
    var hasCalories: Bool { caloriesConsumed > 0 }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - Food Extensions
// ────────────────────────────────────────────────────────────────────────────

extension Food {

    /// Mid-point calorie value.
    var averageCalories: Float {
        (totalCaloriesMin + totalCaloriesMax) / 2
    }

    /// Ordered list of hair-nutrient labels this food provides.
    var hairNutrients: [String] {
        var list: [String] = []
        if isBiotinRich   { list.append("Biotin") }
        if isZincRich     { list.append("Zinc") }
        if isIronRich     { list.append("Iron") }
        if isOmega3Rich   { list.append("Omega-3") }
        if isVitaminARich { list.append("Vitamin A") }
        return list
    }

    /// Largest macro gram value across protein/fat/carbs — used as the bar chart denominator.
    var macroMaxValue: Float {
        max(totalProteinsInGm, totalFatInGm, totalCarbsInGm, 1)
    }

    /// Returns a display label ("85 – 115 g") and a 0…1 bar fraction for any macro value.
    func macroDisplayInfo(value: Float) -> (label: String, fraction: Double) {
        let label    = "\(Int((value * 0.85).rounded())) – \(Int((value * 1.15).rounded())) g"
        let fraction = Double(value / macroMaxValue)
        return (label, fraction)
    }
}

// ────────────────────────────────────────────────────────────────────────────
// MARK: - Date Extensions
// ────────────────────────────────────────────────────────────────────────────

extension Date {

    /// True when this date falls on today.
    var isToday: Bool { Calendar.current.isDateInToday(self) }

    /// Header title used in the DietMate date bar ("Today, 31 Mar 2026", etc.).
    var dietMateDateTitle: String {
        let cal = Calendar.current
        let str = formatted(.dateTime.day().month().year())
        if cal.isDateInToday(self)     { return "Today, \(str)" }
        if cal.isDateInYesterday(self) { return "Yesterday, \(str)" }
        return formatted(.dateTime.weekday(.wide).day().month().year())
    }
}

// MARK: - DietmateDataStore

@Observable
class DietmateDataStore {

    // MARK: - Properties

    var foods:       [Food]      = []
    var mealEntries: [MealEntry] = []
    var mealFoods:   [MealFood]  = []

    var currentUserId: UUID
    weak var parentStore: AppDataStore?

    // MARK: - Init

    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
    }

    func seedAll(userId: UUID, nutritionProfile: UserNutritionProfile?) {
        foodItems()
        seedTodaysMealEntries(userId: userId, nutritionProfile: nutritionProfile)
    }

    // ─────────────────────────────────────────────
    // MARK: - Seed Foods
    // ─────────────────────────────────────────────

    func foodItems() {
        foods = [
            Food(id: UUID(), externalFoodId: nil, name: "Paneer Stuffed Paratha", imageURL: "paneerParantha", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 200, apiSource: "mock", totalCaloriesMin: 300, totalCaloriesMax: 330, totalProteinsInGm: 12, totalCarbsInGm: 38, totalFatInGm: 12, totalVitaminsInMg: 4.5, isBiotinRich: true, isZincRich: false, isIronRich: false, isOmega3Rich: false, isVitaminARich: false, suitableMealTypes: [.breakfast, .dinner], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Vegetable Oats Upma", imageURL: "oats", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 180, apiSource: "mock", totalCaloriesMin: 260, totalCaloriesMax: 290, totalProteinsInGm: 9, totalCarbsInGm: 42, totalFatInGm: 6, totalVitaminsInMg: 6.2, isBiotinRich: true, isZincRich: true, isIronRich: true, isOmega3Rich: false, isVitaminARich: false, suitableMealTypes: [.breakfast], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Curd with Flaxseeds & Fruits", imageURL: "flaxSeeds", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 200, apiSource: "mock", totalCaloriesMin: 280, totalCaloriesMax: 310, totalProteinsInGm: 10, totalCarbsInGm: 35, totalFatInGm: 9, totalVitaminsInMg: 5.8, isBiotinRich: true, isZincRich: true, isIronRich: false, isOmega3Rich: true, isVitaminARich: false, suitableMealTypes: [.breakfast, .snack], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Methi Thepla", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 150, apiSource: "mock", totalCaloriesMin: 250, totalCaloriesMax: 270, totalProteinsInGm: 7, totalCarbsInGm: 36, totalFatInGm: 8, totalVitaminsInMg: 9.2, isBiotinRich: false, isZincRich: false, isIronRich: true, isOmega3Rich: false, isVitaminARich: true, suitableMealTypes: [.breakfast, .lunch], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Moong Dal Chilla", imageURL: "moong", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 150, apiSource: "mock", totalCaloriesMin: 220, totalCaloriesMax: 250, totalProteinsInGm: 12, totalCarbsInGm: 30, totalFatInGm: 5, totalVitaminsInMg: 7.4, isBiotinRich: true, isZincRich: true, isIronRich: true, isOmega3Rich: false, isVitaminARich: false, suitableMealTypes: [.breakfast, .lunch], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Spinach Dal (Palak Dal)", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 250, apiSource: "mock", totalCaloriesMin: 280, totalCaloriesMax: 310, totalProteinsInGm: 14, totalCarbsInGm: 38, totalFatInGm: 5, totalVitaminsInMg: 12.0, isBiotinRich: false, isZincRich: true, isIronRich: true, isOmega3Rich: false, isVitaminARich: true, suitableMealTypes: [.lunch, .dinner], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Brown Rice & Lentils", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 280, apiSource: "mock", totalCaloriesMin: 320, totalCaloriesMax: 360, totalProteinsInGm: 14, totalCarbsInGm: 58, totalFatInGm: 3, totalVitaminsInMg: 8.5, isBiotinRich: false, isZincRich: true, isIronRich: true, isOmega3Rich: false, isVitaminARich: false, suitableMealTypes: [.lunch, .dinner], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Egg Bhurji", imageURL: "", foodType: "non-vegetarian", isVegetarian: false, isCustom: false, createdByUserId: nil, servingSizeGrams: 150, apiSource: "mock", totalCaloriesMin: 280, totalCaloriesMax: 310, totalProteinsInGm: 18, totalCarbsInGm: 6, totalFatInGm: 18, totalVitaminsInMg: 5.2, isBiotinRich: true, isZincRich: true, isIronRich: true, isOmega3Rich: true, isVitaminARich: true, suitableMealTypes: [.breakfast, .lunch], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Grilled Chicken Salad", imageURL: "", foodType: "non-vegetarian", isVegetarian: false, isCustom: false, createdByUserId: nil, servingSizeGrams: 200, apiSource: "mock", totalCaloriesMin: 290, totalCaloriesMax: 320, totalProteinsInGm: 28, totalCarbsInGm: 12, totalFatInGm: 10, totalVitaminsInMg: 4.8, isBiotinRich: false, isZincRich: true, isIronRich: true, isOmega3Rich: true, isVitaminARich: false, suitableMealTypes: [.lunch, .dinner], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Walnut & Banana Smoothie", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 300, apiSource: "mock", totalCaloriesMin: 300, totalCaloriesMax: 330, totalProteinsInGm: 8, totalCarbsInGm: 42, totalFatInGm: 14, totalVitaminsInMg: 3.5, isBiotinRich: true, isZincRich: false, isIronRich: false, isOmega3Rich: true, isVitaminARich: false, suitableMealTypes: [.breakfast, .snack], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Pumpkin Seeds & Fruit Bowl", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 100, apiSource: "mock", totalCaloriesMin: 220, totalCaloriesMax: 250, totalProteinsInGm: 8, totalCarbsInGm: 30, totalFatInGm: 10, totalVitaminsInMg: 6.0, isBiotinRich: true, isZincRich: true, isIronRich: false, isOmega3Rich: true, isVitaminARich: true, suitableMealTypes: [.snack], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Almonds & Dates", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 60, apiSource: "mock", totalCaloriesMin: 200, totalCaloriesMax: 230, totalProteinsInGm: 6, totalCarbsInGm: 22, totalFatInGm: 12, totalVitaminsInMg: 4.2, isBiotinRich: true, isZincRich: false, isIronRich: false, isOmega3Rich: false, isVitaminARich: false, suitableMealTypes: [.snack], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Whole Wheat Roti + Sabzi", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 250, apiSource: "mock", totalCaloriesMin: 350, totalCaloriesMax: 390, totalProteinsInGm: 12, totalCarbsInGm: 55, totalFatInGm: 8, totalVitaminsInMg: 10.5, isBiotinRich: false, isZincRich: false, isIronRich: true, isOmega3Rich: false, isVitaminARich: true, suitableMealTypes: [.lunch, .dinner], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Paneer Tikka", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 200, apiSource: "mock", totalCaloriesMin: 320, totalCaloriesMax: 360, totalProteinsInGm: 20, totalCarbsInGm: 12, totalFatInGm: 20, totalVitaminsInMg: 3.8, isBiotinRich: false, isZincRich: true, isIronRich: false, isOmega3Rich: false, isVitaminARich: true, suitableMealTypes: [.dinner], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Fish Curry (Rohu)", imageURL: "", foodType: "non-vegetarian", isVegetarian: false, isCustom: false, createdByUserId: nil, servingSizeGrams: 250, apiSource: "mock", totalCaloriesMin: 300, totalCaloriesMax: 340, totalProteinsInGm: 26, totalCarbsInGm: 14, totalFatInGm: 12, totalVitaminsInMg: 5.6, isBiotinRich: true, isZincRich: true, isIronRich: true, isOmega3Rich: true, isVitaminARich: true, suitableMealTypes: [.lunch, .dinner], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Oatmeal with Almonds", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 200, apiSource: "mock", totalCaloriesMin: 280, totalCaloriesMax: 310, totalProteinsInGm: 10, totalCarbsInGm: 44, totalFatInGm: 9, totalVitaminsInMg: 4.0, isBiotinRich: true, isZincRich: false, isIronRich: true, isOmega3Rich: false, isVitaminARich: false, suitableMealTypes: [.breakfast], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Greek Yogurt", imageURL: "", foodType: "vegetarian", isVegetarian: true, isCustom: false, createdByUserId: nil, servingSizeGrams: 150, apiSource: "mock", totalCaloriesMin: 150, totalCaloriesMax: 180, totalProteinsInGm: 15, totalCarbsInGm: 12, totalFatInGm: 4, totalVitaminsInMg: 2.5, isBiotinRich: true, isZincRich: false, isIronRich: false, isOmega3Rich: false, isVitaminARich: false, suitableMealTypes: [.breakfast, .snack], createdAt: Date()),
            Food(id: UUID(), externalFoodId: nil, name: "Chicken Soup", imageURL: "", foodType: "non-vegetarian", isVegetarian: false, isCustom: false, createdByUserId: nil, servingSizeGrams: 350, apiSource: "mock", totalCaloriesMin: 200, totalCaloriesMax: 240, totalProteinsInGm: 22, totalCarbsInGm: 10, totalFatInGm: 7, totalVitaminsInMg: 3.2, isBiotinRich: false, isZincRich: true, isIronRich: true, isOmega3Rich: false, isVitaminARich: false, suitableMealTypes: [.lunch, .dinner], createdAt: Date()),
        ]
    }

    
    func seedTodaysMealEntries(userId: UUID, nutritionProfile: UserNutritionProfile?) {
        guard let np = nutritionProfile else { return }
        for (mealType, budget) in [(MealType.breakfast, np.breakfastCalTarget),
                                   (.lunch,             np.lunchCalTarget),
                                   (.snack,             np.snackCalTarget),
                                   (.dinner,            np.dinnerCalTarget)] {
            mealEntries.append(MealEntry(
                id: UUID(), userId: userId, mealType: mealType,
                date: Date(), isLogged: false, loggedAt: nil,
                calorieTarget: budget, caloriesConsumed: 0,
                proteinConsumed: 0, carbsConsumed: 0, fatConsumed: 0,
                goalStatus: .under
            ))
        }
    }

    

    // ─────────────────────────────────────────────
    // MARK: - Query Helpers
    // ─────────────────────────────────────────────

    func todaysMealEntries() -> [MealEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return mealEntries.filter {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == today
        }.sorted { $0.mealType.displayOrder < $1.mealType.displayOrder }
    }

    func mealEntries(for date: Date) -> [MealEntry] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mealEntries.filter {
            $0.userId == currentUserId &&
            Calendar.current.startOfDay(for: $0.date) == dayStart
        }.sorted { $0.mealType.displayOrder < $1.mealType.displayOrder }
    }

    func mealEntry(id: UUID) -> MealEntry? {
        mealEntries.first { $0.id == id }
    }

    func totalCalories(for date: Date) -> Float {
        mealEntries(for: date).reduce(0) { $0 + $1.caloriesConsumed }
    }

    func totalCalorieTarget(for date: Date) -> Float {
        mealEntries(for: date).reduce(0) { $0 + $1.calorieTarget }
    }

    func weeklyCalorieTotals() -> [(day: String, consumed: Float, target: Float)] {
        let cal = Calendar.current
        let format = DateFormatter()
        format.dateFormat = "EEE"
        let today = Date()
        let weekday = cal.component(.weekday, from: today)
        let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1),
                                   to: cal.startOfDay(for: today))!
        return (0..<7).map { offset in
            let date = cal.date(byAdding: .day, value: offset, to: startOfWeek)!
            return (day: format.string(from: date),
                    consumed: totalCalories(for: date),
                    target:   totalCalorieTarget(for: date))
        }
    }

    /// The 7 dates of the current week starting Sunday .
    func currentWeekDates() -> [Date] {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = -(cal.component(.weekday, from: today) - 1)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: start + $0, to: today) }
    }

    func foods(for mealType: MealType, vegetarianOnly: Bool = false) -> [Food] {
        foods
            .filter { $0.suitableMealTypes.contains(mealType) && (!vegetarianOnly || $0.isVegetarian) }
            .sorted {
                let a = ($0.isBiotinRich ? 1 : 0) + ($0.isZincRich ? 1 : 0) + ($0.isIronRich ? 1 : 0)
                let b = ($1.isBiotinRich ? 1 : 0) + ($1.isZincRich ? 1 : 0) + ($1.isIronRich ? 1 : 0)
                return a > b
            }
    }

    /// Foods for a meal entry by id — used in both MealCard and AddMealView.
    func linkedFoods(for mealEntryId: UUID) -> [(mealFood: MealFood, food: Food)] {
        mealFoods
            .filter { $0.mealEntryId == mealEntryId }
            .compactMap { mf in
                guard let food = foods.first(where: { $0.id == mf.foodId }) else { return nil }
                return (mealFood: mf, food: food)
            }
    }

    /// Filtered suggested foods for AddMealView — avoids any filtering logic living in a View.
    func suggestedFoods(for mealType: MealType, searchText: String) -> [Food] {
        let all = foods(for: mealType)
        return searchText.isEmpty
            ? all
            : all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func foodsInMealEntry(mealType: MealType) -> [(mealFood: MealFood, food: Food)] {
        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else { return [] }
        return linkedFoods(for: entry.id)
    }

    func todaysTotalMacros() -> (protein: Double, carbs: Double, fat: Double) {
        let entries = todaysMealEntries()
        return (
            protein: Double(entries.reduce(0) { $0 + $1.proteinConsumed }),
            carbs:   Double(entries.reduce(0) { $0 + $1.carbsConsumed  }),
            fat:     Double(entries.reduce(0) { $0 + $1.fatConsumed    })
        )
    }

    func todaysTotalCalories() -> Float {
        todaysMealEntries().reduce(0) { $0 + $1.caloriesConsumed }
    }

    func todaysLoggedMealCount() -> Int {
        todaysMealEntries().filter { $0.isLogged }.count
    }

    func mealGoalMessage(for entry: MealEntry) -> String {
        switch entry.goalStatus {
        case .met:
            return "Goal met! Great choices for your hair health."
        case .exceeded:
            return "\(Int(entry.caloriesConsumed - entry.calorieTarget)) kcal over target — logged anyway."
        case .under:
            return "Add \(Int(entry.calorieTarget * 0.70 - entry.caloriesConsumed)) more kcal before logging."
        }
    }

    func rankedFoods(for mealType: MealType, plan: UserPlan?, vegetarianOnly: Bool = false) -> [Food] {
        guard let plan = plan else {
            return foods(for: mealType, vegetarianOnly: vegetarianOnly)
        }
        return RecommendationEngine.rankedFoods(
            from: foods, for: mealType, plan: plan,
            vegetarianOnly: vegetarianOnly
        )
    }

    // MARK: - Meal Slot Summary

    struct MealSlotSummary {
        let mealType: MealType
        let calorieTarget: Float
        let caloriesConsumed: Float
        let progress: Float
        let overAmount: Float
        let goalStatus: MealGoalStatus
        let isLogged: Bool
        let canLog: Bool
        let statusMessage: String
        let foods: [(mealFood: MealFood, food: Food)]
    }

    func mealSlotSummary(for mealType: MealType) -> MealSlotSummary {
        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else {
            return MealSlotSummary(
                mealType: mealType, calorieTarget: 0, caloriesConsumed: 0,
                progress: 0, overAmount: 0, goalStatus: .under, isLogged: false,
                canLog: false, statusMessage: "No data", foods: []
            )
        }
        let check    = RecommendationEngine.checkCalorieGoal(
            consumed: entry.caloriesConsumed, target: entry.calorieTarget)
        let progress = min(entry.caloriesConsumed / max(entry.calorieTarget, 1), 1.0)
        let over     = max(0, entry.caloriesConsumed - entry.calorieTarget)
        return MealSlotSummary(
            mealType: mealType,
            calorieTarget: entry.calorieTarget,
            caloriesConsumed: entry.caloriesConsumed,
            progress: progress,
            overAmount: over,
            goalStatus: check.goalStatus,
            isLogged: entry.isLogged,
            canLog: check.canLog,
            statusMessage: check.message,
            foods: foodsInMealEntry(mealType: mealType)
        )
    }

    // ─────────────────────────────────────────────
    // MARK: - Meal Entry Total Recalculation
    // ─────────────────────────────────────────────

    func updateMealEntryTotals(mealEntryId: UUID) {
        guard let index = mealEntries.firstIndex(where: { $0.id == mealEntryId }) else { return }
        let linked = mealFoods.filter { $0.mealEntryId == mealEntryId }

        var calories: Float = 0
        var protein:  Float = 0
        var carbs:    Float = 0
        var fat:      Float = 0

        for mf in linked {
            if let food = foods.first(where: { $0.id == mf.foodId }) {
                calories += food.averageCalories   * mf.quantity
                protein  += food.totalProteinsInGm * mf.quantity
                carbs    += food.totalCarbsInGm    * mf.quantity
                fat      += food.totalFatInGm      * mf.quantity
            }
        }

        mealEntries[index].caloriesConsumed = calories
        mealEntries[index].proteinConsumed  = protein
        mealEntries[index].carbsConsumed    = carbs
        mealEntries[index].fatConsumed      = fat

        let target = mealEntries[index].calorieTarget
        mealEntries[index].goalStatus = calories < target * 0.70 ? .under
                                      : calories <= target * 1.10 ? .met : .exceeded
    }

    // MARK: - Food CRUD

    func addFood(_ food: Food, to mealEntryId: UUID, quantity: Float = 1.0) {
        mealFoods.append(MealFood(id: UUID(), mealEntryId: mealEntryId,
                                  foodId: food.id, quantity: quantity))
        updateMealEntryTotals(mealEntryId: mealEntryId)
    }

    func removeFood(mealFoodId: UUID, from mealEntryId: UUID) {
        mealFoods.removeAll { $0.id == mealFoodId }
        updateMealEntryTotals(mealEntryId: mealEntryId)
    }

    func incrementFood(mealFoodId: UUID, mealEntryId: UUID) {
        guard let idx = mealFoods.firstIndex(where: { $0.id == mealFoodId }) else { return }
        mealFoods[idx].quantity += 1
        updateMealEntryTotals(mealEntryId: mealEntryId)
    }

    func decrementOrRemoveFood(mealFoodId: UUID, mealEntryId: UUID) {
        guard let idx = mealFoods.firstIndex(where: { $0.id == mealFoodId }) else { return }
        if mealFoods[idx].quantity > 1 {
            mealFoods[idx].quantity -= 1
            updateMealEntryTotals(mealEntryId: mealEntryId)
        } else {
            removeFood(mealFoodId: mealFoodId, from: mealEntryId)
        }
    }

    func addOrIncrementFood(_ food: Food, to mealEntryId: UUID) {
        if let existing = mealFoods.first(where: {
            $0.mealEntryId == mealEntryId && $0.foodId == food.id
        }) {
            incrementFood(mealFoodId: existing.id, mealEntryId: mealEntryId)
        } else {
            addFood(food, to: mealEntryId)
        }
    }

    // MARK: - Meal Logging Actions

    func addFoodToMeal(food: Food, mealType: MealType, quantity: Float = 1.0) -> ActionResult {
        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else {
            return .blocked(reason: "No meal slot found for \(mealType.displayName) today.")
        }
        if entry.isLogged {
            return .blocked(reason: "\(mealType.displayName) is already logged. Tap edit to make changes.")
        }
        mealFoods.append(MealFood(id: UUID(), mealEntryId: entry.id,
                                  foodId: food.id, quantity: quantity))
        updateMealEntryTotals(mealEntryId: entry.id)
        guard let updated = mealEntries.first(where: { $0.id == entry.id }) else {
            return .success(message: "\(food.name) added.")
        }
        let check = RecommendationEngine.checkCalorieGoal(
            consumed: updated.caloriesConsumed, target: updated.calorieTarget)
        switch check.goalStatus {
        case .met:
            return .success(message: "\(food.name) added! \(mealType.displayName) goal met.")
        case .exceeded:
            let over = Int(updated.caloriesConsumed - updated.calorieTarget)
            return .warning(message: "\(food.name) added. You're \(over) kcal over your \(mealType.displayName) target.")
        case .under:
            let remaining = Int(updated.calorieTarget - updated.caloriesConsumed)
            return .success(message: "\(food.name) added. \(remaining) kcal remaining for \(mealType.displayName).")
        }
    }

    func removeFoodFromMeal(mealFoodId: UUID, mealType: MealType) -> ActionResult {
        guard let entry = mealEntries.first(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else { return .noChange }
        if entry.isLogged {
            return .blocked(reason: "Unlog \(mealType.displayName) first to edit foods.")
        }
        guard mealFoods.contains(where: { $0.id == mealFoodId }) else {
            return .blocked(reason: "Food not found.")
        }
        mealFoods.removeAll { $0.id == mealFoodId }
        updateMealEntryTotals(mealEntryId: entry.id)
        return .success(message: "Food removed from \(mealType.displayName).")
    }

    func logMealEntry(mealType: MealType) -> ActionResult {
        guard let index = mealEntries.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else {
            return .blocked(reason: "No \(mealType.displayName) entry found for today.")
        }
        let entry = mealEntries[index]
        if entry.isLogged {
            return .warning(message: "\(mealType.displayName) is already logged.")
        }
        let check = RecommendationEngine.checkCalorieGoal(
            consumed: entry.caloriesConsumed, target: entry.calorieTarget)
        if !check.canLog {
            return .blocked(reason: check.message)
        }
        mealEntries[index].isLogged   = true
        mealEntries[index].loggedAt   = Date()
        mealEntries[index].goalStatus = check.goalStatus
        return check.goalStatus == .exceeded
            ? .warning(message: check.message)
            : .success(message: check.message)
    }

    func unlogMealEntry(mealType: MealType) -> ActionResult {
        guard let idx = mealEntries.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.mealType == mealType &&
            Calendar.current.isDateInToday($0.date)
        }) else { return .noChange }
        mealEntries[idx].isLogged = false
        mealEntries[idx].loggedAt = nil
        return .success(message: "\(mealType.displayName) unlocked for editing.")
    }
}

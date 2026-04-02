//
//  MindEaseDataStore.swift
import Foundation
import Observation

// MARK: - MindEaseDataStore

@Observable
final class MindEaseDataStore {

    // MARK: - State

    var mindEaseCategories:       [MindEaseCategory]        = []
    var mindEaseCategoryContents: [MindEaseCategoryContent] = []
    var mindfulSessions:          [MindfulSession]          = []
    var todaysPlans:              [TodaysPlan]              = []
    var sessionStartTimes:        [UUID: Date]              = [:]

    var currentUserId: UUID
    weak var parentStore: AppDataStore?

    // MARK: - Init

    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        addCategories()
        addContent()
    }

    // MARK: - Seed Data

    private func addCategories() {
        mindEaseCategories = [
            MindEaseCategory(
                id: UUID(),
                title: "Yoga",
                categoryDescription: "Gentle poses to strengthen body and reduce hair fall",
                cardImageUrl: "yoga",
                cardIconName: "figure.yoga"
            ),
            MindEaseCategory(
                id: UUID(),
                title: "Meditation",
                categoryDescription: "Mindful practices to reduce cortisol and support hair health",
                cardImageUrl: "meditation",
                cardIconName: "brain.head.profile"
            ),
            MindEaseCategory(
                id: UUID(),
                title: "Relaxing Sounds",
                categoryDescription: "Soothing sounds to help you relax and unwind",
                cardImageUrl: "relaxingSounds",
                cardIconName: "waveform"
            ),
        ]
    }

    private func addContent() {
        let yogaId       = mindEaseCategories.first { $0.title == "Yoga" }?.id            ?? UUID()
        let meditationId = mindEaseCategories.first { $0.title == "Meditation" }?.id      ?? UUID()
        let soundsId     = mindEaseCategories.first { $0.title == "Relaxing Sounds" }?.id ?? UUID()

        mindEaseCategoryContents = [
            MindEaseCategoryContent(
                id: UUID(), categoryId: yogaId,
                title: "Uttanasana", caption: "Forward Fold",
                mediaURL: "yoga_1.mp4", mediaType: .video,
                durationSeconds: 90, difficultyLevel: "beginner",
                imageurl: "uttanasana"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: yogaId,
                title: "Adho Mukha Svanasana", caption: "Downward Facing Dog",
                mediaURL: "yoga_2.mp4", mediaType: .video,
                durationSeconds: 90, difficultyLevel: "beginner",
                imageurl: "adhoMukhaSavasana"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: yogaId,
                title: "Shirshasana", caption: "Headstand",
                mediaURL: "yoga_3.mp4", mediaType:.video,
                durationSeconds: 90, difficultyLevel: "intermediate",
                imageurl: "shirshasana"
            ),
            
            MindEaseCategoryContent(
                id: UUID(), categoryId: yogaId,
                title: "Vajrasana", caption: "Diamond Pose",
                mediaURL: "yoga_5.mp4", mediaType: .video,
                durationSeconds: 900, difficultyLevel: "beginner",
                imageurl: "shirshasana"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: meditationId,
                title: "Bhramari", caption: "Humming Bee Breath",
                mediaURL: "meditation_1.mp4", mediaType: .video,
                durationSeconds: 600, difficultyLevel: "beginner",
                imageurl: "yoga"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: meditationId,
                title: "Anulom Vilom", caption: "Alternate Nostril Breathing",
                mediaURL: "meditation_2.mp4", mediaType: .video,
                durationSeconds: 900, difficultyLevel: "beginner",
                imageurl: "shirshasana"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: meditationId,
                title: "Kapalbhati", caption: "Skull Shining Breath",
                mediaURL: "meditation_3.mp4", mediaType: .video,
                durationSeconds: 600, difficultyLevel: "intermediate",
                imageurl: "shirshasana"
            ),
           
            MindEaseCategoryContent(
                id: UUID(), categoryId: soundsId,
                title: "Ocean Waves", caption: "Soft ocean rhythms for deep calm",
                mediaURL: "sound_1.mp3", mediaType: .audio,
                durationSeconds: 3600, difficultyLevel: "beginner",
                imageurl: "ocean_waves_list"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: soundsId,
                title: "Forest Breeze", caption: "Feel the calm of nature in every breath",
                mediaURL: "sound_2.mp3", mediaType: .audio,
                durationSeconds: 1800, difficultyLevel: "beginner",
                imageurl: "forest_breeze_list"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: soundsId,
                title: "Bird Songs", caption: "Wake your senses with soothing bird sounds",
                mediaURL: "sound_3.mp3", mediaType: .audio,
                durationSeconds: 1200, difficultyLevel: "beginner",
                imageurl: "birdSongs"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: soundsId,
                title: "Deep Sleep Music", caption: "432 Hz binaural tones for better sleep",
                mediaURL: "sound_4.mp3", mediaType: .audio,
                durationSeconds: 3600, difficultyLevel: "beginner",
                imageurl: "deep_sleep_list"
            ),
            MindEaseCategoryContent(
                id: UUID(), categoryId: soundsId,
                title: "Evening Wind Down", caption: "Soft wind chimes ideal before sleep",
                mediaURL: "sound_5.mp3", mediaType: .audio,
                durationSeconds: 1200, difficultyLevel: "beginner",
                imageurl: "evening_wind_list"
            ),
        ]
    }

    // MARK: - Seed All

    func seedAll(userId: UUID, userPlans: [UserPlan]) {
        seedTodaysPlan(userId: userId, userPlans: userPlans)
    }

    private func seedTodaysPlan(userId: UUID, userPlans: [UserPlan]) {
        guard let plan = userPlans.first(where: { $0.userId == userId }) else { return }
        let today = Date()
        var result: [TodaysPlan] = []

        
        let dailyPlan: [(categoryTitle: String, totalMinutes: Int)] = [
            ("Meditation",      plan.meditationMinutesPerDay),
            ("Yoga",            plan.yogaMinutesPerDay),
            ("Relaxing Sounds", plan.soundMinutesPerDay),
        ]

        for (categoryTitle, totalMinutes) in dailyPlan {
            guard totalMinutes > 0,
                  let cat = mindEaseCategories.first(where: { $0.title == categoryTitle })
            else { continue }

           
            var pool = mindEaseCategoryContents
                .filter { $0.categoryId == cat.id }
                .shuffled()

            guard !pool.isEmpty else { continue }

            var budgetRemaining = totalMinutes
            var usedIds = Set<UUID>()
            var attempts = 0

            // Keep picking items until the full minute budget is filled
            while budgetRemaining > 0 && attempts < pool.count * 3 {
                if let idx = pool.indices.first(where: { !usedIds.contains(pool[$0].id) }) {
                    let content  = pool[idx]
                    let contentMins = max(1, content.durationSeconds / 60)
                    let assigned = min(contentMins, budgetRemaining)
                    result.append(TodaysPlan(
                        id: UUID(), userId: userId, planDate: today,
                        contentId: content.id, categoryId: content.categoryId,
                        planId: plan.planId,
                        minutesTarget: assigned, minutesCompleted: 0,
                        isCompleted: false
                    ))
                    usedIds.insert(content.id)
                    budgetRemaining -= assigned
                } else {
                    //reshuffle 
                    pool = pool.shuffled()
                    usedIds.removeAll()
                }
                attempts += 1
            }
        }

        todaysPlans = result
    }

    // MARK: - Computed Daily Target

    var dailyMindfulTarget: Int {
        guard
            let store = parentStore,
            let plan  = store.userPlans.first(where: { $0.userId == currentUserId })
        else { return 30 }
        return plan.meditationMinutesPerDay + plan.yogaMinutesPerDay + plan.soundMinutesPerDay
    }

    // MARK: - Content Helpers

    /// Duration in whole minutes, e.g. 90s → 1, 600s → 10
    func durationMinutes(for content: MindEaseCategoryContent) -> Int {
        content.durationSeconds / 60
    }

    /// Zero-padded "MM:SS" string, e.g. "01:30"
    func durationFormatted(for content: MindEaseCategoryContent) -> String {
        String(format: "%02d:%02d", content.durationSeconds / 60, content.durationSeconds % 60)
    }

    // MARK: - Query Helpers

    func sessions(for date: Date) -> [MindfulSession] {
        mindfulSessions.filter {
            $0.userId == currentUserId &&
            Calendar.current.isDate($0.sessionDate, inSameDayAs: date)
        }
    }

    func mindfulMinutes(for date: Date) -> Int {
        sessions(for: date).reduce(0) { $0 + $1.minutesCompleted }
    }

    func todaysMindfulMinutes() -> Int {
        mindfulMinutes(for: .now)
    }

    func weeklyMindfulMinutes() -> [Int] {
        let cal = Calendar.current
        return (0..<7).map { daysAgo -> Int in
            guard let day = cal.date(byAdding: .day, value: -daysAgo, to: .now) else { return 0 }
            return mindfulMinutes(for: day)
        }.reversed()
    }

    func getContentItems(for categoryId: UUID) -> [MindEaseCategoryContent] {
        mindEaseCategoryContents.filter { $0.categoryId == categoryId }
    }

    /// Returns minutes spent in a named category on a given date for a specific user.
    func categoryMinutes(named categoryTitle: String, for date: Date, userId: UUID) -> Int {
        sessions(for: date)
            .filter { session in
                guard session.userId == userId,
                      let content = mindEaseCategoryContents.first(where: { $0.id == session.contentId }),
                      let cat     = mindEaseCategories.first(where: { $0.id == content.categoryId })
                else { return false }
                return cat.title == categoryTitle
            }
            .reduce(0) { $0 + $1.minutesCompleted }
    }

    // MARK: - Session Lookup Helpers

    func content(for session: MindfulSession) -> MindEaseCategoryContent? {
        mindEaseCategoryContents.first { $0.id == session.contentId }
    }

    func sessionIcon(for session: MindfulSession) -> String {
        guard let content  = content(for: session),
              let category = mindEaseCategories.first(where: { $0.id == content.categoryId })
        else { return "brain.head.profile" }
        return category.cardIconName
    }

    func contentTitle(for session: MindfulSession) -> String {
        content(for: session)?.title ?? "Session"
    }

    func categoryName(for session: MindfulSession) -> String {
        guard let content  = content(for: session),
              let category = mindEaseCategories.first(where: { $0.id == content.categoryId })
        else { return "MindEase" }
        return category.title
    }

    // MARK: - Today's Plan Helpers

    func todayPlan(for content: MindEaseCategoryContent) -> TodaysPlan? {
        todaysPlans.first {
            $0.userId == currentUserId &&
            $0.contentId == content.id &&
            Calendar.current.isDateInToday($0.planDate)
        }
    }

    func todayActivePlans() -> [TodaysPlan] {
        todaysPlans.filter {
            $0.userId == currentUserId &&
            Calendar.current.isDateInToday($0.planDate)
        }
    }

    // MARK: - Plan Update

    private func updatePlan(contentId: UUID, minutesCompleted: Int) {
        guard let idx = todaysPlans.firstIndex(where: {
            $0.userId == currentUserId &&
            $0.contentId == contentId &&
            Calendar.current.isDateInToday($0.planDate)
        }) else { return }
        todaysPlans[idx].minutesCompleted = minutesCompleted
        todaysPlans[idx].isCompleted      = minutesCompleted >= todaysPlans[idx].minutesTarget
    }

    // MARK: - User Actions

    func startSession(contentId: UUID) {
        sessionStartTimes[contentId] = .now
    }

    func completeSession(contentId: UUID, minutesCompleted: Int) -> ActionResult {
        guard minutesCompleted > 0 else {
            return .blocked(reason: "Session too short to log (< 1 minute).")
        }
        let now       = Date.now
        let startTime = sessionStartTimes[contentId] ??
            Calendar.current.date(byAdding: .minute, value: -minutesCompleted, to: now)!
        sessionStartTimes.removeValue(forKey: contentId)
        mindfulSessions.append(MindfulSession(
            id: UUID(), userId: currentUserId,
            contentId: contentId, sessionDate: now,
            minutesCompleted: minutesCompleted,
            startTime: startTime, endTime: now
        ))
        updatePlan(contentId: contentId, minutesCompleted: minutesCompleted)
        let target = todaysPlans.first(where: {
            $0.userId == currentUserId && $0.contentId == contentId
        })?.minutesTarget ?? minutesCompleted
        return minutesCompleted >= target
            ? .success(message: "Session complete! \(minutesCompleted) min logged.")
            : .warning(message: "Session logged — \(minutesCompleted)/\(target) min completed.")
    }

    func logMindfulSession(contentId: UUID, minutesCompleted: Int) {
        guard minutesCompleted > 0 else { return }
        let now = Date.now
        mindfulSessions.append(MindfulSession(
            id: UUID(), userId: currentUserId, contentId: contentId,
            sessionDate: now, minutesCompleted: minutesCompleted,
            startTime: Calendar.current.date(byAdding: .minute, value: -minutesCompleted, to: now)!,
            endTime: now
        ))
        updatePlan(contentId: contentId, minutesCompleted: minutesCompleted)
    }
}

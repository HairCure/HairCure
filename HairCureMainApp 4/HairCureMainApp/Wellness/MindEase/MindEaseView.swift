//
//  MindEaseView.swift
//
//  MindEaseView              — home / dashboard
//  MindEaseProgressView      — progress tab
//  MindEaseCategoryListView  — per-category content list
//  MindEasePlayerView        — media player
//  DayDetailSheet            — past-day session detail (sheet, xmark to close)

import SwiftUI

// MARK: - Theme

extension Color {
    static let mindEasePurple = Color(red: 0.40, green: 0.30, blue: 0.85)
}

extension Date {
    func mindEaseFormatted(_ format: String) -> String {
        Date.meFormatter(format).string(from: self)
    }
    private static var meCache: [String: DateFormatter] = [:]
    private static func meFormatter(_ format: String) -> DateFormatter {
        if let f = meCache[format] { return f }
        let f = DateFormatter(); f.dateFormat = format
        meCache[format] = f; return f
    }
}

extension Date: Identifiable {
    public var id: Date { self }
}

// MARK: - View Modifiers

extension View {
    func mindEaseCard(cornerRadius: CGFloat = 18, shadowRadius: CGFloat = 10, shadowY: CGFloat = 4) -> some View {
        self.background(.background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: shadowRadius, x: 0, y: shadowY)
    }
    func mindEaseSectionHeader() -> some View {
        self.font(.system(size: 22, weight: .bold)).padding(.horizontal, 20)
    }
    func mindEaseStatValue(size: CGFloat = 28) -> some View {
        self.font(.system(size: size, weight: .bold)).foregroundStyle(Color.mindEasePurple)
    }
    func mindEasePageBackground() -> some View {
        self.background(Color.hcCream.ignoresSafeArea())
    }
}

// MARK: ── MindEaseView ──────────────────────────────────────────────────────

struct MindEaseView: View {
    @Environment(AppDataStore.self)      private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    @State private var sheetDate:         Date? = nil
    @State private var showCalendarSheet        = false
    @State private var calendarPickedDate       = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now

    private var weekDates: [Date] {
        let cal    = Calendar.current
        let today  = cal.startOfDay(for: .now)
        let offset = -(cal.component(.weekday, from: today) - 1)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: offset + $0, to: today) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // Date header
                HStack(spacing: 8) {
                    Text("Today, \(Date().mindEaseFormatted("d MMM yyyy"))")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button {
                        calendarPickedDate = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
                        showCalendarSheet = true
                    } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.mindEasePurple)
                            .padding(8)
                            .background(Color.mindEasePurple.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 20)

                // Week ring row — tap past day → sheet
                HStack(spacing: 0) {
                    ForEach(weekDates, id: \.self) { date in
                        WeekDayCell(
                            date: date,
                            dailyTarget: mindEaseStore.dailyMindfulTarget,
                            minutes: mindEaseStore.mindfulMinutes(for: date),
                            onTap: { sheetDate = date }
                        )
                    }
                }
                .padding(.horizontal, 20)

                // Categories
                VStack(alignment: .leading, spacing: 14) {
                    Text("Categories").mindEaseSectionHeader()
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(mindEaseStore.mindEaseCategories) { cat in
                                NavigationLink(value: cat) { CategoryCard(category: cat) }
                                    .buttonStyle(.plain)
                                    .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                                        c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.88)
                                    }
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 4)
                    }
                }

                // Today's plan
                VStack(alignment: .leading, spacing: 14) {
                    Text("Today's Plan").mindEaseSectionHeader()
                    let plans = mindEaseStore.todayActivePlans()
                    VStack(spacing: 0) {
                        ForEach(Array(plans.enumerated()), id: \.element.id) { idx, plan in
                            if let content = mindEaseStore.mindEaseCategoryContents.first(where: { $0.id == plan.contentId }) {
                                NavigationLink(value: content) {
                                    PlanRow(plan: plan, content: content, store: mindEaseStore)
                                }
                                .buttonStyle(.plain)
                                .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                                    c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 22)
                                }
                                if idx < plans.count - 1 { Divider().padding(.leading, 96) }
                            }
                        }
                    }
                    .mindEaseCard(cornerRadius: 16)
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .mindEasePageBackground()
        .navigationDestination(for: MindEaseCategory.self)        { MindEaseCategoryListView(category: $0) }
        .navigationDestination(for: MindEaseCategoryContent.self) { MindEasePlayerView(content: $0) }
        .sheet(item: $sheetDate) { DayDetailSheet(date: $0) }
        .sheet(isPresented: $showCalendarSheet, onDismiss: {
            sheetDate = Calendar.current.startOfDay(for: calendarPickedDate)
        }) {
            CalendarPickerSheet(pickedDate: $calendarPickedDate)
        }
    }
}

// MARK: - Week Day Cell

private struct WeekDayCell: View {
    let date:        Date
    let dailyTarget: Int
    let minutes:     Int
    let onTap:       () -> Void

    private var cal:      Calendar { .current }
    private var dayStart: Date     { cal.startOfDay(for: date) }
    private var isToday:  Bool     { cal.isDateInToday(date) }
    private var isFuture: Bool     { dayStart > cal.startOfDay(for: .now) }
    private var isPast:   Bool     { !isToday && !isFuture }
    private var letter:   String   { ["S","M","T","W","T","F","S"][cal.component(.weekday, from: date) - 1] }
    private var progress: Double   { min(Double(minutes) / Double(max(1, dailyTarget)), 1.0) }

    var body: some View {
        Button {
            guard isPast else { return }
            onTap()
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    if isToday { Circle().fill(Color.mindEasePurple).frame(width: 28, height: 28) }
                    Text(letter)
                        .font(.system(size: 13, weight: isToday ? .semibold : .regular))
                        .foregroundStyle(isToday ? .white : Color.secondary)
                }
                .frame(width: 28, height: 28)

                MindEaseProgressRing(progress: progress, lineWidth: 4, diameter: 32,
                                     color: isFuture ? .gray : .mindEasePurple, trackOpacity: 0.12)
                .frame(width: 36, height: 36)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(!isPast)
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    let category: MindEaseCategory
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            MindEaseThumbnail(imageurl: category.cardImageUrl, size: 220, height: 145,
                              cornerRadius: 0, placeholder: category.cardIconName, placeholderSize: 44)
            LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                .frame(width: 220, height: 145)
            VStack(alignment: .leading, spacing: 5) {
                Text(category.title).font(.system(size: 17, weight: .bold)).foregroundStyle(.white)
                Text(category.categoryDescription)
                    .font(.system(size: 12)).foregroundStyle(.white.opacity(0.80))
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
        }
        .frame(width: 220, height: 145)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Plan Row

private struct PlanRow: View {
    let plan: TodaysPlan; let content: MindEaseCategoryContent; let store: MindEaseDataStore
    var body: some View {
        HStack(spacing: 14) {
            MindEaseThumbnail(imageurl: content.imageurl, size: 68, cornerRadius: 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(content.title).font(.system(size: 16, weight: .semibold))
                HStack(spacing: 6) {
                    Text("\(store.durationMinutes(for: content)) mins")
                        .font(.system(size: 13, weight: .medium)).foregroundStyle(Color.mindEasePurple)
                    Text(content.difficultyLevel.capitalized).font(.system(size: 13, weight: .bold))
                }
            }
            Spacer()
            if plan.isCompleted {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 28)).foregroundStyle(Color.mindEasePurple)
            } else {
                Text("Start").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white)
                    .padding(.horizontal, 22).padding(.vertical, 10)
                    .background(Color.mindEasePurple).clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

// MARK: - Calendar Picker Sheet

private struct CalendarPickerSheet: View {
    @Binding var pickedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var pushedDate: Date?

    var body: some View {
        NavigationStack {
            DatePicker("Select a past date", selection: $pickedDate,
                       in: ...Calendar.current.date(byAdding: .day, value: -1, to: .now)!,
                       displayedComponents: .date)
                .datePickerStyle(.graphical).tint(.mindEasePurple)
                .padding(.horizontal, 16).padding(.top, 8)
                .navigationTitle("View Past Day").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { dismiss() } label: { Image(systemName: "xmark") }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("View Day") { pushedDate = Calendar.current.startOfDay(for: pickedDate) }
                            .fontWeight(.semibold).foregroundStyle(Color.mindEasePurple)
                    }
                }
                .navigationDestination(item: $pushedDate) { DayDetailSheet(date: $0) }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: ── MindEaseProgressView ─────────────────────────────────────────────

struct MindEaseProgressView: View {
    @Environment(AppDataStore.self)      private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    private var recentDates: [Date] {
        let cal   = Calendar.current
        let today = cal.startOfDay(for: .now)
        return (1...7).compactMap { cal.date(byAdding: .day, value: -$0, to: today) }
    }

    @State private var sheetDate:    Date? = nil
    @State private var showDatePicker      = false
    @State private var calendarDate        = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {

                // Today compact card
                let done   = mindEaseStore.mindfulMinutes(for: .now)
                let target = max(1, mindEaseStore.dailyMindfulTarget)
                HStack(spacing: 16) {
                    MindEaseProgressRing(progress: min(Double(done) / Double(target), 1.0), lineWidth: 8, diameter: 56)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today").font(.system(size: 14, weight: .semibold)).foregroundStyle(.secondary)
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(done)").mindEaseStatValue()
                            Text("/ \(target) min").font(.system(size: 14)).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(16)
                .mindEaseCard()
                .padding(.horizontal, 20).padding(.top, 4)

                // Recent days header
                HStack {
                    Text("Recent Days").mindEaseSectionHeader()
                    Spacer()
                    Button { showDatePicker = true } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.mindEasePurple)
                            .padding(.trailing, 20)
                    }
                    .sheet(isPresented: $showDatePicker) {
                        CalendarPickerSheet(pickedDate: $calendarDate)
                    }
                }

                // Past-day rows — tap → sheet
                VStack(spacing: 0) {
                    ForEach(Array(recentDates.enumerated()), id: \.element) { idx, date in
                        DayProgressRow(
                            date: date,
                            minutes: mindEaseStore.mindfulMinutes(for: date),
                            target: mindEaseStore.dailyMindfulTarget,
                            onTap: { sheetDate = date }
                        )
                        if idx < recentDates.count - 1 { Divider().padding(.leading, 20) }
                    }
                }
                .mindEaseCard()
                .padding(.horizontal, 20)

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("MindEase Progress")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sheetDate) { DayDetailSheet(date: $0) }
    }
}

private struct DayProgressRow: View {
    let date: Date; let minutes: Int; let target: Int; let onTap: () -> Void
    private var progress: Double { min(Double(minutes) / Double(max(1, target)), 1.0) }
    private var label: String {
        Calendar.current.isDateInYesterday(date) ? "Yesterday" : date.mindEaseFormatted("EEE, d MMM")
    }
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                MindEaseProgressRing(progress: progress, lineWidth: 4, diameter: 36)
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 15, weight: .semibold))
                    Text(minutes > 0 ? "\(minutes) min · \(Int(progress * 100))% of goal" : "Rest day")
                        .font(.system(size: 12)).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium)).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16).padding(.vertical, 12).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: ── DayDetailSheet ───────────────────────────────────────────────────

struct DayDetailSheet: View, Identifiable {
    var id: Date { date }
    @Environment(AppDataStore.self)      private var store
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    @Environment(\.dismiss)             private var dismiss
    let date: Date

    private var sessions: [MindfulSession] {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mindEaseStore.mindfulSessions
            .filter {
                $0.userId == store.currentUserId &&
                Calendar.current.startOfDay(for: $0.sessionDate) == dayStart
            }
            .sorted { $0.startTime < $1.startTime }
    }
    private var totalMinutes:  Int    { sessions.reduce(0) { $0 + $1.minutesCompleted } }
    private var targetMinutes: Int    { mindEaseStore.dailyMindfulTarget }
    private var fraction:      Double {
        guard targetMinutes > 0 else { return 0 }
        return min(Double(totalMinutes) / Double(targetMinutes), 1.0)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // Inline summary card
                    HStack(spacing: 16) {
                        MindEaseProgressRing(progress: fraction, lineWidth: 8, diameter: 56)
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(alignment: .lastTextBaseline, spacing: 4) {
                                Text("\(totalMinutes)").mindEaseStatValue()
                                Text("/ \(targetMinutes) min").font(.system(size: 14)).foregroundStyle(.secondary)
                            }
                            Text(totalMinutes == 0 ? "No sessions logged"
                                 : fraction >= 1   ? "Goal reached 🎉"
                                                   : "\(targetMinutes - totalMinutes) min short")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(fraction >= 1 ? Color.mindEasePurple : .secondary)
                        }
                        Spacer()
                    }
                    .padding(16)
                    .mindEaseCard()
                    .padding(.horizontal, 20)

                    // Sessions
                    Text(sessions.isEmpty ? "Sessions" : "Sessions (\(sessions.count))")
                        .mindEaseSectionHeader()

                    if sessions.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 44)).foregroundStyle(.secondary.opacity(0.35))
                            Text("No sessions logged for this day")
                                .font(.system(size: 15)).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 48)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(sessions.enumerated()), id: \.element.id) { idx, session in
                                SessionRow(session: session)
                                if idx < sessions.count - 1 { Divider().padding(.leading, 72) }
                            }
                        }
                        .mindEaseCard(cornerRadius: 16, shadowRadius: 8, shadowY: 3)
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .mindEasePageBackground()
            .navigationTitle(date.mindEaseFormatted("EEE, d MMM"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

private struct SessionRow: View {
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    let session: MindfulSession
    var body: some View {
        HStack(spacing: 14) {
            MindEaseSessionIconView(iconName: mindEaseStore.sessionIcon(for: session), size: 52, cornerRadius: 10)
            VStack(alignment: .leading, spacing: 4) {
                Text(mindEaseStore.contentTitle(for: session))
                    .font(.system(size: 15, weight: .semibold)).lineLimit(1)
                Text("\(session.startTime.mindEaseFormatted("h:mm a")) – \(session.endTime.mindEaseFormatted("h:mm a"))")
                    .font(.system(size: 12)).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 2) {
                Text("\(session.minutesCompleted)").mindEaseStatValue(size: 18)
                Text("min").font(.system(size: 11)).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }
}

// MARK: ── MindEaseCategoryListView ────────────────────────────────────────

struct MindEaseCategoryListView: View {
    let category: MindEaseCategory
    @Environment(MindEaseDataStore.self) private var mindEaseStore

    var body: some View {
        let contents = mindEaseStore.mindEaseCategoryContents.filter { $0.categoryId == category.id }
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ForEach(Array(contents.enumerated()), id: \.element.id) { idx, content in
                        NavigationLink(value: content) { ContentRow(content: content, store: mindEaseStore) }
                            .buttonStyle(.plain)
                            .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                                c.opacity(p.isIdentity ? 1 : 0).offset(x: p.isIdentity ? 0 : 24)
                            }
                        if idx < contents.count - 1 { Divider().padding(.leading, 100) }
                    }
                }
                .mindEaseCard()
                .padding(.horizontal, 16).padding(.top, 12)
                Spacer(minLength: 32)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .mindEasePageBackground()
        .navigationTitle(category.title).navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: MindEaseCategoryContent.self) { MindEasePlayerView(content: $0) }
    }
}

private struct ContentRow: View {
    let content: MindEaseCategoryContent; let store: MindEaseDataStore
    private var isAudio: Bool { content.mediaType == "audio" }
    var body: some View {
        HStack(spacing: 14) {
            MindEaseThumbnail(imageurl: content.imageurl, size: 78, height: 68, cornerRadius: 10,
                              placeholder: isAudio ? "waveform" : "play.fill")
            VStack(alignment: .leading, spacing: 4) {
                Text(content.title).font(.system(size: 16, weight: .semibold)).lineLimit(1)
                Text(content.caption).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(isAudio ? 2 : 1)
                if !isAudio {
                    Label(store.durationFormatted(for: content), systemImage: "clock")
                        .font(.system(size: 12, weight: .medium)).foregroundStyle(.secondary).padding(.top, 2)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .medium)).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16).padding(.vertical, 14).contentShape(Rectangle())
    }
}

// MARK: ── MindEasePlayerView ───────────────────────────────────────────────

struct MindEasePlayerView: View {
    let content: MindEaseCategoryContent
    @Environment(MindEaseDataStore.self) private var mindEaseStore
    @State private var isPlaying = false
    @State private var progress  = 0.0

    private var elapsed:   Int { Int(progress * Double(content.durationSeconds)) }
    private var remaining: Int { max(0, content.durationSeconds - elapsed) }
    private func timeLabel(_ s: Int) -> String { String(format: "%02d : %02d", s / 60, s % 60) }
    private func saveProgress() {
        let mins = elapsed / 60; guard mins > 0 else { return }
        mindEaseStore.logMindfulSession(contentId: content.id, minutesCompleted: mins)
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                MindEaseThumbnail(imageurl: content.imageurl,
                                  size: geo.size.width, height: geo.size.height * 0.48,
                                  cornerRadius: 0,
                                  placeholder: content.mediaType == "audio" ? "waveform" : "play.circle",
                                  placeholderSize: 64)
                .clipped()

                VStack(spacing: 0) {
                    HStack {
                        Text(content.title).font(.system(size: 22, weight: .bold)).lineLimit(1)
                        Spacer()
                        Button { } label: { Image(systemName: "stopwatch").font(.system(size: 22)) }
                    }
                    Slider(value: $progress, in: 0...1).tint(.black).padding(.top, 16)
                    HStack {
                        Text(timeLabel(elapsed)).font(.system(size: 12, weight: .medium, design: .monospaced)).foregroundStyle(.secondary)
                        Spacer()
                        Text(timeLabel(remaining)).font(.system(size: 12, weight: .medium, design: .monospaced)).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 0) {
                        Button { progress = max(0, progress - 0.05) } label: {
                            Image(systemName: "backward.end.fill").font(.system(size: 24))
                        }.frame(maxWidth: .infinity)

                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) { isPlaying.toggle() }
                        } label: {
                            ZStack {
                                Circle().fill(Color.black).frame(width: 64, height: 64)
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 24)).foregroundStyle(.white)
                                    .contentTransition(.symbolEffect(.replace))
                            }
                        }.frame(maxWidth: .infinity)

                        Button { progress = min(1, progress + 0.05) } label: {
                            Image(systemName: "forward.end.fill").font(.system(size: 24))
                        }.frame(maxWidth: .infinity)
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle(content.title).navigationBarTitleDisplayMode(.inline)
        .task(id: isPlaying) {
            guard isPlaying else { return }
            let step = 1.0 / Double(max(1, content.durationSeconds))
            do {
                while true {
                    try await Task.sleep(for: .seconds(1))
                    progress = min(1.0, progress + step)
                    if progress >= 1.0 { isPlaying = false; saveProgress(); break }
                }
            } catch {}
        }
        .onDisappear { saveProgress() }
    }
}

// MARK: ── Shared Primitives ────────────────────────────────────────────────

struct MindEaseProgressRing: View {
    let progress: Double; let lineWidth: CGFloat; let diameter: CGFloat
    var color: Color = .mindEasePurple; var trackOpacity: Double = 0.15
    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(trackOpacity), lineWidth: lineWidth)
            Circle().trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
        }
        .frame(width: diameter, height: diameter)
    }
}

struct MindEaseSessionIconView: View {
    let iconName: String; let size: CGFloat; let cornerRadius: CGFloat
    var color: Color = .mindEasePurple
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(color.opacity(0.10)).frame(width: size, height: size)
            .overlay(Image(systemName: iconName).font(.system(size: size * 0.45)).foregroundStyle(color))
    }
}

struct MindEaseThumbnail: View {
    let imageurl: String
    var size: CGFloat = 68; var height: CGFloat? = nil
    var cornerRadius: CGFloat = 10
    var placeholder: String = "photo"; var placeholderSize: CGFloat = 20
    var body: some View {
        Group {
            if let img = UIImage(named: imageurl) {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                Color(UIColor.systemGray5)
                    .overlay(Image(systemName: placeholder)
                        .font(.system(size: placeholderSize, weight: .ultraLight)).foregroundStyle(.secondary))
            }
        }
        .frame(width: size, height: height ?? size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: ── Previews ─────────────────────────────────────────────────────────

#Preview("Home") {
    NavigationStack {
        MindEaseView()
            .environment(AppDataStore())
            .environment(MindEaseDataStore(currentUserId: UUID()))
    }
}

#Preview("Progress") {
    NavigationStack {
        MindEaseProgressView()
            .environment(AppDataStore())
            .environment(MindEaseDataStore(currentUserId: UUID()))
    }
}

#Preview("Day Detail Sheet") {
    DayDetailSheet(date: Calendar.current.date(byAdding: .day, value: -1, to: .now)!)
        .environment(AppDataStore())
        .environment(MindEaseDataStore(currentUserId: UUID()))
}

#Preview("Category List") {
    let s = MindEaseDataStore(currentUserId: UUID())
    return NavigationStack {
        MindEaseCategoryListView(category: s.mindEaseCategories[0]).environment(s)
    }
}


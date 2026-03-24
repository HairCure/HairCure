//
//  HairProgressView.swift
//  HairCureTesting1
//
//  Navigation flow:
//  Profile → Hair Progress  →  HairProgressJourneyView   (camera scan + Hair Journey + "See all")
//                          →  (See all tap)  →  HairProgressAllScansView  (monthly reports)
//                          →  (View Details) →  HairProgressDetailView
//

import SwiftUI

// ─────────────────────────────────────────────────────────────
// MARK: 1 — Journey View  (first screen after Profile row tap)
// "Hair Progress" title · camera scan card · Hair Journey list · See all
// ─────────────────────────────────────────────────────────────

struct HairProgressView: View {
    @Environment(AppDataStore.self) private var store

    /// Preview: first 3 entries from the current month
    private var previewEntries: [HairProgressEntry] {
        Array(allEntriesForCurrentMonth().prefix(3))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // ─── Camera Scan Card ───
                scanCard
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // ─── Hair Journey heading ───
                Text("Hair Journey")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal, 20)

                // ─── Preview Cards (max 3) ───
                ForEach(previewEntries) { entry in
                    NavigationLink(destination: HairProgressDetailView(entry: entry)) {
                        HairProgressCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                }

                // ─── See all ───
                NavigationLink(destination: HairProgressAllScansView()) {
                    Text("See all")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.hcTeal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 32)
            }
            .padding(.top, 4)
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle("Hair Progress")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Camera scan card

    private var scanCard: some View {
        VStack(spacing: 14) {
            // Dashed border camera area
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                    .foregroundColor(Color.hcBrown.opacity(0.35))

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 52, weight: .thin))
                    .foregroundColor(.primary.opacity(0.7))
            }
            .frame(height: 130)

            // Take a scan button
            Button {} label: {
                Text("Take a scan")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.hcBrown)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(UIColor.systemGray6).opacity(0.6))
        )
    }

    // MARK: - Helper: generate entries for the current month

    private func allEntriesForCurrentMonth() -> [HairProgressEntry] {
        hairProgressEntries(for: Date(), store: store)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 2 — All Scans View  (reached via "See all")
// "My Hair Progress" title · monthly reports heading · date picker · full list
// ─────────────────────────────────────────────────────────────

struct HairProgressAllScansView: View {
    @Environment(AppDataStore.self) private var store

    @State private var selectedMonth: Date = Date()
    @State private var showMonthPicker = false

    private var entries: [HairProgressEntry] {
        hairProgressEntries(for: selectedMonth, store: store)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // ─── Month row ───
                HStack {
                    Text("Monthly reports")
                        .font(.system(size: 22, weight: .bold))

                    Spacer()

                    Button { showMonthPicker.toggle() } label: {
                        HStack(spacing: 6) {
                            Text(monthLabel(selectedMonth))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Image(systemName: "calendar")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color.hcBrown)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // ─── Entry cards ───
                if entries.isEmpty {
                    emptyState
                } else {
                    ForEach(entries) { entry in
                        NavigationLink(destination: HairProgressDetailView(entry: entry)) {
                            HairProgressCard(entry: entry)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                    }
                }

                Spacer(minLength: 32)
            }
            .padding(.top, 8)
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle("My Hair Progress")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMonthPicker) {
            MonthPickerSheet(selectedMonth: $selectedMonth)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 60)
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 52))
                .foregroundColor(Color.hcBrown.opacity(0.35))
            Text("No scans for this month")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }

    private func monthLabel(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM, yyyy"
        let lastDay = Calendar.current.date(
            byAdding: DateComponents(month: 1, day: -1),
            to: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date))!
        ) ?? date
        return df.string(from: lastDay)
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 3 — Shared data model + helpers
// ─────────────────────────────────────────────────────────────

struct HairProgressEntry: Identifiable {
    let id: UUID
    let densityPercent: Int
    let doneOn: String      // "05 Dec,2025"
}

/// Generates mock weekly scan entries for a given month
func hairProgressEntries(for month: Date, store: AppDataStore) -> [HairProgressEntry] {
    let cal = Calendar.current
    let comps = cal.dateComponents([.year, .month], from: month)
    guard let firstOfMonth = cal.date(from: comps),
          let firstOfNext  = cal.date(byAdding: .month, value: 1, to: firstOfMonth)
    else { return [] }

    let baseDensity = Int(store.latestScanReport?.hairDensityPercent ?? 70)
    var entries: [HairProgressEntry] = []
    let weekOffsets: [(Int, Int)] = [(0, 3), (7, 4), (14, 5), (21, 6), (28, 7)]
    let df = DateFormatter()
    df.dateFormat = "dd MMM,yyyy"

    for (weekBack, densityDrop) in weekOffsets {
        guard let scanDate = cal.date(byAdding: .day, value: -weekBack, to: firstOfNext),
              scanDate >= firstOfMonth
        else { continue }

        let density = max(60, baseDensity - densityDrop + weekOffsets.count - 1)
        entries.append(HairProgressEntry(id: UUID(),
                                         densityPercent: density,
                                         doneOn: df.string(from: scanDate)))
    }
    return entries
}

// ─────────────────────────────────────────────────────────────
// MARK: 4 — Shared Card
// ─────────────────────────────────────────────────────────────

struct HairProgressCard: View {
    let entry: HairProgressEntry

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Density Percentage : \(entry.densityPercent)%")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Text("Done on \(entry.doneOn)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()

            Text("View Details")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.hcBrown)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 5 — Month Picker Sheet
// ─────────────────────────────────────────────────────────────

private struct MonthPickerSheet: View {
    @Binding var selectedMonth: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            DatePicker("Select month",
                       selection: $selectedMonth,
                       displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .tint(Color.hcBrown)
                .padding(.horizontal)
                .navigationTitle("Choose Month")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                            .foregroundColor(Color.hcBrown)
                    }
                }
        }
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: 6 — Detail View
// ─────────────────────────────────────────────────────────────

struct HairProgressDetailView: View {
    let entry: HairProgressEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Circular density gauge
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color.hcBrown.opacity(0.15), lineWidth: 14)
                            .frame(width: 140, height: 140)
                        Circle()
                            .trim(from: 0, to: CGFloat(entry.densityPercent) / 100)
                            .stroke(Color.hcBrown,
                                    style: StrokeStyle(lineWidth: 14, lineCap: .round))
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90))
                        VStack(spacing: 2) {
                            Text("\(entry.densityPercent)%")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color.hcBrown)
                            Text("Hair Density")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 12)

                    Text("Done on \(entry.doneOn)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray6).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)

                Group {
                    detailRow(title: "Hair Density Level",
                              value: entry.densityPercent >= 80 ? "High — Thick & full"
                                   : entry.densityPercent >= 65 ? "Medium"
                                   : "Low — Thin")
                    detailRow(title: "Scan Type",       value: "Weekly scan")
                    detailRow(title: "Analysis Source", value: "AI Model")
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle("Scan Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────────────────────

#Preview {
    NavigationStack {
        HairProgressView()
    }
    .environment(AppDataStore())
}

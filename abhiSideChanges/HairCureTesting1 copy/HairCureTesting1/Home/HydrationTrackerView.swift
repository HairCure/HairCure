//
//  HydrationTrackerView.swift
//  HairCureTesting1
//
//  Created by Abhinav Yadav on 20/03/26.
//


//
//  HydrationTrackerView.swift
//  HairCure
//
//  Sheet — log water intake by cup size.
//  Shows today's total vs target, 3 cup size options, log button.
//

import SwiftUI

struct HydrationTrackerView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(\.dismiss)         private var dismiss

    @State private var selectedCupSize: CupOption = .medium
    @State private var banner: String? = nil

    private var todayML:  Float { store.todaysTotalWaterML() }
    private var targetML: Float { store.activeNutritionProfile?.waterTargetML ?? 2450 }
    private var progress: Float { min(todayML / targetML, 1.0) }

    enum CupOption: String, CaseIterable {
        case small  = "Small"
        case medium = "Medium"
        case large  = "Large"

        var ml: Float {
            switch self {
            case .small:  return 150
            case .medium: return 250
            case .large:  return 400
            }
        }
        var icon: String { "cup.and.saucer.fill" }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hcCream.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Progress ring
                        progressRing
                            .padding(.top, 8)

                        // Today vs target
                        HStack {
                            statCell(value: "\(Int(todayML)) ml", label: "Today")
                            Divider().frame(height: 44)
                            statCell(value: "\(Int(targetML)) ml", label: "Target")
                            Divider().frame(height: 44)
                            statCell(
                                value: "\(Int(max(0, targetML - todayML))) ml",
                                label: "Remaining"
                            )
                        }
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        // Cup size selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select cup size")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)

                            HStack(spacing: 12) {
                                ForEach(CupOption.allCases, id: \.self) { cup in
                                    let isSel = selectedCupSize == cup
                                    Button { selectedCupSize = cup } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: cup.icon)
                                                .font(.system(size: isSel ? 28 : 22))
                                                .foregroundColor(isSel ? .white : Color(red: 0.15, green: 0.55, blue: 0.9))
                                            Text(cup.rawValue)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(isSel ? .white : .primary)
                                            Text("\(Int(cup.ml)) ml")
                                                .font(.system(size: 11))
                                                .foregroundColor(isSel ? .white.opacity(0.8) : .secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(isSel ? Color(red: 0.15, green: 0.55, blue: 0.9) : Color.white)
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    isSel ? Color.clear : Color(.systemGray4),
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Log button
                        Button {
                            let result = store.logWaterIntake(
                                cupSize: selectedCupSize.rawValue.lowercased(),
                                amountML: selectedCupSize.ml
                            )
                            if case .success(let msg) = result { banner = msg }
                        } label: {
                            Text("+ Add \(Int(selectedCupSize.ml)) ml")
                                .hcPrimaryButton()
                        }
                        .padding(.horizontal, 20)

                        // Banner
                        if let msg = banner {
                            Text(msg)
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.15, green: 0.55, blue: 0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .transition(.opacity)
                        }

                        // Today's log list
                        if !store.todaysWaterLogs().isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Today's log")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)

                                ForEach(store.todaysWaterLogs()) { log in
                                    HStack {
                                        Image(systemName: "drop.fill")
                                            .foregroundColor(Color(red: 0.15, green: 0.55, blue: 0.9))
                                            .font(.system(size: 14))
                                        Text("\(Int(log.cupSizeAmountInML)) ml · \(log.cupSize.capitalized)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(timeString(log.loggedAt))
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    .animation(.easeInOut(duration: 0.25), value: banner)
                }
            }
            .navigationTitle("Hydration")
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") { dismiss() }
//                        .foregroundColor(Color.hcBrown)
//                }
//            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color.hcBrown)
                }
            }
        }
    }

    // ── Progress ring ──
    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(red: 0.15, green: 0.55, blue: 0.9).opacity(0.15), lineWidth: 14)
                .frame(width: 130, height: 130)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    Color(red: 0.15, green: 0.55, blue: 0.9),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 130, height: 130)
                .animation(.easeOut(duration: 0.6), value: progress)
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                Text("of daily goal")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }
}

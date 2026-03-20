//
//  PlanResultView.swift
//  HairCureTesting
//
//  Created by Abhinav Yadav on 19/03/26.
//

//
//  PlanResultsView.swift
//  HairCure
//
//  "Scan Report" screen shown after engine assigns the plan.
//
//  Layout (top → bottom):
//    1. Nav bar — back + "Scan Report" title
//    2. 3 scan photo thumbnails with timestamps (dashed border)
//    3. Swipeable 2-page TabView card:
//         Page 1 — Hair Analysis Results (density / stage / scalp)
//         Page 2 — Lifestyle Scores (Poor/Moderate/Good badge + dot scores)
//    4. Page indicator dots
//    5. "Recommended Plan" section — 4 icon cards
//    6. "Get Started" pinned button
//

//import SwiftUI
//
//struct PlanResultsView: View {
//    @Environment(AppDataStore.self) private var store
//    let result:     ActionResult
//    let onContinue: () -> Void
//
//    @State private var cardPage      = 0
//    @State private var scoresVisible = false
//    @Environment(\.dismiss) private var dismiss
//
//    private var report: ScanReport? { store.latestScanReport }
//    private var plan:   UserPlan?   { store.activePlan }
//
//    private let photoTimes = ["12 : 35 PM", "12 : 40 PM", "12 : 45 PM"]
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Color.hcCream.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 20) {
//
//                    navBar.padding(.top, 8)
//
//                    photoStrip.padding(.horizontal, 20)
//
//                    TabView(selection: $cardPage) {
//                        analysisCard.tag(0)
//                        scoresCard.tag(1)
//                    }
//                    .tabViewStyle(.page(indexDisplayMode: .never))
//                    .frame(height: 220)
//                    .padding(.horizontal, 20)
//
//                    pageIndicator.frame(maxWidth: .infinity)
//
//                    Text("Recommended Plan")
//                        .font(.system(size: 22, weight: .bold))
//                        .padding(.horizontal, 20)
//                        .padding(.top, 4)
//
//                    recommendedPlanCards.padding(.horizontal, 20)
//
//                    if case .referDoctor(let msg) = result {
//                        doctorCard(msg).padding(.horizontal, 20)
//                    }
//
//                    Spacer(minLength: 110)
//                }
//            }
//
//            Button { onContinue() } label: {
//                Text("Get Started").hcPrimaryButton()
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 36)
//            .background(Color.hcCream)
//        }
//        .navigationBarHidden(true)
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                withAnimation(.easeOut(duration: 0.7)) { scoresVisible = true }
//            }
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Nav Bar
//    // ─────────────────────────────────────
//
//    private var navBar: some View {
//        HStack {
//            HCBackButton { dismiss() }
//            Spacer()
//            Text("Scan Report")
//                .font(.system(size: 18, weight: .bold))
//            Spacer()
//            Color.clear.frame(width: 40, height: 40)
//        }
//        .padding(.horizontal, 16)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Photo Strip
//    // ─────────────────────────────────────
//
//    private var photoStrip: some View {
//        HStack(spacing: 12) {
//            ForEach(0..<3, id: \.self) { i in
//                VStack(spacing: 6) {
//                    photoThumbnail(index: i)
//                    Text(photoTimes[i])
//                        .font(.system(size: 11))
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func photoThumbnail(index: Int) -> some View {
//        let assets = ["arjun_front", "arjun_left", "arjun_top"]
//        let name   = assets[index]
//        ZStack {
//            RoundedRectangle(cornerRadius: 12)
//                .strokeBorder(
//                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])
//                )
//                .foregroundColor(Color(.systemGray3))
//
//            if UIImage(named: name) != nil {
//                Image(name)
//                    .resizable()
//                    .scaledToFill()
//                    .clipShape(RoundedRectangle(cornerRadius: 11))
//            } else {
//                // Placeholder — swap with real asset in Assets.xcassets
//                RoundedRectangle(cornerRadius: 11)
//                    .fill(Color(.systemGray5))
//                    .overlay {
//                        VStack(spacing: 4) {
//                            Image(systemName: "photo")
//                                .font(.system(size: 22))
//                                .foregroundColor(Color(.systemGray3))
//                            Text(["Front","Left","Top"][index])
//                                .font(.system(size: 10))
//                                .foregroundColor(Color(.systemGray3))
//                        }
//                    }
//            }
//        }
//        .frame(height: 110)
//        .frame(maxWidth: .infinity)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Page 1 — Hair Analysis Results
//    // ─────────────────────────────────────
//
//    private var analysisCard: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Text("Your Hair Analysis Results")
//                .font(.system(size: 17, weight: .bold))
//                .padding(.bottom, 12)
//            Divider().padding(.bottom, 16)
//
//            if let r = report {
//                analysisRow("Hair Density",    "\(Int(r.hairDensityPercent))%",     densityColor(r.hairDensityPercent))
//                analysisRow("Growth Stage",    "Stage \(r.hairFallStage.intValue)", .orange)
//                analysisRow("Scalp Condition", scalpLabel(r.scalpCondition),        .blue)
//            }
//            Spacer()
//        }
//        .padding(20)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.white)
//        .cornerRadius(16)
//    }
//
//    private func analysisRow(_ label: String, _ value: String, _ color: Color) -> some View {
//        HStack {
//            Text(label).font(.system(size: 15)).foregroundColor(.primary)
//            Spacer()
//            Text(value).font(.system(size: 15, weight: .semibold)).foregroundColor(color)
//        }
//        .padding(.bottom, 16)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Page 2 — Lifestyle Scores
//    // ─────────────────────────────────────
//
//    private var scoresCard: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            HStack {
//                Text("Lifestyle Scores")
//                    .font(.system(size: 17, weight: .bold))
//                Spacer()
//                if let r = report { lifestyleBadge(r.lifestyleScore) }
//            }
//            .padding(.bottom, 12)
//            Divider().padding(.bottom, 16)
//
//            if let r = report {
//                scoreRow("Sleep",     r.sleepScore,    dotFor(r.sleepScore))
//                scoreRow("Stress",    r.stressScore,   dotFor(r.stressScore))
//                scoreRow("Diet",      r.dietScore,     dotFor(r.dietScore))
//                scoreRow("Hair care", r.hairCareScore, dotFor(r.hairCareScore))
//            }
//            Spacer()
//        }
//        .padding(20)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.white)
//        .cornerRadius(16)
//    }
//
//    private func scoreRow(_ label: String, _ value: Float, _ dot: Color) -> some View {
//        HStack {
//            Text(label).font(.system(size: 15)).foregroundColor(.primary)
//            Spacer()
//            HStack(spacing: 6) {
//                Circle().fill(dot).frame(width: 10, height: 10)
//                Text("\(Int(value))/10")
//                    .font(.system(size: 15, weight: .semibold))
//                    .foregroundColor(.primary)
//            }
//        }
//        .padding(.bottom, 14)
//    }
//
//    private func lifestyleBadge(_ score: Float) -> some View {
//        let (label, color) = lifestyleInfo(score)
//        return Text(label)
//            .font(.system(size: 13, weight: .semibold))
//            .foregroundColor(color)
//            .padding(.horizontal, 14)
//            .padding(.vertical, 5)
//            .background(color.opacity(0.15))
//            .cornerRadius(20)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Page Dots
//    // ─────────────────────────────────────
//
//    private var pageIndicator: some View {
//        HStack(spacing: 8) {
//            ForEach(0..<2, id: \.self) { i in
//                Circle()
//                    .fill(i == cardPage ? Color.hcBrown : Color(.systemGray4))
//                    .frame(width: 8, height: 8)
//            }
//        }
//        .animation(.easeInOut(duration: 0.2), value: cardPage)
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Recommended Plan Cards
//    // ─────────────────────────────────────
//
//    private struct PlanCard {
//        let iconName:  String
//        let iconColor: Color
//        let title:     String
//        let subtitle:  String
//    }
//
//    private var planCards: [PlanCard] {
//        let waterML = Int(store.activeNutritionProfile?.waterTargetML ?? 2450)
//        return [
//            PlanCard(iconName: "leaf.fill",
//                     iconColor: .orange,
//                     title: "Protein Rich-Diet",
//                     subtitle: "For keratin production"),
//            PlanCard(iconName: "moon.zzz.fill",
//                     iconColor: Color(red: 0.40, green: 0.30, blue: 0.90),
//                     title: "Sleep",
//                     subtitle: "Aim for 7–8 hours to reduce cortisol"),
//            PlanCard(iconName: "drop.fill",
//                     iconColor: .blue,
//                     title: "Hydration",
//                     subtitle: "Drink at least \(waterML) ml of water to keep your body hydrated"),
//            PlanCard(iconName: "heart.fill",
//                     iconColor: .green,
//                     title: "Stress management",
//                     subtitle: "High stress pushes hair follicles into a resting phase"),
//        ]
//    }
//
//    private var recommendedPlanCards: some View {
//        VStack(spacing: 12) {
//            ForEach(planCards, id: \.title) { card in
//                HStack(spacing: 16) {
//                    ZStack {
//                        Circle()
//                            .fill(card.iconColor)
//                            .frame(width: 52, height: 52)
//                        Image(systemName: card.iconName)
//                            .font(.system(size: 20))
//                            .foregroundColor(.white)
//                    }
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(card.title)
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.primary)
//                        Text(card.subtitle)
//                            .font(.system(size: 13))
//                            .foregroundColor(.secondary)
//                            .fixedSize(horizontal: false, vertical: true)
//                    }
//                    Spacer()
//                }
//                .padding(16)
//                .background(Color.white)
//                .cornerRadius(14)
//            }
//        }
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Doctor Card
//    // ─────────────────────────────────────
//
//    private func doctorCard(_ message: String) -> some View {
//        HStack(alignment: .top, spacing: 16) {
//            ZStack {
//                Circle().fill(Color.red).frame(width: 52, height: 52)
//                Image(systemName: "stethoscope")
//                    .font(.system(size: 20)).foregroundColor(.white)
//            }
//            VStack(alignment: .leading, spacing: 4) {
//                Text("See a dermatologist")
//                    .font(.system(size: 16, weight: .semibold))
//                Text(message)
//                    .font(.system(size: 13))
//                    .foregroundColor(.secondary)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            Spacer()
//        }
//        .padding(16)
//        .background(Color.red.opacity(0.06))
//        .cornerRadius(14)
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.red.opacity(0.2), lineWidth: 1))
//    }
//
//    // ─────────────────────────────────────
//    // MARK: Helpers
//    // ─────────────────────────────────────
//
//    private func densityColor(_ pct: Float) -> Color {
//        pct >= 70 ? .green : pct >= 50 ? .orange : .red
//    }
//
//    private func dotFor(_ score: Float) -> Color {
//        score >= 7 ? .green : score >= 5 ? .orange : .red
//    }
//
//    private func lifestyleInfo(_ score: Float) -> (String, Color) {
//        switch score {
//        case 0..<5:  return ("Poor",     .red)
//        case 5..<8:  return ("Moderate", .orange)
//        default:     return ("Good",     .green)
//        }
//    }
//
//    private func scalpLabel(_ c: ScalpCondition) -> String {
//        switch c {
//        case .dry:      return "Mild Dryness"
//        case .dandruff: return "Dandruff"
//        case .oily:     return "Oily Scalp"
//        case .inflamed: return "Inflammation"
//        case .normal:   return "Normal"
//        }
//    }
//}

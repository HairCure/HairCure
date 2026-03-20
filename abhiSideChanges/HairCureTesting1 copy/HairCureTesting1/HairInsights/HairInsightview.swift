//
//  HairInsightview.swift
//  HairCureTesting1
//
//  Created by Abhinav Yadav on 21/03/26.
//
//
//  HairInsightsView.swift
//  HairCureTesting1
//
//  Hair Insights main dashboard:
//  • Large navigation title "Hair Insights" (collapses on scroll — iOS 17)
//  • Recommended Hair Care Routine carousel (auto-advance, page dots)
//  • Your Favourites horizontal scroll
//  • Care Tips 2-column grid  → tapping "Care Tips >" pushes list view
//  • Home Remedies horizontal scroll → tapping "Home Remedies >" pushes list view
//  • All sections use iOS 17 scrollTransition


import SwiftUI

// MARK: - Section destination wrappers

struct HairInsightSectionDest: Hashable {
    enum Section: String { case favourites, careTips, homeRemedies, insights }
    let section: Section
}
struct HairInsightItemDest: Hashable  { let id: UUID; let type: String }

// MARK: - Local routine card model (for the Recommended carousel)

private struct RoutineCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let frequency: String
    let description: String
}

// MARK: - Main View

struct HairInsightsView: View {
    @Environment(AppDataStore.self) private var store

    // Navigation state
    @State private var sectionDest: HairInsightSectionDest? = nil
    @State private var itemDest:    HairInsightItemDest?    = nil

    // Carousel state
    @State private var carouselIndex: Int = 0

    // Routine cards (dynamically generated based on user's active plan)
    private var routineCards: [RoutineCard] {
        guard let routine = store.currentHairCareRoutine else { return [] }
        
        let washParts = routine.washFrequency.components(separatedBy: "—")
        let washFreq = washParts.count > 1 ? washParts[0].trimmingCharacters(in: .whitespaces) : ""
        let washDesc = washParts.count > 1 ? washParts[1].trimmingCharacters(in: .whitespaces) : routine.washFrequency
        
        let oilParts = routine.oilingSchedule.components(separatedBy: "—")
        let oilFreq = oilParts.count > 1 ? oilParts[0].trimmingCharacters(in: .whitespaces) : ""
        let oilDesc = oilParts.count > 1 ? oilParts[1].trimmingCharacters(in: .whitespaces) : routine.oilingSchedule
        
        return [
            RoutineCard(icon: "shower.fill", title: "Wash Frequency", frequency: washFreq, description: washDesc),
            RoutineCard(icon: "drop.fill", title: "Oiling Schedule", frequency: oilFreq, description: oilDesc),
            RoutineCard(icon: "bubbles.and.sparkles.fill", title: "Shampoo Type", frequency: "", description: routine.shampooType),
            RoutineCard(icon: "exclamationmark.triangle.fill", title: "Avoidances", frequency: "", description: routine.avoidances.joined(separator: ", "))
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {

                    // ── Recommended Carousel ──
                    recommendedSection
                        .scrollTransition(.animated.threshold(.visible(0.2))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 16)
                        }

                    // ── Your Favourites ──
                    favouritesSection
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.96)
                        }

                    // ── Care Tips ──
                    careTipsSection
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
                        }

                    // ── Home Remedies ──
                    homeRemediesSection
                        .scrollTransition(.animated.threshold(.visible(0.1))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).offset(y: p.isIdentity ? 0 : 20)
                        }

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .scrollBounceBehavior(.basedOnSize)
            .frame(maxWidth: .infinity, maxHeight: .infinity)


            // Native large title — collapses on scroll
            .navigationTitle("Hair Insights")
            .navigationBarTitleDisplayMode(.large)


            // Section list push
            .navigationDestination(item: $sectionDest) { dest in
                HairInsightsListView(section: dest.section)
            }
            // Item detail push
            .navigationDestination(item: $itemDest) { dest in
                HairInsightDetailView(itemId: dest.id, type: dest.type)
            }

            // Auto-advance carousel every 4 s
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(4))
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if !routineCards.isEmpty {
                            carouselIndex = (carouselIndex + 1) % routineCards.count
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recommended Carousel

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recommended")
                    .font(.system(size: 24, weight: .bold))
                Text("Hair Care Routine")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)

            // Swipeable card
            TabView(selection: $carouselIndex) {
                ForEach(Array(routineCards.enumerated()), id: \.element.id) { i, card in
                    RoutineCardView(card: card)
                        .tag(i)
                        .padding(.horizontal, 20)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 110)

            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<routineCards.count, id: \.self) { i in
                    Circle()
                        .fill(i == carouselIndex ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 7, height: 7)
                        .animation(.easeInOut(duration: 0.2), value: carouselIndex)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Your Favourites

    // Unified model so cards can come from any content type
    private struct FavItem: Identifiable {
        let id: UUID
        let title: String
        let imageUrl: String?
        let type: String        // "homeRemedy" | "careTip" | "hairInsight"
    }

    private var favouriteItems: [FavItem] {
        store.userFavorites
            .filter { $0.userId == store.currentUserId }
            .compactMap { fav -> FavItem? in
                switch fav.contentType {
                case "homeRemedy":
                    if let r = store.homeRemedies.first(where: { $0.id == fav.contentId }) {
                        return FavItem(id: r.id, title: r.title, imageUrl: r.mediaURL, type: "homeRemedy")
                    }
                case "careTip":
                    if let t = store.careTips.first(where: { $0.id == fav.contentId }) {
                        return FavItem(id: t.id, title: t.title, imageUrl: t.mediaURL, type: "careTip")
                    }
                case "hairInsight":
                    if let h = store.hairInsights.first(where: { $0.id == fav.contentId }) {
                        return FavItem(id: h.id, title: h.title, imageUrl: h.mediaURL, type: "hairInsight")
                    }
                default: break
                }
                return nil
            }
    }

    private var favouritesSection: some View {
        let items = favouriteItems

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your Favourites", chevron: items.isEmpty ? false : true) {
                sectionDest = HairInsightSectionDest(section: .favourites)
            }
            .padding(.horizontal, 20)

            if items.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No favourites yet")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("Tap the ♥️ on any item to save it here.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(items.prefix(5).enumerated()), id: \.element.id) { i, item in
                            FavouriteThumbCard(
                                label: item.title,
                                imageUrl: item.imageUrl,
                                gradientSeed: i
                            ) {
                                itemDest = HairInsightItemDest(id: item.id, type: item.type)
                            }
                            .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                                c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.88)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                }
            }
        }
    }

    // MARK: - Care Tips

    private var careTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Care Tips", chevron: true) {
                sectionDest = HairInsightSectionDest(section: .careTips)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(store.careTips.prefix(4).enumerated()), id: \.element.id) { i, tip in
                        CareTipCard(tip: tip, gradientSeed: i) {
                            itemDest = HairInsightItemDest(id: tip.id, type: "careTip")
                        }
                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Home Remedies

    private var homeRemediesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Home Remedies", chevron: true) {
                sectionDest = HairInsightSectionDest(section: .homeRemedies)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(store.homeRemedies.enumerated()), id: \.element.id) { i, remedy in
                        RemedyCard(remedy: remedy, gradientSeed: i) {
                            itemDest = HairInsightItemDest(id: remedy.id, type: "homeRemedy")
                        }
                        .scrollTransition(.animated.threshold(.visible(0.05))) { c, p in
                            c.opacity(p.isIdentity ? 1 : 0).scaleEffect(p.isIdentity ? 1 : 0.90)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    let chevron: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                if chevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Routine Card

private struct RoutineCardView: View {
    let card: RoutineCard

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: card.icon)
                .font(.system(size: 24))
                .foregroundColor(.primary.opacity(0.7))
                .frame(width: 42, height: 42)
                .background(Color.secondary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(card.title)
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Text(card.frequency)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Text(card.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.88, green: 0.85, blue: 0.82).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.55, green: 0.40, blue: 0.30).opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Favourite Thumbnail Card  (App Store style)

private struct FavouriteThumbCard: View {
    let label: String
    let imageUrl: String?
    let gradientSeed: Int
    let onTap: () -> Void

    private static let palettes: [[Color]] = [
        [Color(hue: 0.58, saturation: 0.55, brightness: 0.55), Color(hue: 0.62, saturation: 0.45, brightness: 0.35)],
        [Color(hue: 0.08, saturation: 0.60, brightness: 0.55), Color(hue: 0.04, saturation: 0.55, brightness: 0.35)],
        [Color(hue: 0.38, saturation: 0.50, brightness: 0.48), Color(hue: 0.35, saturation: 0.45, brightness: 0.30)],
        [Color(hue: 0.78, saturation: 0.45, brightness: 0.50), Color(hue: 0.75, saturation: 0.40, brightness: 0.32)],
        [Color(hue: 0.12, saturation: 0.55, brightness: 0.52), Color(hue: 0.09, saturation: 0.50, brightness: 0.34)]
    ]

    private var bgGradient: LinearGradient {
        let c = Self.palettes[gradientSeed % Self.palettes.count]
        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Background fill
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 150, height: 170)

                // Full-bleed photo
                if let url = imageUrl, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 150, height: 170)
                        .clipped()
                }

                // Deep bottom gradient vignette (App Store style)
                LinearGradient(
                    stops: [
                        .init(color: .clear,              location: 0.0),
                        .init(color: .black.opacity(0.15), location: 0.45),
                        .init(color: .black.opacity(0.72), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // Title at bottom
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 14)
            }
            .frame(width: 150, height: 170)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Care Tip Card  (App Store style)

private struct CareTipCard: View {
    let tip: CareTip
    let gradientSeed: Int
    let onTap: () -> Void

    private static let categories = ["Scalp Care", "Cleansing", "Styling", "Recovery", "Sleep", "Nutrition"]
    private static let palettes: [[Color]] = [
        [Color(hue: 0.60, saturation: 0.60, brightness: 0.52), Color(hue: 0.65, saturation: 0.50, brightness: 0.30)],
        [Color(hue: 0.06, saturation: 0.65, brightness: 0.55), Color(hue: 0.03, saturation: 0.60, brightness: 0.32)],
        [Color(hue: 0.36, saturation: 0.55, brightness: 0.48), Color(hue: 0.34, saturation: 0.50, brightness: 0.28)],
        [Color(hue: 0.80, saturation: 0.50, brightness: 0.50), Color(hue: 0.77, saturation: 0.45, brightness: 0.30)]
    ]

    private var bgGradient: LinearGradient {
        let c = Self.palettes[gradientSeed % Self.palettes.count]
        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var category: String { Self.categories[gradientSeed % Self.categories.count] }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 175, height: 200)

                // Full-bleed photo
                if let url = tip.mediaURL, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 175, height: 200)
                        .clipped()
                }

                // Gradient vignette
                LinearGradient(
                    stops: [
                        .init(color: .clear,               location: 0.0),
                        .init(color: .black.opacity(0.10),  location: 0.40),
                        .init(color: .black.opacity(0.78),  location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // Text stack
                VStack(alignment: .leading, spacing: 4) {
                    // Eyebrow / category pill
                    Text(category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                        .kerning(0.8)

                    Text(tip.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
            .frame(width: 175, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Remedy Card  (App Store style)

private struct RemedyCard: View {
    let remedy: HomeRemedy
    let gradientSeed: Int
    let onTap: () -> Void

    private static let categories = ["Home Remedy", "Hair Mask", "Scalp Treat", "Oil Therapy"]
    private static let palettes: [[Color]] = [
        [Color(hue: 0.38, saturation: 0.58, brightness: 0.46), Color(hue: 0.35, saturation: 0.52, brightness: 0.26)],
        [Color(hue: 0.07, saturation: 0.65, brightness: 0.54), Color(hue: 0.04, saturation: 0.58, brightness: 0.32)],
        [Color(hue: 0.72, saturation: 0.48, brightness: 0.50), Color(hue: 0.70, saturation: 0.42, brightness: 0.30)],
        [Color(hue: 0.14, saturation: 0.60, brightness: 0.52), Color(hue: 0.11, saturation: 0.55, brightness: 0.30)]
    ]

    private var bgGradient: LinearGradient {
        let c = Self.palettes[gradientSeed % Self.palettes.count]
        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var category: String { Self.categories[gradientSeed % Self.categories.count] }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 175, height: 200)

                // Full-bleed photo
                if let url = remedy.mediaURL, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 175, height: 200)
                        .clipped()
                }

                // Gradient vignette
                LinearGradient(
                    stops: [
                        .init(color: .clear,               location: 0.0),
                        .init(color: .black.opacity(0.12),  location: 0.40),
                        .init(color: .black.opacity(0.80),  location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // Text stack
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                        .kerning(0.8)

                    Text(remedy.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
            .frame(width: 175, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Safe array subscript helper (kept for potential future use)
private extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

#Preview {
    HairInsightsView()
        .environment(AppDataStore())
}

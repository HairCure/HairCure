////
////  HairInsightsView.swift
////  HairCureTesting1
////
////  Hair Insights main dashboard:
////  • Large navigation title "Hair Insights" (collapses on scroll — iOS 17)
////  • Recommended Hair Care Routine carousel (auto-advance, page dots)
////  • Your Favourites horizontal scroll
////  • Care Tips 2-column grid  → tapping "Care Tips >" pushes list view
////  • Home Remedies horizontal scroll → tapping "Home Remedies >" pushes list view
////  • All sections use iOS 17 scrollTransition
//
//
//
//  HairInsightsView.swift
//  HairCure
//
//  Hair Insights main dashboard.
//  Now reads from HairInsightsDataStore instead of AppDataStore.
//

import SwiftUI

// MARK: - Section destination wrappers

struct HairInsightSectionDest: Hashable {
    enum Section: String { case favourites, careTips, homeRemedies, insights }
    let section: Section
}
struct HairInsightItemDest: Hashable { let id: UUID; let type: String }

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
    // ← Changed from AppDataStore to HairInsightsDataStore
    @Environment(HairInsightsDataStore.self) private var store

    // Navigation state
    @State private var sectionDest: HairInsightSectionDest? = nil
    @State private var itemDest:    HairInsightItemDest?    = nil

    // Carousel state
    @State private var carouselIndex: Int = 0

    // Routine cards (static — based on user's active plan)
    private let routineCards: [RoutineCard] = [
        RoutineCard(icon: "shower.fill",     title: "Wash Frequency",  frequency: "2 – 3x per week",  description: "Maintains scalp hydration; avoids barrier damage."),
        RoutineCard(icon: "drop.fill",       title: "Oiling Schedule", frequency: "1 – 2x per week",  description: "Coconut oil reduces protein loss in hair."),
        RoutineCard(icon: "comb.fill",       title: "Gentle Combing",  frequency: "Daily",             description: "Wide-tooth comb on damp hair prevents breakage."),
        RoutineCard(icon: "bed.double.fill", title: "Sleep Routine",   frequency: "7 – 8 hrs / night", description: "Hair cells repair during sleep — maintain a schedule.")
    ]

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
            .navigationTitle("Hair Insights")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(item: $sectionDest) { dest in
                HairInsightsListView(section: dest.section)
            }
            .navigationDestination(item: $itemDest) { dest in
                HairInsightDetailView(itemId: dest.id, type: dest.type)
            }
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(4))
                    withAnimation(.easeInOut(duration: 0.5)) {
                        carouselIndex = (carouselIndex + 1) % routineCards.count
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

            TabView(selection: $carouselIndex) {
                ForEach(Array(routineCards.enumerated()), id: \.element.id) { i, card in
                    RoutineCardView(card: card)
                        .tag(i)
                        .padding(.horizontal, 20)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 110)

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

    private struct FavItem: Identifiable {
        let id: UUID
        let title: String
        let imageUrl: String?
        let type: String        // "homeRemedy" | "careTip" | "hairInsight"
    }

    /// Resolves the current user's favourites to displayable items.
    /// Uses store.currentUserFavorites (convenience on HairInsightsDataStore).
    private var favouriteItems: [FavItem] {
        store.currentUserFavorites.compactMap { fav -> FavItem? in
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
            SectionHeader(title: "Your Favourites", chevron: !items.isEmpty) {
                sectionDest = HairInsightSectionDest(section: .favourites)
            }
            .padding(.horizontal, 20)

            if items.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No favourites yet — tap ♥ on any insight.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { idx, item in
                            FavouriteCard(
                                label:        item.title,
                                imageUrl:     item.imageUrl,
                                gradientSeed: idx
                            ) {
                                itemDest = HairInsightItemDest(id: item.id, type: item.type)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
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
                HStack(spacing: 14) {
                    // Uses store.sortedCareTips (convenience on HairInsightsDataStore)
                    ForEach(Array(store.sortedCareTips.enumerated()), id: \.element.id) { idx, tip in
                        CareTipCard(tip: tip, gradientSeed: idx) {
                            itemDest = HairInsightItemDest(id: tip.id, type: "careTip")
                        }
                    }
                }
                .padding(.horizontal, 20)
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
                HStack(spacing: 14) {
                    ForEach(Array(store.homeRemedies.enumerated()), id: \.element.id) { idx, remedy in
                        RemedyCard(remedy: remedy, gradientSeed: idx) {
                            itemDest = HairInsightItemDest(id: remedy.id, type: "homeRemedy")
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Routine Card View (unchanged)

private struct RoutineCardView: View {
    let card: RoutineCard   // same type declared above

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: card.icon)
                .font(.system(size: 28))
                .foregroundColor(.primary.opacity(0.75))
                .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(card.frequency)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.accentColor)
                Text(card.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Section Header  (unchanged)

private struct SectionHeader: View {
    let title:   String
    let chevron: Bool
    let onTap:   () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                if chevron {
                    HStack(spacing: 4) {
                        Text("See all")
                            .font(.system(size: 14))
                            .foregroundColor(.accentColor)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Favourite Card  (App Store style — unchanged)

private struct FavouriteCard: View {
    let label:        String
    let imageUrl:     String?
    let gradientSeed: Int
    let onTap:        () -> Void

    private static let palettes: [[Color]] = [
        [Color(red:0.22,green:0.45,blue:0.32), Color(red:0.12,green:0.30,blue:0.20)],
        [Color(red:0.58,green:0.32,blue:0.22), Color(red:0.38,green:0.18,blue:0.10)],
        [Color(red:0.28,green:0.42,blue:0.60), Color(red:0.14,green:0.26,blue:0.46)],
        [Color(red:0.50,green:0.38,blue:0.22), Color(red:0.32,green:0.22,blue:0.10)]
    ]

    private var bgGradient: LinearGradient {
        let c = Self.palettes[gradientSeed % Self.palettes.count]
        return LinearGradient(colors: c, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 150, height: 170)

                if let url = imageUrl, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 150, height: 170)
                        .clipped()
                }

                LinearGradient(
                    stops: [
                        .init(color: .clear,               location: 0.0),
                        .init(color: .black.opacity(0.15), location: 0.45),
                        .init(color: .black.opacity(0.72), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

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

// MARK: - Care Tip Card  (App Store style — unchanged)

private struct CareTipCard: View {
    let tip:          CareTip
    let gradientSeed: Int
    let onTap:        () -> Void

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
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 175, height: 200)

                if let url = tip.mediaURL, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 175, height: 200)
                        .clipped()
                }

                LinearGradient(
                    stops: [
                        .init(color: .clear,               location: 0.0),
                        .init(color: .black.opacity(0.10), location: 0.40),
                        .init(color: .black.opacity(0.78), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
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

// MARK: - Remedy Card  (App Store style — unchanged)

private struct RemedyCard: View {
    let remedy:       HomeRemedy
    let gradientSeed: Int
    let onTap:        () -> Void

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
                RoundedRectangle(cornerRadius: 20)
                    .fill(bgGradient)
                    .frame(width: 175, height: 200)

                if let url = remedy.mediaURL, let img = UIImage(named: url) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 175, height: 200)
                        .clipped()
                }

                LinearGradient(
                    stops: [
                        .init(color: .clear,               location: 0.0),
                        .init(color: .black.opacity(0.12), location: 0.40),
                        .init(color: .black.opacity(0.80), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

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

#Preview {
    HairInsightsView()
        .environment(HairInsightsDataStore(currentUserId: UUID()))
}

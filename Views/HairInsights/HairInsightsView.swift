
import SwiftUI

// MARK: - HairInsightsView

struct HairInsightsView: View {
    
    @Environment(AppDataStore.self) private var store
    
    @State private var routineScrollPosition = ScrollPosition(idType: Int.self)
    
    // computed property
    private var insightStore: HairInsightsDataStore { store.hairInsightsStore }
    private var userPlan: UserPlan? { store.activePlan }
    
    private var routineCards: [RecommendationEngine.HairCareRoutine] {
        if let plan = userPlan {
            return RecommendationEngine.buildHairCareRoutine(for: plan)
        }
        
        let defaultPlan = UserPlan(
            id: UUID(), userId: store.currentUserId,
            scanReportId: UUID(),
            planId: "2A",
            stage: 2, lifestyleProfile: .poor,
            scalpModifier: .oily,
            meditationMinutesPerDay: 10, yogaMinutesPerDay: 15,
            soundMinutesPerDay: 10, sessionFrequencyPerWeek: 5,
            isActive: false,
            assignedAt: Date(),
            expiresAt: Date()
        )
        return RecommendationEngine.buildHairCareRoutine(for: defaultPlan)
    }
    
    private var allFavourites: [AnyFavouriteItem] {
        insightStore.allFavourites()
    }
    
    private var routineIndex: Int {
        routineScrollPosition.viewID(type: Int.self) ?? 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    routineSection
                    favouritesSection
                    careTipsSection
                    homeRemediesSection
                    Spacer(minLength: 20)
                }
            }
            .background(Color.hcCream.ignoresSafeArea())
            .navigationTitle("Hair Insights")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Routine Section
    
    private var routineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Recommended")
                    .font(.title3.bold())
                    .foregroundStyle(.black)
                Text("Hair Care Routine")
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.55))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(routineCards.indices, id: \.self) { i in
                        RoutineCardView(routine: routineCards[i])
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                            .id(i)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 20, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition($routineScrollPosition)
            
            HStack(spacing: 6) {
                ForEach(routineCards.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == routineIndex ? Color.black : Color.black.opacity(0.18))
                        .frame(width: i == routineIndex ? 18 : 7, height: 7)
                        .animation(.spring(duration: 0.35), value: routineIndex)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Favourites Section
    
    private var favouritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            NavigationLink {
                FavouritesListView(insightStore: insightStore, userPlan: userPlan)
            } label: {
                HStack {
                    Text("Your Favourites")
                        .font(.title3.bold())
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundStyle(.black.opacity(0.5))
                }
                .padding(.horizontal, 20)
            }
            
            if allFavourites.isEmpty {
                EmptyFavouritesView()
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(allFavourites) { item in
                            NavigationLink {
                                destinationView(for: item)
                            } label: {
                                FavouriteCardView(item: item)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Care Tips Section
    
    private var careTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
           
            NavigationLink {
                CareTipsListView(insightStore: insightStore)
            } label: {
                HStack {
                    Text("Care Tips")
                        .font(.title3.bold())
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundStyle(.black.opacity(0.5))
                }
                .padding(.horizontal, 20)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(insightStore.careTips.filter(\.isActive)) { tip in
                        NavigationLink {
                            
                            CareTipDetailView(tip: tip, insightStore: insightStore)
                        } label: {
                            InsightMediaCardView(
                                title: tip.title,
                                mediaURL: tip.mediaURL
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Home Remedies Section
    
    private var homeRemediesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            NavigationLink {
                HomeRemediesListView(insightStore: insightStore)
            } label: {
                HStack {
                    Text("Home Remedies")
                        .font(.title3.bold())
                        .foregroundStyle(.black)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.bold())
                        .foregroundStyle(.black.opacity(0.5))
                }
                .padding(.horizontal, 20)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(insightStore.homeRemedies.filter(\.isActive)) { remedy in
                        NavigationLink {
                            // userId removed
                            HomeRemedyDetailView(remedy: remedy, insightStore: insightStore)
                        } label: {
                            InsightMediaCardView(
                                title: remedy.title,
                                mediaURL: remedy.mediaURL
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Destination Router
   
    @ViewBuilder 
    
    private func destinationView(for item: AnyFavouriteItem) -> some View {
        switch item {
        case .careTip(let t):
            CareTipDetailView(tip: t, insightStore: insightStore)
        case .remedy(let r):
            HomeRemedyDetailView(remedy: r, insightStore: insightStore)
        }
    }
}

// MARK: - RoutineCardView

struct RoutineCardView: View {
    let routine: RecommendationEngine.HairCareRoutine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.hcBrown.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: routine.iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(Color.hcBrown)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(routine.cardHeading)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                    Text(routine.applyingFrequency)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.hcBrown)
                }
                Spacer()
            }
            
            Text(routine.summary)
                .font(.system(size: 13))
                .foregroundStyle(.black.opacity(0.55))
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hcBrown.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.hcBrown.opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - InsightMediaCardView

struct InsightMediaCardView: View {
    let title: String
    let mediaURL: String?
    
    private let cardWidth: CGFloat = 160
    private let imageHeight: CGFloat = 140
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color(.systemGray5)
                if let imageName = mediaURL {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: imageHeight)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            .frame(width: cardWidth, height: imageHeight)
            .clipped()
            
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 36)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 10)
        }
        .frame(width: cardWidth)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - FavouriteCardView

struct FavouriteCardView: View {
    let item: AnyFavouriteItem
    
    private let cardWidth: CGFloat = 140
    private let imageHeight: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color(.systemGray5)
                if let imageName = item.mediaURL {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: imageHeight)
                        .clipped()
                } else {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            .frame(width: cardWidth, height: imageHeight)
            .clipped()
            
            Text(item.title)
                .font(.caption.bold())
                .foregroundStyle(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(height: 30)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 10)
        }
        .frame(width: cardWidth)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - EmptyFavouritesView

struct EmptyFavouritesView: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "heart")
                .font(.title2)
                .foregroundStyle(Color(.systemGray3))
            Text("Tap ♡ on any tip or remedy to save it here.")
                .font(.subheadline)
                .foregroundStyle(.black.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
// MARK: - Preview

#Preview {
    let store = AppDataStore()
    return HairInsightsView()
        .environment(store)
}

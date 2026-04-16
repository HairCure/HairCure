//
//  InsightsTab.swift
//  hairInsightTesting
//
//  Created by Avnish Singh on 4/16/26.
//


import SwiftUI

struct InsightsTab: View {
    var vm: HairInsightsViewModel
    var onTapTip:     (CareTip)        -> Void
    var onTapRemedy:  (HomeRemedy)     -> Void
    var onTapRoutine: (HairCareRoutine)-> Void

    @State private var routinePage = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Title ──
                Text("Hair Insights")
                    .font(.custom("Georgia-Bold", size: 40))
                    .foregroundColor(.hiInk)
                    .padding(.horizontal, 22)
                    .padding(.top, 22)
                    .padding(.bottom, 4)

                // ── Status ──
                switch vm.status {
                case .loading: LoaderView()
                case .error:   ErrorView(msg: vm.errorMsg)
                case .ok:
                    VStack(alignment: .leading, spacing: 0) {
                        // Recommended routines
                        SectionHeader(label: "Recommended", sub: "Hair Care Routine")
                        RoutineCarousel(routines: vm.routines, favs: vm.favourites, toggleFav: vm.toggleFav, onTap: onTapRoutine)

                        // Favourites
                        SectionHeader(label: "Your Favourites", showArrow: true)
                        FavouritesRow(tips: vm.favTips, remedies: vm.favRemedies,
                                      onTapTip: onTapTip, onTapRemedy: onTapRemedy)

                        // Care Tips
                        SectionHeader(label: "Care Tips", showArrow: true)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(vm.tips) { tip in
                                    ImgCard(title: tip.title ?? "",
                                            imageKey: tip.imageKey,
                                            frequency: tip.frequency,
                                            isFav: vm.favourites.contains(tip.id),
                                            onFav: { vm.toggleFav(tip.id) },
                                            onTap: { onTapTip(tip) })
                                }
                                if vm.tips.isEmpty { EmptySlotView(label: "No care tips yet") }
                            }
                            .padding(.horizontal, 22)
                            .padding(.vertical, 2)
                        }

                        // Home Remedies
                        SectionHeader(label: "Home Remedies", showArrow: true)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(vm.remedies) { rem in
                                    ImgCard(title: rem.title ?? "",
                                            imageKey: rem.imageKey,
                                            frequency: rem.frequency,
                                            isFav: vm.favourites.contains(rem.id),
                                            tall: true,
                                            onFav: { vm.toggleFav(rem.id) },
                                            onTap: { onTapRemedy(rem) })
                                }
                                if vm.remedies.isEmpty { EmptySlotView(label: "No remedies yet") }
                            }
                            .padding(.horizontal, 22)
                            .padding(.vertical, 2)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let label: String
    var sub: String?     = nil
    var showArrow: Bool  = false

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.hiInk)
                if let sub {
                    Text(sub)
                        .font(.system(size: 13))
                        .foregroundColor(.hiMuted)
                }
            }
            Spacer()
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.hiMuted)
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 26)
        .padding(.bottom, 10)
    }
}

// MARK: - Routine Carousel
struct RoutineCarousel: View {
    let routines:  [HairCareRoutine]
    let favs:      Set<UUID>
    let toggleFav: (UUID) -> Void
    let onTap:     (HairCareRoutine) -> Void

    @State private var page = 0

    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(routines) { r in
                        RoutineCard(routine: r,
                                    isFav: favs.contains(r.id),
                                    onFav: { toggleFav(r.id) },
                                    onTap: { onTap(r) })
                    }
                    if routines.isEmpty { EmptySlotView(label: "No routines yet") }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 2)
            }

            // Page dots
            if routines.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<routines.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? Color.hiInk : Color.hiBorder)
                            .frame(width: i == page ? 22 : 7, height: 7)
                            .animation(.easeInOut(duration: 0.3), value: page)
                    }
                }
            }
        }
    }
}

// MARK: - Routine Card
struct RoutineCard: View {
    let routine: HairCareRoutine
    let isFav:   Bool
    let onFav:   () -> Void
    let onTap:   () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                // Icon bubble
                ZStack {
                    Circle()
                        .fill(Color.hiWarm)
                        .frame(width: 50, height: 50)
                    Image(systemName: iconSF(routine.iconName))
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#7C5A3A"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.cardHeading ?? "Routine")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.hiInk)
                        .multilineTextAlignment(.leading)

                    if let freq = routine.applyingFrequency {
                        Text(fmtFreq(freq))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.hiAccent)
                    }

                    if let summary = routine.summary {
                        Text(summary)
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "#716860"))
                            .lineSpacing(3)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(width: 316)
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.07), radius: 9, x: 0, y: 2)
            .overlay(alignment: .topTrailing) {
                Button(action: onFav) {
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundColor(isFav ? .hiRed : .hiMuted)
                        .padding(4)
                }
                .padding(12)
            }
        }
        .buttonStyle(.plain)
    }

    func iconSF(_ name: String?) -> String {
        switch name {
        case "leaf.arrow.circlepath":   return "leaf.arrow.circlepath"
        case "arrow.up.forward.circle": return "arrow.up.forward.circle"
        case "drop.fill":               return "drop.fill"
        default:                        return "sparkles"
        }
    }
}

// MARK: - Image Card
struct ImgCard: View {
    let title:    String
    let imageKey: String
    let frequency: String?
    let isFav:    Bool
    var tall:     Bool   = false
    let onFav:    () -> Void
    let onTap:    () -> Void

    var cardHeight: CGFloat { tall ? 215 : 200 }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: resolvedImageURL(imageKey)) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            Color.hiWarm
                        }
                    }
                    .frame(height: cardHeight * 0.65)
                    .clipped()

                    Button(action: onFav) {
                        Image(systemName: isFav ? "heart.fill" : "heart")
                            .font(.system(size: 13))
                            .foregroundColor(isFav ? .hiRed : .hiMuted)
                            .padding(7)
                            .background(Color.white.opacity(0.88))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.hiInk)
                        .lineLimit(2)
                    if let freq = frequency {
                        Text(fmtFreq(freq))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.hiAccent)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .frame(width: 165, height: cardHeight)
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.07), radius: 7, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Favourites Row
struct FavouritesRow: View {
    let tips:      [CareTip]
    let remedies:  [HomeRemedy]
    let onTapTip:    (CareTip)    -> Void
    let onTapRemedy: (HomeRemedy) -> Void

    var body: some View {
        if tips.isEmpty && remedies.isEmpty {
            HStack(spacing: 12) {
                Image(systemName: "heart")
                    .foregroundColor(.secondary)
                Text("Tap ♡ on any tip or remedy to save it here.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 22)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(tips) { t in
                        MiniCard(title: t.title ?? "", imageKey: t.imageKey)
                            .onTapGesture { onTapTip(t) }
                    }
                    ForEach(remedies) { r in
                        MiniCard(title: r.title ?? "", imageKey: r.imageKey)
                            .onTapGesture { onTapRemedy(r) }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - Mini Card
struct MiniCard: View {
    let title:    String
    let imageKey: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: resolvedImageURL(imageKey)) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { Color.hiWarm }
            }
            .frame(height: 100)
            .clipped()

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.hiInk)
                .lineLimit(2)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
        }
        .frame(width: 120, height: 148)
        .background(.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Empty Slot
struct EmptySlotView: View {
    let label: String
    var body: some View {
        Text(label)
            .font(.system(size: 13))
            .foregroundColor(.hiMuted)
            .frame(width: 180, height: 180)
            .background(Color.hiWarm)
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Loader
struct LoaderView: View {
    @State private var rotating = false
    var body: some View {
        VStack(spacing: 14) {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.hiAccent, lineWidth: 3)
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(rotating ? 360 : 0))
                .onAppear { withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) { rotating = true } }
            Text("Fetching from Supabase…")
                .font(.system(size: 14))
                .foregroundColor(.hiMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

// MARK: - Error
struct ErrorView: View {
    let msg: String
    var body: some View {
        VStack(spacing: 10) {
            Text("⚠️").font(.system(size: 36))
            Text("Could not load data")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(hex: "#C0503A"))
            Text(msg)
                .font(.system(size: 12))
                .foregroundColor(.hiMuted)
                .multilineTextAlignment(.center)
            Text("Check RLS policies and that tables have is_active rows")
                .font(.system(size: 11))
                .foregroundColor(.hiMuted)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
    }
}

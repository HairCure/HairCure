//
//  DetailHero.swift
//  hairInsightTesting
//
//  Created by Avnish Singh on 4/16/26.
//


import SwiftUI

// MARK: - Shared Detail Components

struct DetailHero: View {
    let imageKey: String?
    let isRoutine: Bool
    let iconName: String?
    let category: String?
    let title: String
    let isFav: Bool
    let onBack: () -> Void
    let onFav:  () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            if isRoutine {
                Color.hiWarm
                    .frame(height: 270)
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 90, height: 90)
                    Image(systemName: iconSF(iconName))
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "#7C5A3A"))
                }
            } else {
                AsyncImage(url: resolvedImageURL(imageKey)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.hiWarm
                    }
                }
                .frame(height: 270)
                .clipped()
                LinearGradient(
                    colors: [.black.opacity(0.25), .clear, .black.opacity(0.5)],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 270)
            }

            // Title block
            VStack(alignment: .leading, spacing: 4) {
                if let cat = category {
                    Text(cat.replacingOccurrences(of: "_", with: " ").uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isRoutine ? .hiMuted : .white.opacity(0.75))
                        .kerning(1.2)
                }
                Text(title)
                    .font(.custom("Georgia-Bold", size: 21))
                    .foregroundColor(isRoutine ? .hiInk : .white)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 14)
        }
        .frame(height: 270)
        .overlay(alignment: .topLeading) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.hiInk)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.88))
                    .clipShape(Circle())
            }
            .padding(.top, 54)
            .padding(.leading, 18)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onFav) {
                Image(systemName: isFav ? "heart.fill" : "heart")
                    .font(.system(size: 16))
                    .foregroundColor(isFav ? .hiRed : .hiInk)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.88))
                    .clipShape(Circle())
            }
            .padding(.top, 54)
            .padding(.trailing, 18)
        }
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

struct MetaPill: View {
    let label: String
    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.hiAccent)
            .padding(.horizontal, 11)
            .padding(.vertical, 4)
            .background(Color(hex: "#EFE9DF"))
            .clipShape(Capsule())
    }
}

struct DetailBlock<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.hiInk)
            content()
        }
        .padding(.bottom, 20)
    }
}

struct StepRow: View {
    let index: Int
    let step: Int?
    let title: String?
    let instruction: String?
    var tip: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(step ?? index + 1)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.hiAccent)
                .frame(width: 24, height: 24)
                .background(Color.hiWarm)
                .clipShape(Circle())
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 3) {
                if let t = title {
                    Text(t)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.hiInk)
                }
                if let ins = instruction {
                    Text(ins)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#655D55"))
                        .lineSpacing(3)
                }
                if let tip {
                    Text("💡 \(tip)")
                        .font(.system(size: 11).italic())
                        .foregroundColor(.hiAccent)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color(hex: "#F8F4EE"))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 4)
                }
            }
        }
        .padding(.bottom, 14)
    }
}

struct PrecautionBlock: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(Color(hex: "#E0A060"))
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 5) {
                Text("PRECAUTIONS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#C07030"))
                    .kerning(0.8)
                Text(text)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#7A5A40"))
                    .lineSpacing(3)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(hex: "#FFF8F0"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.bottom, 18)
    }
}

struct SourceBlock: View {
    let item: (name: String, url: String?, type: String?)
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(Color.hiAccent)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 5) {
                Text((item.type ?? "source").replacingOccurrences(of: "_", with: " ").uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.hiAccent)
                    .kerning(1)
                Text(item.name)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#7A6A5A"))
                    .lineSpacing(3)
                if let url = item.url, let link = URL(string: url) {
                    Link("View research →", destination: link)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.hiAccent)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(hex: "#F4F0E9"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Care Tip Detail
struct DetailTipView: View {
    let tip: CareTip
    var vm: HairInsightsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                DetailHero(imageKey: tip.imageKey, isRoutine: false, iconName: nil,
                           category: nil, title: tip.title ?? "Tip",
                           isFav: vm.favourites.contains(tip.id),
                           onBack: { dismiss() }, onFav: { vm.toggleFav(tip.id) })

                VStack(alignment: .leading, spacing: 0) {
                    // Pills
                    if let freq = tip.frequency {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 7) {
                                MetaPill(label: fmtFreq(freq))
                            }.padding(.horizontal, 20).padding(.bottom, 16)
                        }
                    }

                    // Description
                    if let desc = tip.tipDescription {
                        Text(desc)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#655D55"))
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 18)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        if let benefits = tip.benefits {
                            DetailBlock(title: "Benefits") {
                                Text(benefits)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#655D55"))
                                    .lineSpacing(3)
                            }
                        }

                        if let steps = tip.howToUse, !steps.isEmpty {
                            DetailBlock(title: "How to Use") {
                                ForEach(Array(steps.enumerated()), id: \.offset) { i, s in
                                    StepRow(index: i, step: s.step, title: s.title, instruction: s.instruction)
                                }
                            }
                        }

                        if let avoid = tip.whatToAvoid {
                            DetailBlock(title: "What to Avoid") {
                                Text(avoid)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#655D55"))
                                    .lineSpacing(3)
                            }
                        }

                        if let prec = tip.precautions { PrecautionBlock(text: prec) }

                        if let name = tip.sourceName {
                            SourceBlock(item: (name: name, url: tip.sourceUrl, type: tip.sourceType))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .background(Color.hiBackground)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.hiBackground)
    }
}

// MARK: - Home Remedy Detail
struct DetailRemedyView: View {
    let remedy: HomeRemedy
    var vm: HairInsightsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                DetailHero(imageKey: remedy.imageKey, isRoutine: false, iconName: nil,
                           category: nil, title: remedy.title ?? "Remedy",
                           isFav: vm.favourites.contains(remedy.id),
                           onBack: { dismiss() }, onFav: { vm.toggleFav(remedy.id) })

                VStack(alignment: .leading, spacing: 0) {
                    // Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            if let freq = remedy.frequency { MetaPill(label: fmtFreq(freq)) }
                            if let mins = remedy.leaveonDurationMinutes { MetaPill(label: "Leave \(mins) min") }
                        }.padding(.horizontal, 20).padding(.bottom, 16)
                    }

                    if let desc = remedy.remedyDescription {
                        Text(desc)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#655D55"))
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 18)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        if let benefits = remedy.benefits {
                            DetailBlock(title: "Benefits") {
                                Text(benefits)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#655D55"))
                                    .lineSpacing(3)
                            }
                        }

                        if let ings = remedy.ingredients, !ings.isEmpty {
                            DetailBlock(title: "Ingredients") {
                                ForEach(Array(ings.enumerated()), id: \.offset) { i, g in
                                    VStack {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(g.name ?? "").font(.system(size: 13, weight: .semibold)).foregroundColor(.hiInk)
                                                if let notes = g.notes {
                                                    Text(notes).font(.system(size: 11)).foregroundColor(.hiMuted)
                                                }
                                            }
                                            Spacer()
                                            Text("\(g.quantity ?? "")\(g.unit.map { " \($0)" } ?? "")")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.hiAccent)
                                                .padding(.horizontal, 9)
                                                .padding(.vertical, 3)
                                                .background(Color(hex: "#EFE9DF"))
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        .padding(.vertical, 8)
                                        if i < ings.count - 1 {
                                            Divider().background(Color.hiBorder)
                                        }
                                    }
                                }
                            }
                        }

                        if let make = remedy.howToMake, !make.isEmpty {
                            DetailBlock(title: "How to Make") {
                                ForEach(Array(make.enumerated()), id: \.offset) { i, s in
                                    StepRow(index: i, step: s.step, title: s.title, instruction: s.instruction)
                                }
                            }
                        }

                        if let apply = remedy.howToApply, !apply.isEmpty {
                            DetailBlock(title: "How to Apply") {
                                ForEach(Array(apply.enumerated()), id: \.offset) { i, s in
                                    StepRow(index: i, step: s.step, title: s.title, instruction: s.instruction)
                                }
                            }
                        }

                        if let avoid = remedy.whatToAvoid {
                            DetailBlock(title: "What to Avoid") {
                                Text(avoid)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#655D55"))
                                    .lineSpacing(3)
                            }
                        }

                        if let prec = remedy.precautions { PrecautionBlock(text: prec) }
                        if let name = remedy.sourceName {
                            SourceBlock(item: (name: name, url: remedy.sourceUrl, type: remedy.sourceType))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .background(Color.hiBackground)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.hiBackground)
    }
}

// MARK: - Routine Detail
struct DetailRoutineView: View {
    let routine: HairCareRoutine
    var vm: HairInsightsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                DetailHero(imageKey: nil, isRoutine: true, iconName: routine.iconName,
                           category: nil, title: routine.cardHeading ?? "Routine",
                           isFav: vm.favourites.contains(routine.id),
                           onBack: { dismiss() }, onFav: { vm.toggleFav(routine.id) })

                VStack(alignment: .leading, spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            if let freq = routine.applyingFrequency  { MetaPill(label: fmtFreq(freq)) }
                            if let dur  = routine.durationWeeks       { MetaPill(label: "\(dur) wks") }
                            if let diff = routine.difficultyLevel     { MetaPill(label: diff) }
                            if let mins = routine.estimatedTimeMinutes { MetaPill(label: "~\(mins) min") }
                        }.padding(.horizontal, 20).padding(.bottom, 16)
                    }

                    if let summary = routine.summary {
                        Text(summary)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#655D55"))
                            .lineSpacing(4)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 18)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        if let products = routine.productsNeeded, !products.isEmpty {
                            DetailBlock(title: "What You Need") {
                                FlowLayout(spacing: 8) {
                                    ForEach(products) { p in
                                        Text("\(p.name ?? "")\(p.optional == true ? " (optional)" : "")")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(p.optional == true ? .hiMuted : .hiAccent)
                                            .padding(.horizontal, 11)
                                            .padding(.vertical, 5)
                                            .background(p.optional == true ? Color.hiWarm : Color(hex: "#EFE9DF"))
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule().stroke(p.optional == true ? Color.hiBorder : Color.clear, lineWidth: 0.5)
                                            )
                                    }
                                }
                            }
                        }

                        if let steps = routine.steps, !steps.isEmpty {
                            DetailBlock(title: "Routine Steps") {
                                ForEach(Array(steps.enumerated()), id: \.offset) { i, s in
                                    StepRow(index: i, step: s.step, title: s.title, instruction: s.instruction, tip: s.tip)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .background(Color.hiBackground)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.hiBackground)
    }
}

// MARK: - Simple Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0, y: CGFloat = 0, maxH: CGFloat = 0
        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 { y += maxH + spacing; x = 0; maxH = 0 }
            x += size.width + spacing; maxH = max(maxH, size.height)
        }
        return CGSize(width: width, height: y + maxH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, maxH: CGFloat = 0
        for sv in subviews {
            let size = sv.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX { y += maxH + spacing; x = bounds.minX; maxH = 0 }
            sv.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing; maxH = max(maxH, size.height)
        }
    }
}

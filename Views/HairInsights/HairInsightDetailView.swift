import SwiftUI
import AVKit

// MARK: - HomeRemedyDetailView

struct HomeRemedyDetailView: View {
    let remedy: HomeRemedy
    let insightStore: HairInsightsDataStore  // let, not var

    @State private var isPlaying: Bool = false
    @State private var progress: Double = 0.0
    @State private var playbackTask: Task<Void, Never>?
    @State private var showResearch = false

    private var isFav: Bool {
        insightStore.isFavorite(contentId: remedy.id)
    }

    private var researchURL: URL? {
        let title = remedy.title.lowercased()
        if title.contains("aloe") {
            return URL(string: "https://www.healthline.com/health/aloe-vera-hair-mask")
        } else if title.contains("onion") {
            return URL(string: "https://pubmed.ncbi.nlm.nih.gov/12126069/")
        } else if title.contains("egg") {
            return URL(string: "https://www.medicalnewstoday.com/articles/321971")
        }
        return nil
    }

    private var researchTitle: String {
        let title = remedy.title.lowercased()
        if title.contains("aloe") {
            return "Aloe Vera for Hair "
        } else if title.contains("onion") {
            return "Onion Juice for Alopecia "
        } else if title.contains("egg") {
            return "Egg for Hair"
        }
        return "Research Reference"
    }

    private var totalDuration: Double {
        Double(remedy.videoDurationSeconds ?? 120)
    }

    private var currentTimeString: String { formatTime(Int(progress)) }
    private var totalTimeString: String    { formatTime(remedy.videoDurationSeconds ?? 120) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Hero / Video area
                ZStack(alignment: .center) {
                    if let imageName = remedy.mediaURL {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 280)
                            .overlay(
                                Image(systemName: "play.rectangle")
                                    .font(.system(size: 60))
                                    .foregroundStyle(Color(.systemGray2))
                            )
                    }

                    Button {
                        togglePlayback()
                    } label: {
                        Circle()
                            .fill(Color.black.opacity(0.65))
                            .frame(width: 64, height: 64)
                            .overlay(
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            )
                    }
                }

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Favourite + Scrubber row
                    HStack {
                        Spacer()
                        Button {
                            insightStore.toggleFavorite(contentId: remedy.id)
                        } label: {
                            Image(systemName: isFav ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isFav ? .red : Color(.systemGray2))
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)

                    // Scrubber
                    VStack(spacing: 6) {
                        Slider(value: $progress, in: 0...totalDuration) { editing in
                            if editing {
                                // iOS 18: cancel task directly — no stopTimer() needed
                                playbackTask?.cancel()
                                playbackTask = nil
                            } else if isPlaying {
                                startPlaybackTask()
                            }
                        }
                        .tint(.primary)

                        HStack {
                            Text(currentTimeString)
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(totalTimeString)
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    // MARK: Title & Body
                    Text("Give your hair a natural boost with \(remedy.title.lowercased().components(separatedBy: " ").first ?? "").")
                        .font(.title3.bold())
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    Text(remedy.benefits)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    Divider()
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    Text("How to use")
                        .font(.headline)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Text(remedy.instructions)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 6)

                    Spacer(minLength: 40)
                }
            }
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle(remedy.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if researchURL != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showResearch = true } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(Color.hcBrown)
                    }
                }
            }
        }
        .sheet(isPresented: $showResearch) {
            if let url = researchURL {
                NavigationStack {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.hcBrown)
                        Text("Research Reference")
                            .font(.title3.bold())
                        Text(researchTitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Link(destination: url) {
                            Text("Open Study")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.hcBrown)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(24)
                    .navigationTitle("Reference")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showResearch = false }
                                .fontWeight(.semibold)
                        }
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
        
        .task(id: isPlaying) {
            guard isPlaying else { return }
            await runPlayback()
        }
    }

    // MARK: Playback helpers (structured concurrency)

    private func togglePlayback() {
        if isPlaying {
            isPlaying = false
            playbackTask?.cancel()
            playbackTask = nil
        } else {
            isPlaying = true
            startPlaybackTask()
        }
    }

    private func startPlaybackTask() {
        playbackTask?.cancel()
        playbackTask = Task { await runPlayback() }
    }

    private func runPlayback() async {
        while progress < totalDuration {
            try? await Task.sleep(for: .milliseconds(500))
            if Task.isCancelled { return }
            progress = min(progress + 0.5, totalDuration)
        }
        // Reached end
        isPlaying = false
        playbackTask = nil
    }

    private func formatTime(_ seconds: Int) -> String {
        String(format: "%02d : %02d", seconds / 60, seconds % 60)
    }
}

// MARK: - CareTipDetailView

struct CareTipDetailView: View {
    let tip: CareTip
    let insightStore: HairInsightsDataStore 

    @State private var showResearch = false

    private var isFav: Bool {
        insightStore.isFavorite(contentId: tip.id)
    }

    private var researchURL: URL? {
        let title = tip.title.lowercased()
        if title.contains("oil massage") {
            return URL(string: "https://pmc.ncbi.nlm.nih.gov/articles/PMC4740347/")
        } else if title.contains("silk") || title.contains("pillowcase") {
            return URL(string :"https://www.triprinceton.org/post/everyone-is-talking-about-silk-pillowcases")
        } else if title.contains("cold water") || title.contains("cold rinse") {
            return URL(string: "https://www.hims.com/blog/is-cold-water-good-for-hair")
        } else if title.contains("scalp massage") {
            return URL(string: "https://pmc.ncbi.nlm.nih.gov/articles/PMC4740347/")
        }
        return nil
    }

    private var researchTitle: String {
        let title = tip.title.lowercased()
        if title.contains("oil massage") || title.contains("scalp massage") {
            return "Scalp Massage & Hair Thickness"
        } else if title.contains("silk") || title.contains("pillowcase") {
            return "Use of Silk Pillowcase"
        } else if title.contains("cold water") || title.contains("cold rinse") {
            return "Water Temperature & Hair Shine — TRI Princeton"
        }
        return "Research Reference"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Hero
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 240)

                    if let imageName = tip.mediaURL {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 240)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    } else {
                        Image(systemName: "leaf")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(.systemGray3))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {

                    // Fav button
                    HStack {
                        Spacer()
                        Button {
                            insightStore.toggleFavorite(contentId: tip.id)
                        } label: {
                            Image(systemName: isFav ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isFav ? .red : Color(.systemGray2))
                        }
                    }
                    .padding(.top, 12)

                    Text(tip.title)
                        .font(.title3.bold())

                    Text(tip.tipDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 40)
            }
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle(tip.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if researchURL != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showResearch = true } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(Color.hcBrown)
                    }
                }
            }
        }
        .sheet(isPresented: $showResearch) {
            if let url = researchURL {
                NavigationStack {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.hcBrown)
                        Text("Research Reference")
                            .font(.title3.bold())
                        Text(researchTitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Link(destination: url) {
                            Text("Open Study")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.hcBrown)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(24)
                    .navigationTitle("Reference")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showResearch = false }
                                .fontWeight(.semibold)
                        }
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
        }
    }
}


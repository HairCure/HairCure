//
//  HairAnalysisView..swift
//  HairCureTesting
//
//  Created by Abhinav Yadav on 19/03/26.
//

//
//  HairAnalysisView.swift
//  HairCure
//
//  Two-path hair analysis screen:
//
//  Path A (AI scan):
//    User uploads up to 5 scalp photos → taps Continue
//    → store.submitScanImages() → mock AI → engine runs → onComplete()
//
//  Path B (Self-assessed fallback):
//    User taps Skip on photo screen
//    → 3 fallback questions (stage / scalp / density)
//    → store.submitSelfAssessedStage() → engine runs → onComplete()
//
//  onComplete() is called with the ActionResult so the parent
//  can navigate to PlanResultsView.
//
//
//import SwiftUI
//import PhotosUI
//
//// MARK: - Photo slot model
//
//private enum PhotoSlot: String, CaseIterable {
//    case front = "Front View"
//    case back  = "Back View"
//    case left  = "Left View"
//    case right = "Right View"
//    case top   = "Top View"
//
//    var systemIcon: String { "camera" }
//
//    var mockURL: String {
//        switch self {
//        case .front: return "arjun_front.jpg"
//        case .back:  return "arjun_back.jpg"
//        case .left:  return "arjun_left.jpg"
//        case .right: return "arjun_right.jpg"
//        case .top:   return "arjun_top.jpg"
//        }
//    }
//}
//
//// MARK: - Shared analysis state
//
//private enum AnalysisPath {
//    case photoUpload
//    case fallback
//}
//
//// MARK: - Main container
//
//struct HairAnalysisView: View {
//    @Environment(AppDataStore.self) private var store
//    let onComplete: (ActionResult) -> Void
//
//    @State private var path: AnalysisPath = .photoUpload
//
//    var body: some View {
//        Group {
//            switch path {
//            case .photoUpload:
//                PhotoUploadView(
//                    onSkip:     { withAnimation { path = .fallback } },
//                    onComplete: onComplete
//                )
//            case .fallback:
//                FallbackAssessmentView(
//                    onBack:     { withAnimation { path = .photoUpload } },
//                    onComplete: onComplete
//                )
//            }
//        }
//        .animation(.easeInOut(duration: 0.25), value: path)
//    }
//}
//
//// ─────────────────────────────────────────────
//// MARK: Path A — Photo Upload
//// ─────────────────────────────────────────────
//
//private struct PhotoUploadView: View {
//    @Environment(AppDataStore.self) private var store
//    let onSkip: () -> Void
//    let onComplete: (ActionResult) -> Void
//
//    @Environment(\.dismiss) private var dismiss
//
//    // Uploaded images keyed by slot
//    @State private var uploadedImages: [PhotoSlot: UIImage] = [:]
//    @State private var selectedSlot:   PhotoSlot? = nil
//    @State private var pickerItem:     PhotosPickerItem? = nil
//    @State private var isAnalysing:    Bool = false
//    @State private var showPreview:    PhotoSlot? = nil
//
//    private var uploadedCount: Int { uploadedImages.count }
//    private var canContinue:   Bool { uploadedCount >= 1 }  // at least 1 photo to proceed
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Color.hcCream.ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // ── Navigation bar ──
//                HStack {
//                    HCBackButton { dismiss() }
//                    Spacer()
//                    Text("Upload Scalp Photos")
//                        .font(.system(size: 18, weight: .bold))
//                    Spacer()
//                    Button("Skip") { onSkip() }
//                        .font(.system(size: 16))
//                        .foregroundColor(.secondary)
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 12)
//                .padding(.bottom, 16)
//
//                // ── Subtitle ──
//                Text("Take a clear photo of your scalp from all angles for accurate density analysis")
//                    .font(.system(size: 15, weight: .semibold))
//                    .foregroundColor(.primary)
//                    .multilineTextAlignment(.leading)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 20)
//
//                // ── Photo cards ──
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 16) {
//                        ForEach(PhotoSlot.allCases, id: \.self) { slot in
//                            photoCard(for: slot)
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 120)
//                }
//            }
//
//            // ── Continue button ──
//            VStack(spacing: 0) {
//                if isAnalysing {
//                    analysingOverlay
//                } else {
//                    Button {
//                        runAIAnalysis()
//                    } label: {
//                        Text("Continue")
//                            .hcPrimaryButton()
//                            .opacity(canContinue ? 1 : 0.5)
//                    }
//                    .disabled(!canContinue)
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 36)
//                    .padding(.top, 12)
//                    .background(Color.hcCream)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        // PhotosPicker sheet for selected slot
//        .photosPicker(
//            isPresented: Binding(
//                get:  { selectedSlot != nil },
//                set:  { if !$0 { selectedSlot = nil } }
//            ),
//            selection: $pickerItem,
//            matching: .images
//        )
//        .onChange(of: pickerItem) { _, item in
//            guard let item, let slot = selectedSlot else { return }
//            Task {
//                if let data = try? await item.loadTransferable(type: Data.self),
//                   let image = UIImage(data: data) {
//                    await MainActor.run {
//                        uploadedImages[slot] = image
//                        pickerItem = nil
//                        selectedSlot = nil
//                    }
//                }
//            }
//        }
//        // Full-screen photo preview
//        .fullScreenCover(item: $showPreview) { slot in
//            if let image = uploadedImages[slot] {
//                photoPreviewSheet(image: image, slot: slot)
//            }
//        }
//    }
//
//    // ── Single photo card ──
//    private func photoCard(for slot: PhotoSlot) -> some View {
//        let hasImage = uploadedImages[slot] != nil
//
//        return VStack(alignment: .leading, spacing: 0) {
//            // Card label
//            Text(slot.rawValue)
//                .font(.system(size: 15, weight: .semibold))
//                .foregroundColor(.primary)
//                .padding(.horizontal, 16)
//                .padding(.top, 14)
//                .padding(.bottom, 10)
//
//            // Image area
//            ZStack {
//                if let image = uploadedImages[slot] {
//                    // ── Filled state ──
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 180)
//                        .clipped()
//                        .cornerRadius(10)
//                        .overlay(alignment: .topTrailing) {
//                            Button {
//                                showPreview = slot
//                            } label: {
//                                Image(systemName: "eye.fill")
//                                    .font(.system(size: 18))
//                                    .foregroundColor(.white)
//                                    .padding(10)
//                                    .background(Color.black.opacity(0.5))
//                                    .clipShape(Circle())
//                                    .padding(10)
//                            }
//                        }
//                } else {
//                    // ── Empty / dashed state ──
//                    RoundedRectangle(cornerRadius: 10)
//                        .strokeBorder(
//                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
//                        )
//                        .foregroundColor(Color(.systemGray3))
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 180)
//                        .overlay {
//                            Image(systemName: "camera")
//                                .font(.system(size: 32))
//                                .foregroundColor(Color(.systemGray3))
//                        }
//                }
//            }
//            .padding(.horizontal, 16)
//            .contentShape(Rectangle())
//            .onTapGesture {
//                selectedSlot = slot
//            }
//
//            // Bottom label row
//            HStack {
//                Text(hasImage ? "Tap to upload" : "Tap to upload  or Take a Photo")
//                    .font(.system(size: 13))
//                    .foregroundColor(.secondary)
//                Spacer()
//                if hasImage {
//                    Button {
//                        uploadedImages.removeValue(forKey: slot)
//                    } label: {
//                        Image(systemName: "arrow.clockwise")
//                            .font(.system(size: 14))
//                            .foregroundColor(.secondary)
//                    }
//                } else {
//                    Image(systemName: "arrow.clockwise")
//                        .font(.system(size: 14))
//                        .foregroundColor(Color(.systemGray4))
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//        }
//        .background(Color.white)
//        .cornerRadius(14)
//        .overlay(
//            RoundedRectangle(cornerRadius: 14)
//                .stroke(Color(.systemGray5), lineWidth: 1)
//        )
//    }
//
//    // ── Analysing loading overlay ──
//    private var analysingOverlay: some View {
//        VStack(spacing: 12) {
//            ProgressView()
//                .progressViewStyle(.circular)
//                .scaleEffect(1.2)
//                .tint(Color.hcBrown)
//            Text("Analysing your scalp…")
//                .font(.system(size: 15))
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 24)
//        .background(Color.hcCream)
//    }
//
//    // ── Photo preview full screen ──
//    private func photoPreviewSheet(image: UIImage, slot: PhotoSlot) -> some View {
//        ZStack(alignment: .topLeading) {
//            Color.black.ignoresSafeArea()
//            Image(uiImage: image)
//                .resizable()
//                .scaledToFit()
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            Button {
//                showPreview = nil
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 28))
//                    .foregroundColor(.white)
//                    .padding(20)
//            }
//        }
//    }
//
//    // ── AI analysis (mock) ──
//    private func runAIAnalysis() {
//        isAnalysing = true
//        // Simulate 1.5s AI processing delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            let result = store.submitScanImages(
//                frontURL: PhotoSlot.front.mockURL,
//                leftURL:  PhotoSlot.left.mockURL,
//                rightURL: PhotoSlot.right.mockURL,
//                backURL:  PhotoSlot.back.mockURL,
//                topURL:   PhotoSlot.top.mockURL,
//                scanType: .initial
//            )
//            isAnalysing = false
//            onComplete(result)
//        }
//    }
//}
//
//// ─────────────────────────────────────────────
//// MARK: Path B — Fallback Self-Assessment
//// ─────────────────────────────────────────────
//
//private struct FallbackAssessmentView: View {
//    @Environment(AppDataStore.self) private var store
//    let onBack: () -> Void
//    let onComplete: (ActionResult) -> Void
//
//    @State private var currentIndex = 0
//
//    // Answers
//    @State private var selectedStage:   HairFallStage?   = nil
//    @State private var selectedScalp:   ScalpCondition?  = nil
//    @State private var selectedDensity: HairDensityLevel? = nil
//
//    // Single/image selections by question id
//    @State private var singleSelections: [UUID: UUID] = [:]
//    @State private var imageSelections:  [UUID: UUID] = [:]
//
//    private var questions: [Question] { store.fallbackQuestions() }
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Color.hcCream.ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // ── Header ──
//                HStack {
//                    HCBackButton {
//                        if currentIndex > 0 {
//                            currentIndex -= 1
//                        } else {
//                            onBack()
//                        }
//                    }
//                    Spacer()
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 12)
//                .padding(.bottom, 12)
//
//                // ── Progress ──
//                HCProgressBar(current: currentIndex + 1, total: questions.count)
//                    .padding(.bottom, 28)
//
//                // ── Question ──
//                if currentIndex < questions.count {
//                    let q = questions[currentIndex]
//                    ScrollView(showsIndicators: false) {
//                        VStack(alignment: .leading, spacing: 28) {
//                            Text(q.questionText)
//                                .font(.system(size: 26, weight: .bold))
//                                .multilineTextAlignment(.center)
//                                .frame(maxWidth: .infinity)
//                                .padding(.horizontal, 8)
//
//                            if q.questionType == .imageChoice {
//                                stageImageGrid(for: q)
//                            } else {
//                                singleChoiceOptions(for: q)
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 120)
//                    }
//                }
//
//                Spacer(minLength: 0)
//            }
//
//            // ── Continue button ──
//            Button {
//                guard canContinue else { return }
//                if currentIndex < questions.count - 1 {
//                    currentIndex += 1
//                } else {
//                    submitFallback()
//                }
//            } label: {
//                Text(currentIndex == questions.count - 1 ? "Finish" : "Continue")
//                    .hcPrimaryButton()
//                    .opacity(canContinue ? 1 : 0.5)
//            }
//            .disabled(!canContinue)
//            .padding(.horizontal, 20)
//            .padding(.bottom, 36)
//        }
//        .navigationBarHidden(true)
//    }
//
//    // ── Stage image 2×2 grid ──
//    private func stageImageGrid(for q: Question) -> some View {
//        let opts     = store.options(for: q.id)
//        let selected = imageSelections[q.id]
//        let columns  = [GridItem(.flexible(), spacing: 16),
//                        GridItem(.flexible(), spacing: 16)]
//
//        return LazyVGrid(columns: columns, spacing: 16) {
//            ForEach(opts) { opt in
//                let isSelected = selected == opt.id
//                Button {
//                    imageSelections[q.id] = opt.id
//                    // Map option index → HairFallStage
//                    selectedStage = stageFrom(index: opt.optionOrderIndex)
//                } label: {
//                    ZStack(alignment: .topLeading) {
//                        RoundedRectangle(cornerRadius: 14)
//                            .fill(Color.white)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 14)
//                                    .stroke(
//                                        isSelected ? Color.hcBrown : Color(.systemGray4),
//                                        lineWidth: isSelected ? 2.5 : 1
//                                    )
//                            )
//
//                        VStack(spacing: 0) {
//                            stageIllustration(index: opt.optionOrderIndex)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 130)
//                                .clipped()
//                        }
//
//                        Text("\(opt.optionOrderIndex)")
//                            .font(.system(size: 15, weight: .bold))
//                            .foregroundColor(.primary)
//                            .padding(8)
//                    }
//                    .frame(height: 150)
//                }
//                .buttonStyle(.plain)
//            }
//        }
//    }
//
//    @ViewBuilder
//    private func stageIllustration(index: Int) -> some View {
//        let assetNames = ["stage1_illustration","stage2_illustration",
//                          "stage3_illustration","stage4_illustration"]
//        let asset = index >= 1 && index <= 4 ? assetNames[index - 1] : ""
//
//        if !asset.isEmpty, UIImage(named: asset) != nil {
//            Image(asset)
//                .resizable()
//                .scaledToFit()
//                .padding(10)
//        } else {
//            ZStack {
//                Color(.systemGray6)
//                VStack(spacing: 4) {
//                    Image(systemName: "person.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(Color(.systemGray3))
//                    Text("Stage \(index)")
//                        .font(.system(size: 11))
//                        .foregroundColor(Color(.systemGray2))
//                }
//            }
//        }
//    }
//
//    // ── Single choice options (scalp + density) ──
//    private func singleChoiceOptions(for q: Question) -> some View {
//        let opts     = store.options(for: q.id)
//        let selected = singleSelections[q.id]
//
//        return VStack(spacing: 12) {
//            ForEach(opts) { opt in
//                let isSelected = selected == opt.id
//                Button {
//                    singleSelections[q.id] = opt.id
//                    // Map selection to typed enum
//                    if currentIndex == 1 {
//                        selectedScalp = scalpFrom(optionIndex: opt.optionOrderIndex)
//                    } else if currentIndex == 2 {
//                        selectedDensity = densityFrom(optionIndex: opt.optionOrderIndex)
//                    }
//                } label: {
//                    HStack {
//                        Text(opt.optionText)
//                            .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
//                            .foregroundColor(isSelected ? .white : .primary)
//                            .padding(.leading, 20)
//                        Spacer()
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 58)
//                    .background(isSelected ? Color.hcBrown : Color.hcOptionBg)
//                    .cornerRadius(14)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 14)
//                            .stroke(
//                                isSelected ? Color.clear : Color(.systemGray4),
//                                lineWidth: 1
//                            )
//                    )
//                }
//                .buttonStyle(.plain)
//            }
//        }
//    }
//
//    // ── Can continue ──
//    private var canContinue: Bool {
//        switch currentIndex {
//        case 0: return selectedStage   != nil
//        case 1: return selectedScalp   != nil
//        case 2: return selectedDensity != nil
//        default: return false
//        }
//    }
//
//    // ── Submit fallback to engine ──
//    private func submitFallback() {
//        guard let stage   = selectedStage,
//              let scalp   = selectedScalp,
//              let density = selectedDensity else { return }
//
//        let result = store.submitSelfAssessedStage(
//            stage: stage,
//            scalp: scalp,
//            density: density,
//            scanType: .initial
//        )
//        onComplete(result)
//    }
//
//    // ── Mapping helpers ──
//
//    private func stageFrom(index: Int) -> HairFallStage {
//        switch index {
//        case 1:  return .stage1
//        case 2:  return .stage2
//        case 3:  return .stage3
//        default: return .stage4
//        }
//    }
//
//    private func scalpFrom(optionIndex: Int) -> ScalpCondition {
//        // FB2 options: 1=dandruff 2=dry 3=oily 4=inflamed 5=normal
//        switch optionIndex {
//        case 1:  return .dandruff
//        case 2:  return .dry
//        case 3:  return .oily
//        case 4:  return .inflamed
//        default: return .normal
//        }
//    }
//
//    private func densityFrom(optionIndex: Int) -> HairDensityLevel {
//        // FB3 options: 1=high 2=medium 3=low 4=veryLow
//        switch optionIndex {
//        case 1:  return .high
//        case 2:  return .medium
//        case 3:  return .low
//        default: return .veryLow
//        }
//    }
//}
//
//// MARK: - PhotoSlot Identifiable (for fullScreenCover)
//extension PhotoSlot: Identifiable {
//    var id: String { rawValue }
//}

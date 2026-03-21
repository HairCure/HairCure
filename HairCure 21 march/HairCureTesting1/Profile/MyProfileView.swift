//
//  MyProfileView.swift
//  HairCureTesting1
//
//  Profile → My Profile
//  Matches the design screenshots:
//  • Avatar + editable personal fields (Name, Phone, Email, DOB)
//  • Segmented picker: "My Hair Profile" | "Wellness Profile"
//  • Hair Profile tab: Diagnosis, Hair Type, Scalp Type
//  • Wellness Profile tab: Calorie Goal, Hydration Goal, Height, Weight, Veg Mode,
//    Yoga / Mindful / Sound daily minutes
//  • "Update Profile" primary button
//

import SwiftUI

// MARK: - MyProfileView

struct MyProfileView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    // Fields populated from the store on appear
    @State private var fullName:     String = ""
    @State private var phoneNumber:  String = ""
    @State private var email:        String = ""
    @State private var dateOfBirth:  Date   = Date()
    @State private var showDOBPicker = false

    // Segmented tab
    @State private var selectedTab: Int = 0   // 0 = Hair Profile, 1 = Wellness Profile

    // Computed shorthand helpers
    private var user:       User?                   { store.users.first(where: { $0.id == store.currentUserId }) }
    private var profile:    UserProfile?            { store.userProfiles.first(where: { $0.userId == store.currentUserId }) }
    private var report:     ScanReport?             { store.scanReports.last }
    private var plan:       UserPlan?               { store.userPlans.first(where: { $0.userId == store.currentUserId }) }
    private var nutrition:  UserNutritionProfile?   { store.userNutritionProfiles.first(where: { $0.userId == store.currentUserId }) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // ── Avatar ──
                avatarSection

                // ── Personal fields ──
                personalFieldsSection

                // ── Segmented picker ──
                segmentedPicker

                // ── Tab content ──
                if selectedTab == 0 {
                    hairProfileSection
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                } else {
                    wellnessProfileSection
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }

                // ── Update Profile button ──
                Button {
                    saveProfile()
                } label: {
                    Text("Update Profile")
                        .hcPrimaryButton()
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
            .padding(.top, 12)
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadFields)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
    }

    // MARK: - Avatar

    private var avatarSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .stroke(Color.hcBrown.opacity(0.25), lineWidth: 2)
                .frame(width: 90, height: 90)
                .background(
                    Circle().fill(Color.hcInputBg)
                )
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color.hcBrown.opacity(0.55))
                        .offset(y: 6)
                        .clipShape(Circle())
                )

            // Camera badge
            Circle()
                .fill(Color.hcBrown)
                .frame(width: 26, height: 26)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                )
        }
        .frame(width: 90, height: 90)
    }

    // MARK: - Personal fields

    private var personalFieldsSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            fieldGroup(label: "Full Name") {
                TextField("", text: $fullName)
                    .hcInputField()
            }

            fieldGroup(label: "Phone Number") {
                TextField("+91 9876543210", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .hcInputField()
            }

            fieldGroup(label: "Email") {
                TextField("user@example.com", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .hcInputField()
            }

            fieldGroup(label: "Date Of Birth") {
                Button {
                    showDOBPicker = true
                } label: {
                    HStack {
                        Text(dobDisplayText)
                            .font(.system(size: 16))
                            .foregroundColor(dobDisplayText == "DD / MM / YYYY" ? Color(UIColor.placeholderText) : .primary)
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 15))
                            .foregroundColor(Color.hcBrown.opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background(Color.hcInputBg)
                    .cornerRadius(12)
                }
                .sheet(isPresented: $showDOBPicker) {
                    dobPickerSheet
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var dobDisplayText: String {
        let cal = Calendar.current
        // Show placeholder if dob is today (unset default)
        if cal.isDateInToday(dateOfBirth) && fullName.isEmpty {
            return "DD / MM / YYYY"
        }
        let f = DateFormatter(); f.dateFormat = "dd / MM / yyyy"
        return f.string(from: dateOfBirth)
    }

    private var dobPickerSheet: some View {
        NavigationStack {
            DatePicker("Date of Birth", selection: $dateOfBirth,
                       in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.hcBrown)
                .padding(.horizontal)
                .navigationTitle("Date of Birth")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { showDOBPicker = false }
                            .fontWeight(.semibold)
                            .foregroundColor(Color.hcBrown)
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Segmented picker

    private var segmentedPicker: some View {
        HStack(spacing: 0) {
            pickerTab(title: "My Hair Profile", index: 0)
            pickerTab(title: "Wellness Profile", index: 1)
        }
        .padding(4)
        .background(Color(UIColor.systemGray6).opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 20)
    }

    private func pickerTab(title: String, index: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedTab = index
            }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: selectedTab == index ? .semibold : .regular))
                .foregroundColor(selectedTab == index ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedTab == index
                        ? Color.hcBrown
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - My Hair Profile tab

    private var hairProfileSection: some View {
        VStack(spacing: 0) {
            let stageName  = report?.hairFallStage.displayName ?? "—"
            let hairType   = (profile?.hairType ?? "—").capitalized
            let scalpType  = (profile?.scalpType ?? "—").capitalized

            ProfileInfoRow(label: "Current Diagnosis", value: stageName)
            Divider().padding(.leading, 16)
            ProfileInfoRow(label: "Hair Type",         value: hairType)
            Divider().padding(.leading, 16)
            ProfileInfoRow(label: "Scalp Type",        value: scalpType)
        }
        .background(Color(UIColor.systemGray6).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 20)
    }

    // MARK: - Wellness Profile tab

    private var wellnessProfileSection: some View {
        VStack(spacing: 12) {

            // Goals card
            VStack(spacing: 0) {
                let kcal    = Int(nutrition?.tdee ?? 2038)
                let waterML = Int(nutrition?.waterTargetML ?? 2450)
                let waterL  = String(format: "%.1fL", Float(waterML) / 1000.0)
                let height  = "\(Int(profile?.heightCm ?? 0)) cm"
                let weight  = "\(Int(profile?.weightKg ?? 0)) Kg"

                ProfileInfoRow(label: "Daily Calorie Goal",    value: "\(kcal) kcal")
                Divider().padding(.leading, 16)
                ProfileInfoRow(label: "Daily Hydration Goal",  value: waterL)
                Divider().padding(.leading, 16)
                ProfileInfoRow(label: "Height",                value: height)
                Divider().padding(.leading, 16)
                ProfileInfoRow(label: "Weight",                value: weight)
            }
            .background(Color(UIColor.systemGray6).opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Veg Mode card
            VStack(spacing: 0) {
                HStack {
                    Text("Veg Mode")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { profile?.isVegetarian ?? false },
                        set: { _ in }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .labelsHidden()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(UIColor.systemGray6).opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // MindEase minutes card
            VStack(spacing: 0) {
                let yoga      = plan?.yogaMinutesPerDay    ?? 0
                let mindful   = plan?.meditationMinutesPerDay ?? 0
                let sound     = plan?.soundMinutesPerDay   ?? 0

                ProfileInfoRow(label: "Daily Yoga Minutes",      value: "\(yoga) min")
                Divider().padding(.leading, 16)
                ProfileInfoRow(label: "Daily Mindful Minutes",   value: "\(mindful) min")
                Divider().padding(.leading, 16)
                ProfileInfoRow(label: "Relaxing Sound Minutes",  value: "\(sound) min")
            }
            .background(Color(UIColor.systemGray6).opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            content()
        }
    }

    private func loadFields() {
        fullName    = user?.name         ?? ""
        phoneNumber = user?.phoneNumber  ?? ""
        email       = user?.email        ?? ""
        if let dob = profile?.dateOfBirth {
            dateOfBirth = dob
        }
    }

    private func saveProfile() {
        // Update in-memory store (backend hook point)
        if let idx = store.users.firstIndex(where: { $0.id == store.currentUserId }) {
            store.users[idx].name        = fullName
            store.users[idx].phoneNumber = phoneNumber
            store.users[idx].email       = email
        }
        if let idx = store.userProfiles.firstIndex(where: { $0.userId == store.currentUserId }) {
            store.userProfiles[idx].displayName  = fullName
            store.userProfiles[idx].dateOfBirth  = dateOfBirth
        }
        dismiss()
    }
}

// MARK: - Info Row (label + value + chevron)

private struct ProfileInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MyProfileView()
    }
    .environment(AppDataStore())
}

////////
////////  MyProfileView.swift
////////  HairCureTesting1
////////
////////  Profile → My Profile
////////  Matches the design screenshots:
////////  • Avatar + editable personal fields (Name, Phone, Email, DOB)
////////  • Segmented picker: "My Hair Profile" | "Wellness Profile"
////////  • Hair Profile tab: Diagnosis, Hair Type, Scalp Type
////////  • Wellness Profile tab: Calorie Goal, Hydration Goal, Height, Weight, Veg Mode,
////////    Yoga / Mindful / Sound daily minutes
////////  • "Update Profile" primary button
////////
//////
//////import SwiftUI
//////
//////// MARK: - MyProfileView
//////
//////struct MyProfileView: View {
//////    @Environment(AppDataStore.self) private var store
//////    @Environment(\.dismiss) private var dismiss
//////
//////    // Fields populated from the store on appear
//////    @State private var fullName:     String = ""
//////    @State private var phoneNumber:  String = ""
//////    @State private var email:        String = ""
//////    @State private var dateOfBirth:  Date   = Date()
//////    @State private var showDOBPicker = false
//////
//////    // Segmented tab
//////    @State private var selectedTab: Int = 0   // 0 = Hair Profile, 1 = Wellness Profile
//////
//////    // Computed shorthand helpers
//////    private var user:       User?                   { store.users.first(where: { $0.id == store.currentUserId }) }
//////    private var profile:    UserProfile?            { store.userProfiles.first(where: { $0.userId == store.currentUserId }) }
//////    private var report:     ScanReport?             { store.scanReports.last }
//////    private var plan:       UserPlan?               { store.userPlans.first(where: { $0.userId == store.currentUserId }) }
//////    private var nutrition:  UserNutritionProfile?   { store.userNutritionProfiles.first(where: { $0.userId == store.currentUserId }) }
//////
//////    var body: some View {
//////        ScrollView(showsIndicators: false) {
//////            VStack(spacing: 24) {
//////
//////                // ── Avatar ──
//////                avatarSection
//////
//////                // ── Personal fields ──
//////                personalFieldsSection
//////
//////                // ── Segmented picker ──
//////                segmentedPicker
//////
//////                // ── Tab content ──
//////                if selectedTab == 0 {
//////                    hairProfileSection
//////                        .transition(.opacity.combined(with: .move(edge: .leading)))
//////                } else {
//////                    wellnessProfileSection
//////                        .transition(.opacity.combined(with: .move(edge: .trailing)))
//////                }
//////
//////                // ── Update Profile button ──
//////                Button {
//////                    saveProfile()
//////                } label: {
//////                    Text("Update Profile")
//////                        .hcPrimaryButton()
//////                }
//////                .padding(.horizontal, 20)
//////                .padding(.top, 4)
//////                .padding(.bottom, 32)
//////            }
//////            .padding(.top, 12)
//////        }
//////        .background(Color.hcCream.ignoresSafeArea())
//////        .navigationTitle("Profile")
//////        .navigationBarTitleDisplayMode(.inline)
//////        .onAppear(perform: loadFields)
//////        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
//////    }
//////
//////    // MARK: - Avatar
//////
//////    private var avatarSection: some View {
//////        ZStack(alignment: .bottomTrailing) {
//////            Circle()
//////                .stroke(Color.hcBrown.opacity(0.25), lineWidth: 2)
//////                .frame(width: 90, height: 90)
//////                .background(
//////                    Circle().fill(Color.hcInputBg)
//////                )
//////                .overlay(
//////                    Image(systemName: "person.fill")
//////                        .font(.system(size: 44))
//////                        .foregroundColor(Color.hcBrown.opacity(0.55))
//////                        .offset(y: 6)
//////                        .clipShape(Circle())
//////                )
//////
//////            // Camera badge
//////            Circle()
//////                .fill(Color.hcBrown)
//////                .frame(width: 26, height: 26)
//////                .overlay(
//////                    Image(systemName: "camera.fill")
//////                        .font(.system(size: 11, weight: .semibold))
//////                        .foregroundColor(.white)
//////                )
//////        }
//////        .frame(width: 90, height: 90)
//////    }
//////
//////    // MARK: - Personal fields
//////
//////    private var personalFieldsSection: some View {
//////        VStack(alignment: .leading, spacing: 14) {
//////
//////            fieldGroup(label: "Full Name") {
//////                TextField("", text: $fullName)
//////                    .hcInputField()
//////            }
//////
//////            fieldGroup(label: "Phone Number") {
//////                TextField("+91 9876543210", text: $phoneNumber)
//////                    .keyboardType(.phonePad)
//////                    .hcInputField()
//////            }
//////
//////            fieldGroup(label: "Email") {
//////                TextField("user@example.com", text: $email)
//////                    .keyboardType(.emailAddress)
//////                    .autocorrectionDisabled()
//////                    .textInputAutocapitalization(.never)
//////                    .hcInputField()
//////            }
//////
//////            fieldGroup(label: "Date Of Birth") {
//////                Button {
//////                    showDOBPicker = true
//////                } label: {
//////                    HStack {
//////                        Text(dobDisplayText)
//////                            .font(.system(size: 16))
//////                            .foregroundColor(dobDisplayText == "DD / MM / YYYY" ? Color(UIColor.placeholderText) : .primary)
//////                        Spacer()
//////                        Image(systemName: "calendar")
//////                            .font(.system(size: 15))
//////                            .foregroundColor(Color.hcBrown.opacity(0.7))
//////                    }
//////                    .padding(.horizontal, 16)
//////                    .frame(height: 54)
//////                    .background(Color.hcInputBg)
//////                    .cornerRadius(12)
//////                }
//////                .sheet(isPresented: $showDOBPicker) {
//////                    dobPickerSheet
//////                }
//////            }
//////        }
//////        .padding(.horizontal, 20)
//////    }
//////
//////    private var dobDisplayText: String {
//////        let cal = Calendar.current
//////        // Show placeholder if dob is today (unset default)
//////        if cal.isDateInToday(dateOfBirth) && fullName.isEmpty {
//////            return "DD / MM / YYYY"
//////        }
//////        let f = DateFormatter(); f.dateFormat = "dd / MM / yyyy"
//////        return f.string(from: dateOfBirth)
//////    }
//////
//////    private var dobPickerSheet: some View {
//////        NavigationStack {
//////            DatePicker("Date of Birth", selection: $dateOfBirth,
//////                       in: ...Date(), displayedComponents: .date)
//////                .datePickerStyle(.graphical)
//////                .tint(Color.hcBrown)
//////                .padding(.horizontal)
//////                .navigationTitle("Date of Birth")
//////                .navigationBarTitleDisplayMode(.inline)
//////                .toolbar {
//////                    ToolbarItem(placement: .confirmationAction) {
//////                        Button("Done") { showDOBPicker = false }
//////                            .fontWeight(.semibold)
//////                            .foregroundColor(Color.hcBrown)
//////                    }
//////                }
//////        }
//////        .presentationDetents([.medium, .large])
//////        .presentationDragIndicator(.visible)
//////    }
//////
//////    // MARK: - Segmented picker
//////
//////    private var segmentedPicker: some View {
//////        HStack(spacing: 0) {
//////            pickerTab(title: "My Hair Profile", index: 0)
//////            pickerTab(title: "Wellness Profile", index: 1)
//////        }
//////        .padding(4)
//////        .background(Color(UIColor.systemGray6).opacity(0.8))
//////        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//////        .padding(.horizontal, 20)
//////    }
//////
//////    private func pickerTab(title: String, index: Int) -> some View {
//////        Button {
//////            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
//////                selectedTab = index
//////            }
//////        } label: {
//////            Text(title)
//////                .font(.system(size: 14, weight: selectedTab == index ? .semibold : .regular))
//////                .foregroundColor(selectedTab == index ? .white : .secondary)
//////                .frame(maxWidth: .infinity)
//////                .padding(.vertical, 10)
//////                .background(
//////                    selectedTab == index
//////                        ? Color.hcBrown
//////                        : Color.clear
//////                )
//////                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
//////        }
//////        .buttonStyle(.plain)
//////    }
//////
//////    // MARK: - My Hair Profile tab
//////
//////    private var hairProfileSection: some View {
//////        VStack(spacing: 0) {
//////            let stageName  = report?.hairFallStage.displayName ?? "—"
//////            let hairType   = (profile?.hairType ?? "—").capitalized
//////            let scalpType  = (profile?.scalpType ?? "—").capitalized
//////
//////            ProfileInfoRow(label: "Current Diagnosis", value: stageName)
//////            Divider().padding(.leading, 16)
//////            ProfileInfoRow(label: "Hair Type",         value: hairType)
//////            Divider().padding(.leading, 16)
//////            ProfileInfoRow(label: "Scalp Type",        value: scalpType)
//////        }
//////        .background(Color(UIColor.systemGray6).opacity(0.6))
//////        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//////        .padding(.horizontal, 20)
//////    }
//////
//////    // MARK: - Wellness Profile tab
//////
//////    private var wellnessProfileSection: some View {
//////        VStack(spacing: 12) {
//////
//////            // Goals card
//////            VStack(spacing: 0) {
//////                let kcal    = Int(nutrition?.tdee ?? 2038)
//////                let waterML = Int(nutrition?.waterTargetML ?? 2450)
//////                let waterL  = String(format: "%.1fL", Float(waterML) / 1000.0)
//////                let height  = "\(Int(profile?.heightCm ?? 0)) cm"
//////                let weight  = "\(Int(profile?.weightKg ?? 0)) Kg"
//////
//////                ProfileInfoRow(label: "Daily Calorie Goal",    value: "\(kcal) kcal")
//////                Divider().padding(.leading, 16)
//////                ProfileInfoRow(label: "Daily Hydration Goal",  value: waterL)
//////                Divider().padding(.leading, 16)
//////                ProfileInfoRow(label: "Height",                value: height)
//////                Divider().padding(.leading, 16)
//////                ProfileInfoRow(label: "Weight",                value: weight)
//////            }
//////            .background(Color(UIColor.systemGray6).opacity(0.6))
//////            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//////
//////            // Veg Mode card
//////            VStack(spacing: 0) {
//////                HStack {
//////                    Text("Veg Mode")
//////                        .font(.system(size: 17, weight: .regular))
//////                        .foregroundColor(.primary)
//////                    Spacer()
//////                    Toggle("", isOn: Binding(
//////                        get: { profile?.isVegetarian ?? false },
//////                        set: { _ in }
//////                    ))
//////                    .toggleStyle(SwitchToggleStyle(tint: .green))
//////                    .labelsHidden()
//////                }
//////                .padding(.horizontal, 16)
//////                .padding(.vertical, 16)
//////            }
//////            .background(Color(UIColor.systemGray6).opacity(0.6))
//////            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//////
//////            // MindEase minutes card
//////            VStack(spacing: 0) {
//////                let yoga      = plan?.yogaMinutesPerDay    ?? 0
//////                let mindful   = plan?.meditationMinutesPerDay ?? 0
//////                let sound     = plan?.soundMinutesPerDay   ?? 0
//////
//////                ProfileInfoRow(label: "Daily Yoga Minutes",      value: "\(yoga) min")
//////                Divider().padding(.leading, 16)
//////                ProfileInfoRow(label: "Daily Mindful Minutes",   value: "\(mindful) min")
//////                Divider().padding(.leading, 16)
//////                ProfileInfoRow(label: "Relaxing Sound Minutes",  value: "\(sound) min")
//////            }
//////            .background(Color(UIColor.systemGray6).opacity(0.6))
//////            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
//////        }
//////        .padding(.horizontal, 20)
//////    }
//////
//////    // MARK: - Helpers
//////
//////    private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
//////        VStack(alignment: .leading, spacing: 6) {
//////            Text(label)
//////                .font(.system(size: 15, weight: .medium))
//////                .foregroundColor(.primary)
//////            content()
//////        }
//////    }
//////
//////    private func loadFields() {
//////        fullName    = user?.name         ?? ""
//////        phoneNumber = user?.phoneNumber  ?? ""
//////        email       = user?.email        ?? ""
//////        if let dob = profile?.dateOfBirth {
//////            dateOfBirth = dob
//////        }
//////    }
//////
//////    private func saveProfile() {
//////        // Update in-memory store (backend hook point)
//////        if let idx = store.users.firstIndex(where: { $0.id == store.currentUserId }) {
//////            store.users[idx].name        = fullName
//////            store.users[idx].phoneNumber = phoneNumber
//////            store.users[idx].email       = email
//////        }
//////        if let idx = store.userProfiles.firstIndex(where: { $0.userId == store.currentUserId }) {
//////            store.userProfiles[idx].displayName  = fullName
//////            store.userProfiles[idx].dateOfBirth  = dateOfBirth
//////        }
//////        dismiss()
//////    }
//////}
//////
//////// MARK: - Info Row (label + value + chevron)
//////
//////private struct ProfileInfoRow: View {
//////    let label: String
//////    let value: String
//////
//////    var body: some View {
//////        HStack {
//////            Text(label)
//////                .font(.system(size: 16, weight: .semibold))
//////                .foregroundColor(.primary)
//////            Spacer()
//////            Text(value)
//////                .font(.system(size: 15))
//////                .foregroundColor(.secondary)
//////            Image(systemName: "chevron.right")
//////                .font(.system(size: 12, weight: .semibold))
//////                .foregroundColor(Color(UIColor.tertiaryLabel))
//////        }
//////        .padding(.horizontal, 16)
//////        .padding(.vertical, 14)
//////        .contentShape(Rectangle())
//////    }
//////}
//////
//////// MARK: - Preview
//////
//////#Preview {
//////    NavigationStack {
//////        MyProfileView()
//////    }
//////    .environment(AppDataStore())
//////}
////
//////
//////  MyProfileView.swift
//////  HairCure
//////
//////  Profile → My Profile — iOS 18+ native redesign
//////  • Clean avatar + editable personal fields
//////  • Segmented picker: My Hair Profile | Wellness Profile
//////  • Update Profile primary button
//////
////
////import SwiftUI
////
////struct MyProfileView: View {
////    @Environment(AppDataStore.self) private var store
////    @Environment(\.dismiss) private var dismiss
////
////    @State private var fullName:     String = ""
////    @State private var phoneNumber:  String = ""
////    @State private var email:        String = ""
////    @State private var dateOfBirth:  Date   = Date()
////    @State private var showDOBPicker = false
////    @State private var selectedTab:  Int    = 0
////
////    private var user:      User?                 { store.users.first(where: { $0.id == store.currentUserId }) }
////    private var profile:   UserProfile?          { store.userProfiles.first(where: { $0.userId == store.currentUserId }) }
////    private var report:    ScanReport?           { store.scanReports.last }
////    private var plan:      UserPlan?             { store.userPlans.first(where: { $0.userId == store.currentUserId }) }
////    private var nutrition: UserNutritionProfile? { store.userNutritionProfiles.first(where: { $0.userId == store.currentUserId }) }
////
////    var body: some View {
////        ScrollView(showsIndicators: false) {
////            VStack(spacing: 24) {
////                avatarSection
////                personalFieldsSection
////                segmentedPicker
////
////                Group {
////                    if selectedTab == 0 { hairProfileSection }
////                    else                { wellnessProfileSection }
////                }
////                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)
////
////                Button { saveProfile() } label: {
////                    Text("Update Profile")
////                        .hcPrimaryButton()
////                }
////                .padding(.horizontal, 20)
////                .padding(.bottom, 32)
////            }
////            .padding(.top, 16)
////        }
////        .background(Color.hcCream.ignoresSafeArea())
////        .navigationTitle("My Profile")
////        .navigationBarTitleDisplayMode(.inline)
////        .onAppear(perform: loadFields)
////    }
////
////    // MARK: - Avatar
////
////    private var avatarSection: some View {
////        ZStack(alignment: .bottomTrailing) {
////            Circle()
////                .fill(Color.hcBrown.opacity(0.10))
////                .frame(width: 84, height: 84)
////                .overlay(
////                    Image(systemName: "person.fill")
////                        .font(.system(size: 40))
////                        .foregroundColor(Color.hcBrown.opacity(0.65))
////                        .offset(y: 4)
////                        .clipShape(Circle())
////                )
////                .overlay(
////                    Circle().stroke(Color.hcBrown.opacity(0.20), lineWidth: 1.5)
////                )
////
////            Circle()
////                .fill(Color.hcBrown)
////                .frame(width: 26, height: 26)
////                .overlay(
////                    Image(systemName: "camera.fill")
////                        .font(.system(size: 11, weight: .semibold))
////                        .foregroundColor(.white)
////                )
////                .offset(x: 2, y: 2)
////        }
////    }
////
////    // MARK: - Personal Fields
////
////    private var personalFieldsSection: some View {
////        VStack(spacing: 0) {
////            inputRow(icon: "person.fill", iconColor: Color.hcBrown, label: "Full Name") {
////                TextField("Full name", text: $fullName)
////                    .font(.system(size: 16))
////            }
////            Divider().padding(.leading, 52)
////            inputRow(icon: "phone.fill", iconColor: Color(red: 0.2, green: 0.6, blue: 0.3), label: "Phone") {
////                TextField("+91 9876543210", text: $phoneNumber)
////                    .keyboardType(.phonePad)
////                    .font(.system(size: 16))
////            }
////            Divider().padding(.leading, 52)
////            inputRow(icon: "envelope.fill", iconColor: Color(red: 0.1, green: 0.5, blue: 0.9), label: "Email") {
////                TextField("user@example.com", text: $email)
////                    .keyboardType(.emailAddress)
////                    .autocorrectionDisabled()
////                    .textInputAutocapitalization(.never)
////                    .font(.system(size: 16))
////            }
////            Divider().padding(.leading, 52)
////            inputRow(icon: "calendar", iconColor: Color(red: 0.8, green: 0.4, blue: 0.1), label: "Date of Birth") {
////                Button { showDOBPicker = true } label: {
////                    HStack {
////                        Text(dobDisplayText)
////                            .font(.system(size: 16))
////                            .foregroundColor(dobDisplayText == "DD / MM / YYYY"
////                                ? Color(UIColor.placeholderText) : .primary)
////                        Spacer()
////                    }
////                }
////                .sheet(isPresented: $showDOBPicker) { dobPickerSheet }
////            }
////        }
////        .background(Color.white)
////        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
////        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
////        .padding(.horizontal, 20)
////    }
////
////    private func inputRow<Content: View>(
////        icon: String, iconColor: Color, label: String,
////        @ViewBuilder content: () -> Content
////    ) -> some View {
////        HStack(spacing: 14) {
////            RoundedRectangle(cornerRadius: 8, style: .continuous)
////                .fill(iconColor)
////                .frame(width: 30, height: 30)
////                .overlay(
////                    Image(systemName: icon)
////                        .font(.system(size: 13, weight: .semibold))
////                        .foregroundColor(.white)
////                )
////            VStack(alignment: .leading, spacing: 3) {
////                Text(label)
////                    .font(.system(size: 11, weight: .semibold))
////                    .foregroundColor(.secondary)
////                    .kerning(0.2)
////                content()
////                    .foregroundColor(.primary)
////            }
////            Spacer()
////        }
////        .padding(.horizontal, 16)
////        .padding(.vertical, 13)
////    }
////
////    private var dobDisplayText: String {
////        if Calendar.current.isDateInToday(dateOfBirth) && fullName.isEmpty { return "DD / MM / YYYY" }
////        let f = DateFormatter(); f.dateFormat = "dd / MM / yyyy"
////        return f.string(from: dateOfBirth)
////    }
////
////    private var dobPickerSheet: some View {
////        NavigationStack {
////            DatePicker("Date of Birth", selection: $dateOfBirth,
////                       in: ...Date(), displayedComponents: .date)
////                .datePickerStyle(.graphical)
////                .tint(Color.hcBrown)
////                .padding(.horizontal)
////                .navigationTitle("Date of Birth")
////                .navigationBarTitleDisplayMode(.inline)
////                .toolbar {
////                    ToolbarItem(placement: .confirmationAction) {
////                        Button("Done") { showDOBPicker = false }
////                            .fontWeight(.semibold)
////                            .foregroundColor(Color.hcBrown)
////                    }
////                }
////        }
////        .presentationDetents([.medium, .large])
////        .presentationDragIndicator(.visible)
////    }
////
////    // MARK: - Segmented Picker
////
////    private var segmentedPicker: some View {
////        HStack(spacing: 0) {
////            pickerTab(title: "Hair Profile",    index: 0)
////            pickerTab(title: "Wellness Profile", index: 1)
////        }
////        .padding(4)
////        .background(Color(UIColor.systemGray6))
////        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
////        .padding(.horizontal, 20)
////    }
////
////    private func pickerTab(title: String, index: Int) -> some View {
////        Button {
////            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { selectedTab = index }
////        } label: {
////            Text(title)
////                .font(.system(size: 14, weight: selectedTab == index ? .semibold : .regular))
////                .foregroundColor(selectedTab == index ? .white : .secondary)
////                .frame(maxWidth: .infinity)
////                .padding(.vertical, 10)
////                .background(selectedTab == index ? Color.hcBrown : Color.clear)
////                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
////        }
////        .buttonStyle(.plain)
////    }
////
////    // MARK: - Hair Profile Tab
////
////    private var hairProfileSection: some View {
////        VStack(spacing: 0) {
////            infoRow(label: "Current Diagnosis", value: report?.hairFallStage.displayName ?? "—")
////            Divider().padding(.leading, 16)
////            infoRow(label: "Hair Type",  value: (profile?.hairType  ?? "—").capitalized)
////            Divider().padding(.leading, 16)
////            infoRow(label: "Scalp Type", value: (profile?.scalpType ?? "—").capitalized)
////        }
////        .background(Color.white)
////        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
////        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
////        .padding(.horizontal, 20)
////        .transition(.opacity.combined(with: .move(edge: .leading)))
////    }
////
////    // MARK: - Wellness Profile Tab
////
////    private var wellnessProfileSection: some View {
////        VStack(spacing: 12) {
////            // Goals
////            VStack(spacing: 0) {
////                infoRow(label: "Daily Calorie Goal",   value: "\(Int(nutrition?.tdee ?? 2038)) kcal")
////                Divider().padding(.leading, 16)
////                infoRow(label: "Daily Hydration Goal", value: String(format: "%.1fL", Float(nutrition?.waterTargetML ?? 2450) / 1000))
////                Divider().padding(.leading, 16)
////                infoRow(label: "Height", value: "\(Int(profile?.heightCm ?? 0)) cm")
////                Divider().padding(.leading, 16)
////                infoRow(label: "Weight", value: "\(Int(profile?.weightKg ?? 0)) kg")
////            }
////            .background(Color.white)
////            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
////            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
////
////            // Veg mode
////            HStack {
////                HStack(spacing: 10) {
////                    RoundedRectangle(cornerRadius: 8, style: .continuous)
////                        .fill(Color.green)
////                        .frame(width: 30, height: 30)
////                        .overlay(Image(systemName: "leaf.fill").font(.system(size: 13, weight: .semibold)).foregroundColor(.white))
////                    Text("Veg Mode")
////                        .font(.system(size: 16, weight: .medium))
////                }
////                Spacer()
////                Toggle("", isOn: Binding(get: { profile?.isVegetarian ?? false }, set: { _ in }))
////                    .toggleStyle(SwitchToggleStyle(tint: .green))
////                    .labelsHidden()
////            }
////            .padding(.horizontal, 16)
////            .padding(.vertical, 14)
////            .background(Color.white)
////            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
////            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
////
////            // MindEase minutes
////            VStack(spacing: 0) {
////                infoRow(label: "Yoga Minutes",         value: "\(plan?.yogaMinutesPerDay ?? 0) min/day")
////                Divider().padding(.leading, 16)
////                infoRow(label: "Meditation Minutes",   value: "\(plan?.meditationMinutesPerDay ?? 0) min/day")
////                Divider().padding(.leading, 16)
////                infoRow(label: "Relaxing Sound",       value: "\(plan?.soundMinutesPerDay ?? 0) min/day")
////            }
////            .background(Color.white)
////            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
////            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
////        }
////        .padding(.horizontal, 20)
////        .transition(.opacity.combined(with: .move(edge: .trailing)))
////    }
////
////    private func infoRow(label: String, value: String) -> some View {
////        HStack {
////            Text(label)
////                .font(.system(size: 15, weight: .medium))
////                .foregroundColor(.primary)
////            Spacer()
////            Text(value)
////                .font(.system(size: 15, weight: .semibold))
////                .foregroundColor(Color.hcBrown)
////                .padding(.horizontal, 10)
////                .padding(.vertical, 4)
////                .background(Color.hcBrown.opacity(0.08))
////                .clipShape(Capsule())
////        }
////        .padding(.horizontal, 16)
////        .padding(.vertical, 13)
////    }
////
////    // MARK: - Helpers
////
////    private func loadFields() {
////        fullName    = user?.name        ?? ""
////        phoneNumber = user?.phoneNumber ?? ""
////        email       = user?.email       ?? ""
////        if let dob = profile?.dateOfBirth { dateOfBirth = dob }
////    }
////
////    private func saveProfile() {
////        if let idx = store.users.firstIndex(where: { $0.id == store.currentUserId }) {
////            store.users[idx].name        = fullName
////            store.users[idx].phoneNumber = phoneNumber
////            store.users[idx].email       = email
////        }
////        if let idx = store.userProfiles.firstIndex(where: { $0.userId == store.currentUserId }) {
////            store.userProfiles[idx].displayName = fullName
////            store.userProfiles[idx].dateOfBirth = dateOfBirth
////        }
////        dismiss()
////    }
////}
////
////// MARK: - Preview
////
////#Preview {
////    NavigationStack { MyProfileView() }
////        .environment(AppDataStore())
////}
////
////  MyProfileView.swift
////  HairCure
////
////  Profile → My Profile — iOS 18+ native redesign
////  Design decisions:
////  • Fullscreen scroll with cream background
////  • Avatar with live photo badge — centered above fields
////  • Personal info in a single white card with icon-prefixed rows
////  • Segmented control uses native `.segmented` style via Picker
////  • Hair Profile / Wellness Profile cards with warm badge values
////  • "Update Profile" uses `.borderedProminent` tinted to hcBrown
////
//
//import SwiftUI
//
//// MARK: - MyProfileView
//
//struct MyProfileView: View {
//    @Environment(AppDataStore.self) private var store
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var fullName:     String = ""
//    @State private var phoneNumber:  String = ""
//    @State private var email:        String = ""
//    @State private var dateOfBirth:  Date   = Date()
//    @State private var showDOBPicker = false
//    @State private var selectedTab:  ProfileTab = .hair
//    @State private var appeared      = false
//
//    enum ProfileTab: String, CaseIterable {
//        case hair     = "Hair Profile"
//        case wellness = "Wellness"
//    }
//
//    private var user:      User?                 { store.users.first(where: { $0.id == store.currentUserId }) }
//    private var profile:   UserProfile?          { store.userProfiles.first(where: { $0.userId == store.currentUserId }) }
//    private var report:    ScanReport?           { store.scanReports.last }
//    private var plan:      UserPlan?             { store.userPlans.first(where: { $0.userId == store.currentUserId }) }
//    private var nutrition: UserNutritionProfile? { store.userNutritionProfiles.first(where: { $0.userId == store.currentUserId }) }
//
//    var body: some View {
//        ScrollView(showsIndicators: false) {
//            VStack(spacing: 24) {
//
//                // 1 ── Avatar
//                avatarSection
//                    .padding(.top, 8)
//                    .opacity(appeared ? 1 : 0)
//                    .offset(y: appeared ? 0 : 12)
//
//                // 2 ── Personal fields
//                personalFieldsCard
//                    .opacity(appeared ? 1 : 0)
//                    .offset(y: appeared ? 0 : 12)
//
//                // 3 ── Segmented picker (native)
//                Picker("Profile section", selection: $selectedTab) {
//                    ForEach(ProfileTab.allCases, id: \.self) { tab in
//                        Text(tab.rawValue).tag(tab)
//                    }
//                }
//                .pickerStyle(.segmented)
//                .tint(Color.hcBrown)
//                .padding(.horizontal, 16)
//
//                // 4 ── Tab content
//                Group {
//                    switch selectedTab {
//                    case .hair:     hairProfileCard
//                    case .wellness: wellnessProfileCards
//                    }
//                }
//                .transition(.asymmetric(
//                    insertion: .opacity.combined(with: .move(edge: selectedTab == .hair ? .leading : .trailing)),
//                    removal:   .opacity
//                ))
//                .animation(.spring(response: 0.38, dampingFraction: 0.80), value: selectedTab)
//
//                // 5 ── Update button
//                Button(action: saveProfile) {
//                    Label("Update Profile", systemImage: "checkmark")
//                        .font(.system(size: 16, weight: .bold, design: .rounded))
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                }
//                .buttonStyle(.borderedProminent)
//                .tint(Color.hcBrown)
//                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                .shadow(color: Color.hcBrown.opacity(0.30), radius: 8, x: 0, y: 4)
//                .padding(.horizontal, 16)
//                .padding(.bottom, 40)
//            }
//        }
//        .background(Color.hcCream.ignoresSafeArea())
//        .navigationTitle("My Profile")
//        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            loadFields()
//            withAnimation(.spring(response: 0.48, dampingFraction: 0.78).delay(0.05)) {
//                appeared = true
//            }
//        }
//    }
//
//    // MARK: 1 · Avatar
//
//    private var avatarSection: some View {
//        VStack(spacing: 10) {
//            ZStack(alignment: .bottomTrailing) {
//                Circle()
//                    .fill(
//                        LinearGradient(
//                            colors: [Color.hcBrown.opacity(0.16), Color.hcBrown.opacity(0.07)],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .frame(width: 88, height: 88)
//                    .overlay(
//                        Circle().stroke(Color.hcBrown.opacity(0.20), lineWidth: 1.5)
//                    )
//                    .overlay(
//                        Image(systemName: "person.fill")
//                            .font(.system(size: 42))
//                            .foregroundStyle(Color.hcBrown.opacity(0.65))
//                            .offset(y: 4)
//                            .clipShape(Circle())
//                    )
//
//                // Camera badge
//                ZStack {
//                    Circle()
//                        .fill(Color.hcBrown)
//                        .frame(width: 28, height: 28)
//                        .shadow(color: Color.hcBrown.opacity(0.4), radius: 4, x: 0, y: 2)
//                    Image(systemName: "camera.fill")
//                        .font(.system(size: 12, weight: .semibold))
//                        .foregroundStyle(.white)
//                }
//                .offset(x: 2, y: 2)
//            }
//
//            // Name displayed under avatar
//            if !fullName.isEmpty {
//                Text(fullName)
//                    .font(.system(size: 15, weight: .semibold, design: .rounded))
//                    .foregroundStyle(.primary)
//            }
//        }
//    }
//
//    // MARK: 2 · Personal Fields Card
//
//    private var personalFieldsCard: some View {
//        VStack(spacing: 0) {
//            personalRow(
//                icon: "person.fill",
//                iconColor: Color.hcBrown,
//                label: "Full Name"
//            ) {
//                TextField("Full name", text: $fullName)
//                    .font(.system(size: 15))
//                    .foregroundStyle(.primary)
//            }
//
//            cardDivider
//
//            personalRow(
//                icon: "phone.fill",
//                iconColor: Color(red: 0.20, green: 0.60, blue: 0.28),
//                label: "Phone"
//            ) {
//                TextField("+91 9876543210", text: $phoneNumber)
//                    .keyboardType(.phonePad)
//                    .font(.system(size: 15))
//                    .foregroundStyle(.primary)
//            }
//
//            cardDivider
//
//            personalRow(
//                icon: "envelope.fill",
//                iconColor: Color(red: 0.10, green: 0.48, blue: 0.90),
//                label: "Email"
//            ) {
//                TextField("user@example.com", text: $email)
//                    .keyboardType(.emailAddress)
//                    .autocorrectionDisabled()
//                    .textInputAutocapitalization(.never)
//                    .font(.system(size: 15))
//                    .foregroundStyle(.primary)
//            }
//
//            cardDivider
//
//            personalRow(
//                icon: "calendar",
//                iconColor: Color(red: 0.85, green: 0.40, blue: 0.10),
//                label: "Date of Birth"
//            ) {
//                Button { showDOBPicker = true } label: {
//                    HStack {
//                        Text(dobDisplayText)
//                            .font(.system(size: 15))
//                            .foregroundStyle(dobDisplayText == "DD / MM / YYYY"
//                                ? Color(UIColor.placeholderText) : .primary)
//                        Spacer()
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 11, weight: .semibold))
//                            .foregroundStyle(.secondary)
//                    }
//                }
//                .sheet(isPresented: $showDOBPicker) { dobPickerSheet }
//            }
//        }
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//        .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
//        .padding(.horizontal, 16)
//    }
//
//    private func personalRow<Content: View>(
//        icon: String, iconColor: Color, label: String,
//        @ViewBuilder content: () -> Content
//    ) -> some View {
//        HStack(spacing: 14) {
//            RoundedRectangle(cornerRadius: 9, style: .continuous)
//                .fill(iconColor)
//                .frame(width: 34, height: 34)
//                .overlay(
//                    Image(systemName: icon)
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundStyle(.white)
//                )
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(label)
//                    .font(.system(size: 10, weight: .semibold))
//                    .foregroundStyle(.secondary)
//                    .textCase(.uppercase)
//                    .kerning(0.3)
//                content()
//            }
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 13)
//    }
//
//    private var cardDivider: some View {
//        Divider().padding(.leading, 64)
//    }
//
//    // MARK: DOB helpers
//
//    private var dobDisplayText: String {
//        if Calendar.current.isDateInToday(dateOfBirth) && fullName.isEmpty { return "DD / MM / YYYY" }
//        let f = DateFormatter(); f.dateFormat = "dd / MM / yyyy"
//        return f.string(from: dateOfBirth)
//    }
//
//    private var dobPickerSheet: some View {
//        NavigationStack {
//            DatePicker("Date of Birth", selection: $dateOfBirth,
//                       in: ...Date(), displayedComponents: .date)
//                .datePickerStyle(.graphical)
//                .tint(Color.hcBrown)
//                .padding(.horizontal)
//                .navigationTitle("Date of Birth")
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .confirmationAction) {
//                        Button("Done") { showDOBPicker = false }
//                            .fontWeight(.semibold)
//                            .foregroundStyle(Color.hcBrown)
//                    }
//                }
//        }
//        .presentationDetents([.medium, .large])
//        .presentationDragIndicator(.visible)
//    }
//
//    // MARK: 4a · Hair Profile Card
//
//    private var hairProfileCard: some View {
//        VStack(spacing: 0) {
//            sectionHeader(icon: "scissors", iconColor: Color.hcBrown, title: "Hair Profile")
//            Divider().padding(.leading, 16)
//
//            infoRow(label: "Current Diagnosis",
//                    value: report?.hairFallStage.displayName ?? "—",
//                    valueColor: Color(red: 0.85, green: 0.30, blue: 0.10))
//            cardDivider
//            infoRow(label: "Hair Type",
//                    value: (profile?.hairType ?? "—").capitalized)
//            cardDivider
//            infoRow(label: "Scalp Type",
//                    value: (profile?.scalpType ?? "—").capitalized)
//        }
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//        .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
//        .padding(.horizontal, 16)
//    }
//
//    // MARK: 4b · Wellness Profile Cards
//
//    private var wellnessProfileCards: some View {
//        VStack(spacing: 14) {
//
//            // Goals
//            VStack(spacing: 0) {
//                sectionHeader(icon: "bolt.heart.fill", iconColor: .orange, title: "Daily Goals")
//                Divider().padding(.leading, 16)
//
//                let kcal  = Int(nutrition?.tdee ?? 2038)
//                let waterL = String(format: "%.1fL", Float(nutrition?.waterTargetML ?? 2450) / 1000)
//                infoRow(label: "Calorie Goal",    value: "\(kcal) kcal", valueColor: .orange)
//                cardDivider
//                infoRow(label: "Hydration Goal",  value: waterL, valueColor: Color(red: 0.10, green: 0.52, blue: 0.92))
//                cardDivider
//                infoRow(label: "Height",          value: "\(Int(profile?.heightCm ?? 0)) cm")
//                cardDivider
//                infoRow(label: "Weight",          value: "\(Int(profile?.weightKg ?? 0)) kg")
//            }
//            .background(Color.white)
//            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//            .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
//
//            // Veg Mode
//            HStack(spacing: 14) {
//                RoundedRectangle(cornerRadius: 9, style: .continuous)
//                    .fill(Color.green)
//                    .frame(width: 34, height: 34)
//                    .overlay(
//                        Image(systemName: "leaf.fill")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundStyle(.white)
//                    )
//                Text("Veg Mode")
//                    .font(.system(size: 15, weight: .medium))
//                    .foregroundStyle(.primary)
//                Spacer()
//                Toggle("", isOn: Binding(
//                    get: { profile?.isVegetarian ?? false },
//                    set: { _ in }
//                ))
//                .toggleStyle(SwitchToggleStyle(tint: .green))
//                .labelsHidden()
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 14)
//            .background(Color.white)
//            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//            .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
//
//            // MindEase
//            VStack(spacing: 0) {
//                sectionHeader(icon: "brain.head.profile", iconColor: Color(red: 0.45, green: 0.30, blue: 0.85), title: "MindEase")
//                Divider().padding(.leading, 16)
//
//                infoRow(label: "Daily Yoga",
//                        value: "\(plan?.yogaMinutesPerDay ?? 0) min/day",
//                        valueColor: Color(red: 0.30, green: 0.65, blue: 0.40))
//                cardDivider
//                infoRow(label: "Meditation",
//                        value: "\(plan?.meditationMinutesPerDay ?? 0) min/day",
//                        valueColor: Color(red: 0.45, green: 0.30, blue: 0.85))
//                cardDivider
//                infoRow(label: "Relaxing Sound",
//                        value: "\(plan?.soundMinutesPerDay ?? 0) min/day",
//                        valueColor: Color(red: 0.10, green: 0.52, blue: 0.92))
//            }
//            .background(Color.white)
//            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//            .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
//        }
//        .padding(.horizontal, 16)
//    }
//
//    // MARK: Shared sub-views
//
//    private func sectionHeader(icon: String, iconColor: Color, title: String) -> some View {
//        HStack(spacing: 10) {
//            RoundedRectangle(cornerRadius: 8, style: .continuous)
//                .fill(iconColor.opacity(0.12))
//                .frame(width: 30, height: 30)
//                .overlay(
//                    Image(systemName: icon)
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundStyle(iconColor)
//                )
//            Text(title)
//                .font(.system(size: 13, weight: .bold))
//                .foregroundStyle(.secondary)
//                .textCase(.uppercase)
//                .kerning(0.5)
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//    }
//
//    private func infoRow(
//        label: String,
//        value: String,
//        valueColor: Color = Color.hcBrown
//    ) -> some View {
//        HStack {
//            Text(label)
//                .font(.system(size: 15, weight: .medium))
//                .foregroundStyle(.primary)
//            Spacer()
//            Text(value)
//                .font(.system(size: 13, weight: .bold))
//                .foregroundStyle(valueColor)
//                .padding(.horizontal, 10)
//                .padding(.vertical, 5)
//                .background(valueColor.opacity(0.09), in: Capsule())
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 13)
//    }
//
//    // MARK: Helpers
//
//    private func loadFields() {
//        fullName    = user?.name        ?? ""
//        phoneNumber = user?.phoneNumber ?? ""
//        email       = user?.email       ?? ""
//        if let dob = profile?.dateOfBirth { dateOfBirth = dob }
//    }
//
//    private func saveProfile() {
//        if let idx = store.users.firstIndex(where: { $0.id == store.currentUserId }) {
//            store.users[idx].name        = fullName
//            store.users[idx].phoneNumber = phoneNumber
//            store.users[idx].email       = email
//        }
//        if let idx = store.userProfiles.firstIndex(where: { $0.userId == store.currentUserId }) {
//            store.userProfiles[idx].displayName = fullName
//            store.userProfiles[idx].dateOfBirth = dateOfBirth
//        }
//        dismiss()
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    NavigationStack { MyProfileView() }
//        .environment(AppDataStore())
//}

//
//  MyProfileView.swift
//  HairCure
//
//  Profile → My Profile — iOS 18+ native redesign
//  Design decisions:
//  • Fullscreen scroll with cream background
//  • Avatar with live photo badge — centered above fields
//  • Personal info in a single white card with icon-prefixed rows
//  • Segmented control uses native `.segmented` style via Picker
//  • Hair Profile / Wellness Profile cards with warm badge values
//  • "Update Profile" uses `.borderedProminent` tinted to hcBrown
//

import SwiftUI

// MARK: - MyProfileView

struct MyProfileView: View {
    @Environment(AppDataStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var fullName:     String = ""
    @State private var phoneNumber:  String = ""
    @State private var email:        String = ""
    @State private var dateOfBirth:  Date   = Date()
    @State private var showDOBPicker = false
    @State private var selectedTab:  ProfileTab = .hair
    @State private var appeared      = false

    // Wellness editable fields
    @State private var calorieGoal:    String = ""
    @State private var waterGoalML:    String = ""
    @State private var heightCm:       String = ""
    @State private var weightKg:       String = ""
    @State private var isVegetarian:   Bool   = false
    @State private var yogaMinutes:    String = ""
    @State private var meditationMins: String = ""
    @State private var soundMins:      String = ""

    // Hair editable fields
    @State private var hairType:  String = ""
    @State private var scalpType: String = ""

    enum ProfileTab: String, CaseIterable {
        case hair     = "Hair Profile"
        case wellness = "Wellness"
    }

    private var user:      User?                 { store.users.first(where: { $0.id == store.currentUserId }) }
    private var profile:   UserProfile?          { store.userProfiles.first(where: { $0.userId == store.currentUserId }) }
    private var report:    ScanReport?           { store.scanReports.last }
    private var plan:      UserPlan?             { store.userPlans.first(where: { $0.userId == store.currentUserId }) }
    private var nutrition: UserNutritionProfile? { store.userNutritionProfiles.first(where: { $0.userId == store.currentUserId }) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // 1 ── Avatar
                avatarSection
                    .padding(.top, 8)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                // 2 ── Personal fields
                personalFieldsCard
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                // 3 ── Segmented picker (native)
                Picker("Profile section", selection: $selectedTab) {
                    ForEach(ProfileTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color.hcBrown)
                .padding(.horizontal, 16)

                // 4 ── Tab content
                Group {
                    switch selectedTab {
                    case .hair:     hairProfileCard
                    case .wellness: wellnessProfileCards
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: selectedTab == .hair ? .leading : .trailing)),
                    removal:   .opacity
                ))
                .animation(.spring(response: 0.38, dampingFraction: 0.80), value: selectedTab)

                // 5 ── Update button
                Button(action: saveProfile) {
                    Label("Update Profile", systemImage: "checkmark")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.hcBrown)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.hcBrown.opacity(0.30), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color.hcCream.ignoresSafeArea())
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadFields()
            withAnimation(.spring(response: 0.48, dampingFraction: 0.78).delay(0.05)) {
                appeared = true
            }
        }
    }

    // MARK: 1 · Avatar

    private var avatarSection: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.hcBrown.opacity(0.16), Color.hcBrown.opacity(0.07)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle().stroke(Color.hcBrown.opacity(0.20), lineWidth: 1.5)
                    )
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 42))
                            .foregroundStyle(Color.hcBrown.opacity(0.65))
                            .offset(y: 4)
                            .clipShape(Circle())
                    )

                // Camera badge
                ZStack {
                    Circle()
                        .fill(Color.hcBrown)
                        .frame(width: 28, height: 28)
                        .shadow(color: Color.hcBrown.opacity(0.4), radius: 4, x: 0, y: 2)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .offset(x: 2, y: 2)
            }

            // Name displayed under avatar
            if !fullName.isEmpty {
                Text(fullName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
    }

    // MARK: 2 · Personal Fields Card

    private var personalFieldsCard: some View {
        VStack(spacing: 0) {
            personalRow(
                icon: "person.fill",
                iconColor: Color.hcBrown,
                label: "Full Name"
            ) {
                TextField("Full name", text: $fullName)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
            }

            cardDivider

            personalRow(
                icon: "phone.fill",
                iconColor: Color(red: 0.20, green: 0.60, blue: 0.28),
                label: "Phone"
            ) {
                TextField("+91 9876543210", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
            }

            cardDivider

            personalRow(
                icon: "envelope.fill",
                iconColor: Color(red: 0.10, green: 0.48, blue: 0.90),
                label: "Email"
            ) {
                TextField("user@example.com", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
            }

            cardDivider

            personalRow(
                icon: "calendar",
                iconColor: Color(red: 0.85, green: 0.40, blue: 0.10),
                label: "Date of Birth"
            ) {
                Button { showDOBPicker = true } label: {
                    HStack {
                        Text(dobDisplayText)
                            .font(.system(size: 15))
                            .foregroundStyle(dobDisplayText == "DD / MM / YYYY"
                                ? Color(UIColor.placeholderText) : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .sheet(isPresented: $showDOBPicker) { dobPickerSheet }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
        .padding(.horizontal, 16)
    }

    private func personalRow<Content: View>(
        icon: String, iconColor: Color, label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(iconColor)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .kerning(0.3)
                content()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private var cardDivider: some View {
        Divider().padding(.leading, 64)
    }

    // MARK: DOB helpers

    private var dobDisplayText: String {
        if Calendar.current.isDateInToday(dateOfBirth) && fullName.isEmpty { return "DD / MM / YYYY" }
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
                            .foregroundStyle(Color.hcBrown)
                    }
                }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: 4a · Hair Profile Card

    private var hairProfileCard: some View {
        VStack(spacing: 0) {
            sectionHeader(icon: "scissors", iconColor: Color.hcBrown, title: "Hair Profile")
            Divider().padding(.leading, 16)

            // Diagnosis — read-only (set by scan)
            infoRow(label: "Current Diagnosis",
                    value: report?.hairFallStage.displayName ?? "—",
                    valueColor: Color(red: 0.85, green: 0.30, blue: 0.10))
            cardDivider
            editableRow(
                icon: "wind",
                iconColor: Color(red: 0.55, green: 0.35, blue: 0.10),
                label: "Hair Type",
                placeholder: "e.g. Wavy",
                text: $hairType,
                keyboardType: .default
            )
            cardDivider
            editableRow(
                icon: "drop.halffull",
                iconColor: Color(red: 0.10, green: 0.52, blue: 0.92),
                label: "Scalp Type",
                placeholder: "e.g. Dry",
                text: $scalpType,
                keyboardType: .default
            )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
        .padding(.horizontal, 16)
    }

    // MARK: 4b · Wellness Profile Cards

    private var wellnessProfileCards: some View {
        VStack(spacing: 14) {

            // Goals
            VStack(spacing: 0) {
                sectionHeader(icon: "bolt.heart.fill", iconColor: .orange, title: "Daily Goals")
                Divider().padding(.leading, 16)

                editableRow(
                    icon: "flame.fill",
                    iconColor: .orange,
                    label: "Calorie Goal",
                    placeholder: "kcal",
                    text: $calorieGoal,
                    unit: "kcal",
                    keyboardType: .numberPad
                )
                cardDivider
                editableRow(
                    icon: "drop.fill",
                    iconColor: Color(red: 0.10, green: 0.52, blue: 0.92),
                    label: "Hydration Goal",
                    placeholder: "mL",
                    text: $waterGoalML,
                    unit: "mL",
                    keyboardType: .numberPad
                )
                cardDivider
                editableRow(
                    icon: "ruler.fill",
                    iconColor: Color(red: 0.40, green: 0.40, blue: 0.45),
                    label: "Height",
                    placeholder: "cm",
                    text: $heightCm,
                    unit: "cm",
                    keyboardType: .numberPad
                )
                cardDivider
                editableRow(
                    icon: "scalemass.fill",
                    iconColor: Color(red: 0.55, green: 0.35, blue: 0.10),
                    label: "Weight",
                    placeholder: "kg",
                    text: $weightKg,
                    unit: "kg",
                    keyboardType: .decimalPad
                )
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)

            // Veg Mode
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.green)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                Text("Veg Mode")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
                Spacer()
                Toggle("", isOn: $isVegetarian)
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)

            // MindEase
            VStack(spacing: 0) {
                sectionHeader(icon: "brain.head.profile", iconColor: Color(red: 0.45, green: 0.30, blue: 0.85), title: "MindEase")
                Divider().padding(.leading, 16)

                editableRow(
                    icon: "figure.yoga",
                    iconColor: Color(red: 0.30, green: 0.65, blue: 0.40),
                    label: "Daily Yoga",
                    placeholder: "min",
                    text: $yogaMinutes,
                    unit: "min/day",
                    keyboardType: .numberPad
                )
                cardDivider
                editableRow(
                    icon: "brain.head.profile",
                    iconColor: Color(red: 0.45, green: 0.30, blue: 0.85),
                    label: "Meditation",
                    placeholder: "min",
                    text: $meditationMins,
                    unit: "min/day",
                    keyboardType: .numberPad
                )
                cardDivider
                editableRow(
                    icon: "music.note",
                    iconColor: Color(red: 0.10, green: 0.52, blue: 0.92),
                    label: "Relaxing Sound",
                    placeholder: "min",
                    text: $soundMins,
                    unit: "min/day",
                    keyboardType: .numberPad
                )
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.055), radius: 10, x: 0, y: 3)
        }
        .padding(.horizontal, 16)
    }

    // MARK: Shared sub-views

    private func sectionHeader(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(iconColor.opacity(0.12))
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(iconColor)
                )
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.5)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    /// Editable row — shows a coloured icon, a label, a live TextField, and an optional trailing unit badge.
    private func editableRow(
        icon: String,
        iconColor: Color,
        label: String,
        placeholder: String,
        text: Binding<String>,
        unit: String? = nil,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(iconColor)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .kerning(0.3)
                TextField(placeholder, text: text)
                    .font(.system(size: 15, weight: .medium))
                    .keyboardType(keyboardType)
                    .foregroundStyle(.primary)
            }

            Spacer()

            if let unit {
                Text(unit)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(iconColor.opacity(0.10), in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    private func infoRow(
        label: String,
        value: String,
        valueColor: Color = Color.hcBrown
    ) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(valueColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(valueColor.opacity(0.09), in: Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    // MARK: Helpers

    private func loadFields() {
        fullName    = user?.name        ?? ""
        phoneNumber = user?.phoneNumber ?? ""
        email       = user?.email       ?? ""
        if let dob = profile?.dateOfBirth { dateOfBirth = dob }

        // Wellness
        calorieGoal    = "\(Int(nutrition?.tdee ?? 2038))"
        waterGoalML    = "\(Int(nutrition?.waterTargetML ?? 2450))"
        heightCm       = "\(Int(profile?.heightCm ?? 0))"
        weightKg       = "\(Int(profile?.weightKg ?? 0))"
        isVegetarian   = profile?.isVegetarian ?? false
        yogaMinutes    = "\(plan?.yogaMinutesPerDay ?? 0)"
        meditationMins = "\(plan?.meditationMinutesPerDay ?? 0)"
        soundMins      = "\(plan?.soundMinutesPerDay ?? 0)"

        // Hair
        hairType  = (profile?.hairType  ?? "").capitalized
        scalpType = (profile?.scalpType ?? "").capitalized
    }

    private func saveProfile() {
        if let idx = store.users.firstIndex(where: { $0.id == store.currentUserId }) {
            store.users[idx].name        = fullName
            store.users[idx].phoneNumber = phoneNumber
            store.users[idx].email       = email
        }
        if let idx = store.userProfiles.firstIndex(where: { $0.userId == store.currentUserId }) {
            store.userProfiles[idx].displayName = fullName
            store.userProfiles[idx].dateOfBirth = dateOfBirth
            store.userProfiles[idx].hairType    = hairType.lowercased()
            store.userProfiles[idx].scalpType   = scalpType.lowercased()
            store.userProfiles[idx].heightCm    = Float(heightCm) ?? store.userProfiles[idx].heightCm
            store.userProfiles[idx].weightKg    = Float(weightKg) ?? store.userProfiles[idx].weightKg
            store.userProfiles[idx].isVegetarian = isVegetarian
        }
        if let idx = store.userNutritionProfiles.firstIndex(where: { $0.userId == store.currentUserId }) {
            store.userNutritionProfiles[idx].tdee          = Float(calorieGoal) ?? store.userNutritionProfiles[idx].tdee
            store.userNutritionProfiles[idx].waterTargetML = Float(waterGoalML) ?? store.userNutritionProfiles[idx].waterTargetML
        }
        if let idx = store.userPlans.firstIndex(where: { $0.userId == store.currentUserId }) {
            store.userPlans[idx].yogaMinutesPerDay        = Int(yogaMinutes)    ?? store.userPlans[idx].yogaMinutesPerDay
            store.userPlans[idx].meditationMinutesPerDay  = Int(meditationMins) ?? store.userPlans[idx].meditationMinutesPerDay
            store.userPlans[idx].soundMinutesPerDay       = Int(soundMins)      ?? store.userPlans[idx].soundMinutesPerDay
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack { MyProfileView() }
        .environment(AppDataStore())
}

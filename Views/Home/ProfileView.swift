@ViewBuilder
private func settingsList() -> some View {
    List {
        Section(header: Text("App Settings").foregroundStyle(themeManager.currentTheme.secondaryText)) {
            // Notifications
            Button(action: { showNotificationSettings = true }) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(themeManager.currentTheme.accent)
                        .frame(width: 24, height: 24)
                    Text("Notifications")
                        .foregroundStyle(themeManager.currentTheme.text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(themeManager.currentTheme.text)
                }
            }
            .sheet(isPresented: $showNotificationSettings) {
                NotificationSettingsView(context: PersistenceController.shared.viewContext)
                    .presentationBackground(themeManager.currentTheme.secondaryBackground)
            }
            
            // App Theme
            Button(action: { showThemeView = true }) {
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .foregroundStyle(themeManager.currentTheme.accent)
                        .frame(width: 24, height: 24)
                    Text("App Theme")
                        .foregroundStyle(themeManager.currentTheme.text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(themeManager.currentTheme.text)
                }
            }
            .sheet(isPresented: $showThemeView) {
                AppThemeView()
                    .presentationBackground(themeManager.currentTheme.secondaryBackground)
            }
            
            // About App
            Button(action: { showAboutView = true }) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(themeManager.currentTheme.accent)
                        .frame(width: 24, height: 24)
                    Text("About SwiftTask")
                        .foregroundStyle(themeManager.currentTheme.text)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(themeManager.currentTheme.text)
                }
            }
            .sheet(isPresented: $showAboutView) {
                AboutSwiftTaskView()
                    .presentationBackground(themeManager.currentTheme.secondaryBackground)
            }
        }
        .listRowBackground(themeManager.currentTheme.background)
    }
} 
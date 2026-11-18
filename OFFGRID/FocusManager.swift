import Combine
import FamilyControls
import Foundation
import ManagedSettings

@MainActor
final class FocusManager: ObservableObject {
    @Published private(set) var authorizationStatus: AuthorizationStatus
    @Published var selection: FamilyActivitySelection
    @Published private(set) var mode: FocusMode
    @Published var isShowingError = false
    @Published private(set) var errorMessage = ""

    private let settingsStore = ManagedSettingsStore()
    private let defaults = UserDefaults.standard

    private let selectionKey = "offgrid.familyActivitySelection"
    private let modeKey = "offgrid.focusMode"

    init() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        mode = FocusMode(rawValue: defaults.string(forKey: modeKey) ?? "") ?? .open

        if let savedData = defaults.data(forKey: selectionKey),
           let savedSelection = try? PropertyListDecoder().decode(
                FamilyActivitySelection.self,
                from: savedData
           ) {
            selection = savedSelection
        } else {
            selection = FamilyActivitySelection()
        }

        // Never assume authorization is still available after an app reinstall,
        // device restore, or a change in Screen Time settings.
        if authorizationStatus == .approved {
            apply(mode)
        } else {
            mode = .open
            defaults.set(FocusMode.open.rawValue, forKey: modeKey)
            apply(.open)
        }
    }

    var isAuthorized: Bool {
        authorizationStatus == .approved
    }

    var selectedAppCount: Int {
        selection.applicationTokens.count
    }

    var selectedWebsiteCount: Int {
        selection.webDomainTokens.count
    }

    var selectedCategoryCount: Int {
        selection.categoryTokens.count
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus

            if isAuthorized {
                apply(mode)
            } else {
                showError("Screen Time authorization was not granted. You can try again in Settings.")
            }
        } catch {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            showError("OFFGRID could not get Screen Time access: \(error.localizedDescription)")
        }
    }

    func saveSelection() {
        if let encoded = try? PropertyListEncoder().encode(selection) {
            defaults.set(encoded, forKey: selectionKey)
        }

        if mode.isRestrictive {
            apply(mode)
        }
    }

    func activate(_ newMode: FocusMode) {
        guard newMode == .open || isAuthorized else {
            showError("Allow Screen Time access before turning on Dumb or Work mode.")
            return
        }

        mode = newMode
        defaults.set(newMode.rawValue, forKey: modeKey)
        apply(newMode)
    }

    private func apply(_ selectedMode: FocusMode) {
        guard selectedMode.isRestrictive, isAuthorized else {
            settingsStore.shield.applications = nil
            settingsStore.shield.webDomains = nil
            settingsStore.shield.applicationCategories = nil
            settingsStore.shield.webDomainCategories = nil
            return
        }

        settingsStore.shield.applications = selection.applicationTokens.isEmpty
            ? nil
            : selection.applicationTokens

        settingsStore.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil
            : selection.webDomainTokens

        settingsStore.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)

        settingsStore.shield.webDomainCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
    }

    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
    }
}

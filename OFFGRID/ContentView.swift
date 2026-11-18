import FamilyControls
import SwiftUI

struct ContentView: View {
    @StateObject private var manager = FocusManager()
    @State private var isShowingAppPicker = false

    private let background = Color(red: 0.035, green: 0.04, blue: 0.05)
    private let panel = Color(red: 0.085, green: 0.095, blue: 0.11)
    private let accent = Color(red: 0.77, green: 0.95, blue: 0.45)

    var body: some View {
        ZStack {
            background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    introduction
                    currentModeCard

                    if !manager.isAuthorized {
                        authorizationCard
                    }

                    modePicker
                    appSelectionCard
                    essentialsCard
                    footer
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 36)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isShowingAppPicker) {
            AppSelectionSheet(selection: $manager.selection)
                .presentationDetents([.large])
        }
        .onChange(of: manager.selection) { _ in
            manager.saveSelection()
        }
        .alert("OFFGRID", isPresented: $manager.isShowingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(manager.errorMessage)
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 9) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(accent)

                Text("OFFGRID")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .tracking(3.5)
                    .foregroundStyle(.white)
            }

            Spacer()

            Text("BETA 01")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundStyle(.white.opacity(0.42))
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("TAKE BACK\nYOUR ATTENTION.")
                .font(.system(size: 37, weight: .black, design: .rounded))
                .tracking(-1.7)
                .lineSpacing(-1)
                .foregroundStyle(.white)

            Text("A quieter phone starts with one intentional choice.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.white.opacity(0.56))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
    }

    private var currentModeCard: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack {
                Text("CURRENT MODE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                Circle()
                    .fill(manager.mode.isRestrictive ? accent : Color.white.opacity(0.35))
                    .frame(width: 7, height: 7)

                Text(manager.mode.isRestrictive ? "PROTECTED" : "AVAILABLE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(manager.mode.isRestrictive ? accent : .white.opacity(0.55))
            }

            HStack(alignment: .center, spacing: 16) {
                Image(systemName: manager.mode.symbol)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(accent)
                    .frame(width: 62, height: 62)
                    .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 19))

                VStack(alignment: .leading, spacing: 5) {
                    Text("\(manager.mode.title) MODE")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .tracking(0.5)
                        .foregroundStyle(.white)

                    Text(manager.mode.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.55))
                }

                Spacer(minLength: 0)
            }
        }
        .padding(20)
        .background(panel, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        }
    }

    private var authorizationCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label("SCREEN TIME ACCESS", systemImage: "lock.shield")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.2)
                .foregroundStyle(accent)

            Text("Give OFFGRID permission to keep your chosen apps available and shield the rest.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)

            Button {
                Task {
                    await manager.requestAuthorization()
                }
            } label: {
                HStack {
                    Text("ENABLE SCREEN TIME ACCESS")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(1)
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(accent, in: RoundedRectangle(cornerRadius: 13))
            }
            .buttonStyle(.plain)
        }
        .padding(19)
        .background(panel, in: RoundedRectangle(cornerRadius: 21))
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 13) {
            sectionHeading("YOUR MODES", detail: "SWITCH WHEN YOU NEED")

            HStack(spacing: 10) {
                ForEach(FocusMode.allCases) { mode in
                    Button {
                        manager.activate(mode)
                    } label: {
                        VStack(alignment: .leading, spacing: 13) {
                            Image(systemName: mode.symbol)
                                .font(.system(size: 18, weight: .semibold))

                            VStack(alignment: .leading, spacing: 3) {
                                Text(mode.title)
                                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                                    .tracking(1)

                                Text(mode == .open ? "No shields" : "Allow list")
                                    .font(.system(size: 10, weight: .medium))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        .foregroundStyle(manager.mode == mode ? .black : .white.opacity(0.72))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(13)
                        .background(
                            manager.mode == mode ? accent : panel,
                            in: RoundedRectangle(cornerRadius: 17)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 17)
                                .stroke(.white.opacity(manager.mode == mode ? 0 : 0.06), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var appSelectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading("YOUR KEEP LIST", detail: "STAYS AVAILABLE")

            Button {
                Task {
                    if !manager.isAuthorized {
                        await manager.requestAuthorization()
                    }
                    if manager.isAuthorized {
                        isShowingAppPicker = true
                    }
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 21, weight: .medium))
                        .foregroundStyle(accent)
                        .frame(width: 48, height: 48)
                        .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 15))

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Choose apps to keep")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)

                        Text("\(manager.selectedAppCount) apps  ·  \(manager.selectedWebsiteCount) websites  ·  \(manager.selectedCategoryCount) categories")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.48))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(15)
                .background(panel, in: RoundedRectangle(cornerRadius: 19))
                .overlay {
                    RoundedRectangle(cornerRadius: 19)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)

            Text("Only the apps, websites and categories in this list stay available in Dumb and Work modes. Everything else is shielded. Add essentials such as Phone, Messages and Maps before activating. Open mode removes OFFGRID's shields.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.44))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var essentialsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            sectionHeading("START WITH THESE ESSENTIALS", detail: "SUGGESTED KEEP LIST")

            Text("These are recommendations, not automatic permissions. Choose the apps that are actually installed on your iPhone using the system picker.")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.48))
                .fixedSize(horizontal: false, vertical: true)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(EssentialApp.defaults) { app in
                    HStack(spacing: 9) {
                        Image(systemName: app.symbol)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(accent)
                            .frame(width: 22)

                        Text(app.name)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.88))
                            .lineLimit(1)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 12)
                    .background(panel, in: RoundedRectangle(cornerRadius: 13))
                }
            }

            Label {
                Text("The Simulator can show an empty app list. Run OFFGRID on your real iPhone to select the apps installed on that device.")
                    .font(.system(size: 11))
                    .fixedSize(horizontal: false, vertical: true)
            } icon: {
                Image(systemName: "iphone.gen3")
                    .foregroundStyle(accent)
            }
            .foregroundStyle(.white.opacity(0.62))
            .padding(13)
            .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        }
        .padding(17)
        .background(panel.opacity(0.72), in: RoundedRectangle(cornerRadius: 21))
        .overlay {
            RoundedRectangle(cornerRadius: 21)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        }
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)

            Text("LESS SCROLLING. MORE LIVING.")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.35))

            Text("OFFGRID is a focus tool, not a replacement Home Screen.")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.28))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
    }

    private func sectionHeading(_ title: String, detail: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .tracking(1.6)
                .foregroundStyle(.white.opacity(0.85))

            Spacer()

            Text(detail)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.35))
        }
    }
}


private struct EssentialApp: Identifiable {
    let id: String
    let name: String
    let symbol: String

    static let defaults: [EssentialApp] = [
        EssentialApp(id: "phone", name: "Phone", symbol: "phone.fill"),
        EssentialApp(id: "messages", name: "Messages", symbol: "message.fill"),
        EssentialApp(id: "maps", name: "Maps", symbol: "map.fill"),
        EssentialApp(id: "calendar", name: "Calendar", symbol: "calendar"),
        EssentialApp(id: "camera", name: "Camera", symbol: "camera.fill"),
        EssentialApp(id: "photos", name: "Photos", symbol: "photo.fill"),
        EssentialApp(id: "wallet", name: "Wallet", symbol: "wallet.pass.fill"),
        EssentialApp(id: "music", name: "Music", symbol: "music.note"),
        EssentialApp(id: "mail", name: "Mail", symbol: "envelope.fill"),
        EssentialApp(id: "notes", name: "Notes", symbol: "note.text"),
        EssentialApp(id: "passwords", name: "Passwords", symbol: "key.fill"),
        EssentialApp(id: "authenticator", name: "Authenticator", symbol: "lock.shield.fill"),
        EssentialApp(id: "banking", name: "Banking", symbol: "building.columns.fill"),
        EssentialApp(id: "transit", name: "Transit", symbol: "tram.fill"),
        EssentialApp(id: "school-work", name: "School / Work", symbol: "book.closed.fill"),
        EssentialApp(id: "reminders", name: "Reminders", symbol: "checklist")
    ]
}

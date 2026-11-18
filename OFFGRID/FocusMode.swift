import Foundation

enum FocusMode: String, CaseIterable, Identifiable {
    case open
    case dumb
    case work

    var id: String { rawValue }

    var title: String {
        switch self {
        case .open: return "OPEN"
        case .dumb: return "DUMB"
        case .work: return "WORK"
        }
    }

    var subtitle: String {
        switch self {
        case .open:
            return "All selected apps are available."
        case .dumb:
            return "Your chosen distractions are shielded."
        case .work:
            return "Stay with the task in front of you."
        }
    }

    var symbol: String {
        switch self {
        case .open: return "sun.max"
        case .dumb: return "moon.zzz"
        case .work: return "scope"
        }
    }

    var isRestrictive: Bool {
        self != .open
    }
}

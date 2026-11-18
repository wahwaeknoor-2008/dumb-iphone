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
            return "No OFFGRID restrictions are active."
        case .dumb:
            return "Only your chosen apps and sites stay available."
        case .work:
            return "Your allowed apps stay available; the rest are shielded."
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

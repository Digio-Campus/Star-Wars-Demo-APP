import Foundation
import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    enum ThemePreference: String, CaseIterable, Identifiable {
        case system
        case light
        case dark

        var id: String { rawValue }

        var title: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }

        var subtitle: String {
            switch self {
            case .system: return "Match device settings"
            case .light: return "Always light appearance"
            case .dark: return "Always dark appearance"
            }
        }

        var symbolName: String {
            switch self {
            case .system: return "gearshape"
            case .light: return "sun.max"
            case .dark: return "moon.stars"
            }
        }

        var preferredColorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    private let userDefaults: UserDefaults
    private static let preferenceKey = "theme_preference"

    @Published var preference: ThemePreference {
        didSet {
            userDefaults.set(preference.rawValue, forKey: Self.preferenceKey)
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        if let raw = userDefaults.string(forKey: Self.preferenceKey),
           let saved = ThemePreference(rawValue: raw) {
            self.preference = saved
        } else {
            self.preference = .system
        }
    }

    var preferredColorScheme: ColorScheme? {
        preference.preferredColorScheme
    }
}

import UIKit

extension Notification.Name {
    static let appThemeDidChange = Notification.Name("appThemeDidChange")
}

enum AppThemeKind: String, CaseIterable {
    case system
    case ocean
    case forest
    case sunset
    case lavender
    case slate
}

struct AppThemeSet {
    let background: UIColor
    let secondaryBackground: UIColor
    let label: UIColor
    let secondaryLabel: UIColor
    let accent: UIColor
    let completedMuted: UIColor
    let tabBarBackground: UIColor
    let tabBarSelected: UIColor
    let tabBarUnselected: UIColor
}

enum AppTheme {
    private static let defaults = UserDefaults.standard

    static var currentKind: AppThemeKind {
        get {
            let raw = defaults.string(forKey: UserDefaultsKeys.selectedTheme) ?? AppThemeKind.system.rawValue
            return AppThemeKind(rawValue: raw) ?? .system
        }
        set {
            defaults.set(newValue.rawValue, forKey: UserDefaultsKeys.selectedTheme)
            NotificationCenter.default.post(name: .appThemeDidChange, object: nil)
        }
    }

    static var current: AppThemeSet {
        switch currentKind {
        case .system:
            return AppThemeSet(
                background: UIColor(red: 0.98, green: 0.98, blue: 0.97, alpha: 1),
                secondaryBackground: UIColor(red: 0.94, green: 0.94, blue: 0.93, alpha: 1),
                label: UIColor(red: 0.2, green: 0.22, blue: 0.24, alpha: 1),
                secondaryLabel: UIColor(red: 0.45, green: 0.47, blue: 0.5, alpha: 1),
                accent: UIColor(red: 0.38, green: 0.52, blue: 0.48, alpha: 1),
                completedMuted: UIColor(red: 0.91, green: 0.92, blue: 0.91, alpha: 1),
                tabBarBackground: UIColor(red: 0.94, green: 0.95, blue: 0.94, alpha: 1),
                tabBarSelected: UIColor(red: 0.38, green: 0.52, blue: 0.48, alpha: 1),
                tabBarUnselected: UIColor(red: 0.55, green: 0.57, blue: 0.6, alpha: 1)
            )
        case .ocean:
            return AppThemeSet(
                background: UIColor(red: 0.95, green: 0.97, blue: 1, alpha: 1),
                secondaryBackground: UIColor(red: 0.88, green: 0.93, blue: 0.98, alpha: 1),
                label: UIColor(red: 0.1, green: 0.2, blue: 0.35, alpha: 1),
                secondaryLabel: UIColor(red: 0.35, green: 0.5, blue: 0.65, alpha: 1),
                accent: UIColor(red: 0.2, green: 0.5, blue: 0.85, alpha: 1),
                completedMuted: UIColor(red: 0.85, green: 0.9, blue: 0.95, alpha: 1),
                tabBarBackground: UIColor(red: 0.9, green: 0.94, blue: 0.98, alpha: 1),
                tabBarSelected: UIColor(red: 0.2, green: 0.5, blue: 0.85, alpha: 1),
                tabBarUnselected: UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1)
            )
        case .forest:
            return AppThemeSet(
                background: UIColor(red: 0.96, green: 0.98, blue: 0.95, alpha: 1),
                secondaryBackground: UIColor(red: 0.9, green: 0.94, blue: 0.88, alpha: 1),
                label: UIColor(red: 0.15, green: 0.25, blue: 0.15, alpha: 1),
                secondaryLabel: UIColor(red: 0.4, green: 0.5, blue: 0.4, alpha: 1),
                accent: UIColor(red: 0.2, green: 0.55, blue: 0.3, alpha: 1),
                completedMuted: UIColor(red: 0.88, green: 0.92, blue: 0.86, alpha: 1),
                tabBarBackground: UIColor(red: 0.88, green: 0.93, blue: 0.86, alpha: 1),
                tabBarSelected: UIColor(red: 0.2, green: 0.55, blue: 0.3, alpha: 1),
                tabBarUnselected: UIColor(red: 0.45, green: 0.55, blue: 0.45, alpha: 1)
            )
        case .sunset:
            return AppThemeSet(
                background: UIColor(red: 1, green: 0.97, blue: 0.94, alpha: 1),
                secondaryBackground: UIColor(red: 1, green: 0.92, blue: 0.88, alpha: 1),
                label: UIColor(red: 0.35, green: 0.2, blue: 0.15, alpha: 1),
                secondaryLabel: UIColor(red: 0.6, green: 0.4, blue: 0.35, alpha: 1),
                accent: UIColor(red: 0.9, green: 0.4, blue: 0.2, alpha: 1),
                completedMuted: UIColor(red: 0.98, green: 0.9, blue: 0.85, alpha: 1),
                tabBarBackground: UIColor(red: 1, green: 0.93, blue: 0.88, alpha: 1),
                tabBarSelected: UIColor(red: 0.9, green: 0.4, blue: 0.2, alpha: 1),
                tabBarUnselected: UIColor(red: 0.6, green: 0.45, blue: 0.4, alpha: 1)
            )
        case .lavender:
            return AppThemeSet(
                background: UIColor(red: 0.98, green: 0.96, blue: 1, alpha: 1),
                secondaryBackground: UIColor(red: 0.94, green: 0.9, blue: 0.98, alpha: 1),
                label: UIColor(red: 0.25, green: 0.2, blue: 0.35, alpha: 1),
                secondaryLabel: UIColor(red: 0.5, green: 0.45, blue: 0.6, alpha: 1),
                accent: UIColor(red: 0.5, green: 0.35, blue: 0.75, alpha: 1),
                completedMuted: UIColor(red: 0.92, green: 0.88, blue: 0.96, alpha: 1),
                tabBarBackground: UIColor(red: 0.93, green: 0.88, blue: 0.97, alpha: 1),
                tabBarSelected: UIColor(red: 0.5, green: 0.35, blue: 0.75, alpha: 1),
                tabBarUnselected: UIColor(red: 0.55, green: 0.5, blue: 0.65, alpha: 1)
            )
        case .slate:
            return AppThemeSet(
                background: UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1),
                secondaryBackground: UIColor(red: 0.88, green: 0.89, blue: 0.91, alpha: 1),
                label: UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 1),
                secondaryLabel: UIColor(red: 0.45, green: 0.45, blue: 0.5, alpha: 1),
                accent: UIColor(red: 0.35, green: 0.4, blue: 0.5, alpha: 1),
                completedMuted: UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1),
                tabBarBackground: UIColor(red: 0.88, green: 0.89, blue: 0.91, alpha: 1),
                tabBarSelected: UIColor(red: 0.35, green: 0.4, blue: 0.5, alpha: 1),
                tabBarUnselected: UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1)
            )
        }
    }

    static var background: UIColor { current.background }
    static var secondaryBackground: UIColor { current.secondaryBackground }
    static var label: UIColor { current.label }
    static var secondaryLabel: UIColor { current.secondaryLabel }
    static var accent: UIColor { current.accent }
    static var completedMuted: UIColor { current.completedMuted }
}

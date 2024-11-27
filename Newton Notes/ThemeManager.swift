import SwiftUI

enum AppTheme: String {
    case light = "lgt"
    case dark = "drk"
    case system = "sys"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
}

class ThemeManager: ObservableObject {
    private var storedTheme: String = "sys"
    
    var currentTheme: AppTheme {
        AppTheme(rawValue: storedTheme) ?? .system
    }
    
    func setTheme(_ theme: AppTheme) {
        storedTheme = theme.rawValue
        applyTheme()
    }
    
    func applyTheme() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let colorScheme = currentTheme.colorScheme else {
            return
        }
        
        window.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
    }
}

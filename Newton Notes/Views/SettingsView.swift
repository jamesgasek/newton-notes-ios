import Foundation
import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @AppStorage("weightUnit") private var weightUnit = "lbs"
    @AppStorage("distanceUnit") private var distanceUnit = "mi"
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Environment(\.modelContext) private var modelContext
    @Query private var routines: [Routine]
    @Query private var exerciseTemplates: [ExerciseTemplate]
    @Query private var analyticsLogs: [AnalyticsLog]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Units") {
                    Picker("Weight Unit", selection: $weightUnit) {
                        Text("Kilograms (kg)").tag("kg")
                        Text("Pounds (lbs)").tag("lbs")
                    }
                    Picker("Distance Unit", selection: $distanceUnit) {
                        Text("Kilometers (km)").tag("km")
                        Text("Miles (mi)").tag("mi")
                    }
                }
                
//                Section("Appearance") {
//                    Picker("Theme", selection: Binding(
//                        get: { themeManager.currentTheme.rawValue },
//                        set: { newValue in
//                            if let theme = AppTheme(rawValue: newValue) {
//                                themeManager.setTheme(theme)
//                            }
//                        }
//                    )) {
//                        Text("Light").tag(AppTheme.light.rawValue)
//                        Text("Dark").tag(AppTheme.dark.rawValue)
//                        Text("System").tag(AppTheme.system.rawValue)
//                    }
//                }
                
                Section("About") {
                    Link("Rate App", destination: URL(string: "https://apps.apple.com")!)
                    Link("Privacy Policy", destination: URL(string: "http://www.gasek.net/newtonnotes/privacypolicy")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

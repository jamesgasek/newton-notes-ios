//
//  File.swift
//  Newton Notes IOS
//
//  Created by James Gasek on 11/2/24.
//

import Foundation
import SwiftUI
import SwiftData
// Settings View
struct SettingsView: View {
    @AppStorage("weightUnit") private var weightUnit = "kg"
    @AppStorage("distanceUnit") private var distanceUnit = "km"
    @AppStorage("theme") private var theme = "sys"

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
                
                Section("Data") {
                    Button("Export Data", action: exportData)
                    Button("Import Data", action: importData)
                }
                
                Section("Appearance") {
//                    Button("Export Data", action: exportData)
                    Picker("Theme", selection: $theme) {
                        Text("Light").tag("lgt")
                        Text("Dark").tag("drk")
                        Text("System").tag("sys")
                    }
                    
                }

                Section("About") {
                    Link("Rate App", destination: URL(string: "https://apps.apple.com")!)
                    Link("Privacy Policy", destination: URL(string: "https://your-privacy-policy")!)
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    private func exportData() {
        // Implement export functionality
    }
    
    private func importData() {
        // Implement import functionality
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Routine.self, Exercise.self, ExerciseSet.self], inMemory: true)
}

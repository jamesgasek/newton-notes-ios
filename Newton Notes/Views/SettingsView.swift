import Foundation
import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @AppStorage("weightUnit") private var weightUnit = "lbs"
    @AppStorage("distanceUnit") private var distanceUnit = "mi"
    @AppStorage("theme") private var theme = "sys"
    @State private var showCopiedAlert = false
    @State private var copiedText = ""
    
    
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
                    }.disabled(true)
                    Picker("Distance Unit", selection: $distanceUnit) {
                        Text("Kilometers (km)").tag("km")
                        Text("Miles (mi)").tag("mi")
                    }.disabled(true)
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $theme) {
                        Text("Light").tag("lgt")
                        Text("Dark").tag("drk")
                        Text("System").tag("sys")
                    }.disabled(true)
                }
                
                Section("About") {
                    Link("Rate App", destination: URL(string: "https://apps.apple.com")!)
                    Link("Privacy Policy", destination: URL(string: "http://www.gasek.net/newtonnotes/privacypolicy")!)
                }
                
//                Section("Manage Data") {
//                    Button(action: {
//                        //here
//                    }) {
//                        Text("Import from file")
//                    }.disabled(true)
//                    
//                    Button(action: {
//                        //here
//                    }) {
//                        Text("Export")
//                    }.disabled(true)
//                }
//                
                Section("Donate") {
                    Button(action: {
                        copyToClipboard("bc1qrdc02qnvsn7sc2feml2nfma7u8u0prccln0e8p")
                        copiedText = "BTC"
                    }) {
                        Text("BTC")
                    }
                    
                    Button(action: {
                        copyToClipboard("0x38Eb349E33B86a208CCD199FC7381cDd7dCcCb2D")
                        copiedText = "ETH"
                    }) {
                        Text("ETH")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("\(copiedText) Address Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        showCopiedAlert = true
    }
    
}

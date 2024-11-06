import Foundation
import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("weightUnit") private var weightUnit = "kg"
    @AppStorage("distanceUnit") private var distanceUnit = "km"
    @AppStorage("theme") private var theme = "sys"
    @State private var showCopiedAlert = false
    @State private var copiedText = ""
    
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
                
                Section("Appearance") {
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
    
    private func exportData() {
        // Implement export functionality
    }
    
    private func importData() {
        // Implement import functionality
    }
}
//
//#Preview {
//    SettingsView()
//}

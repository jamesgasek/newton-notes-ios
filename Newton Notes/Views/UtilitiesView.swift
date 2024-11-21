////
////  UtilitiesView.swift
////  Newton Notes
////
////  Created by James Gasek on 11/20/24.
////
//
//import SwiftUI
//
//struct UtilitiesView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    UtilitiesView()
//}

import SwiftUI

struct UtilitiesView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Plate Calculator", destination: PlateCalculatorView())
            }
            .navigationTitle("Utilities")
        }
    }
}

struct PlateCalculatorView: View {
    @State private var targetWeight: Double = 0
    @State private var barbellWeight: Double = 45
    @State private var plates: [Plate] = []
    
    let availablePlates: [Double] = [45, 35, 25, 10, 5, 2.5]
    
    var body: some View {
        Form {
            Section(header: Text("Settings")) {
                HStack {
                    Text("Target Weight")
                    Spacer()
                    TextField("Weight", value: $targetWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Barbell Weight")
                    Spacer()
                    TextField("Barbell", value: $barbellWeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("Required Plates (per side)")) {
                if plates.isEmpty && targetWeight > 0 {
                    Text("No plates needed or weight not achievable")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(plates) { plate in
                        HStack {
                            Text("\(plate.count)x")
                                .foregroundColor(.secondary)
                            Text("\(Int(plate.weight))lb plates")
                        }
                    }
                }
            }
        }
        
        .navigationTitle("Plate Calculator")
        .onChange(of: targetWeight) { calculatePlates() }
        .onChange(of: barbellWeight) { calculatePlates() }
    }
    
    private func calculatePlates() {
        plates.removeAll()
        
        // Calculate weight needed on each side
        var remainingWeight = max(0, (targetWeight - barbellWeight) / 2)
        
        // Try each plate size, from largest to smallest
        for plateWeight in availablePlates {
            if remainingWeight >= plateWeight {
                let count = Int(floor(remainingWeight / plateWeight))
                plates.append(Plate(weight: plateWeight, count: count))
                remainingWeight -= Double(count) * plateWeight
            }
        }
        
        // If we can't reach the exact weight, clear the plates array
        if remainingWeight > 0.1 { // Using 0.1 to account for floating point imprecision
            plates.removeAll()
        }
    }
}

struct Plate: Identifiable {
    let id = UUID()
    let weight: Double
    let count: Int
}

//#Preview {
//    UtilitiesView()
//}

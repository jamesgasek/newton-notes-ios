//
//  AnalyticsView.swift
//  Newton Notes
//
//  Created by James Gasek on 11/7/24.
//
// Analytics page

import Foundation
import SwiftUI
import SwiftData
import Charts

struct AddLogEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existingLogs: [AnalyticsLog]
    
    @State private var selectedName: String = ""
    @State private var customName: String = ""
    @State private var value: Double = 0
    @State private var isCustomName: Bool = true
    @State private var selectedUnit: String = "lbs"  // Add near other @State vars

    
    private var uniqueNames: [String] {
        Array(Set(existingLogs.map { $0.name })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if uniqueNames.isEmpty {
                        Text("Create your first tracking category")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Category Type", selection: $isCustomName) {
                            Text("Choose Existing").tag(false)
                            Text("Create New").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    if isCustomName {
                        TextField("New Category Name", text: $customName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Picker("Select Category", selection: $selectedName) {
                            Text("Select a category").tag("")
                            ForEach(uniqueNames, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                } header: {
                    Text("What do you want to track?")
                }
                
                Section {
                    HStack {
                        TextField("Value", value: $value, format: .number)
                            .keyboardType(.decimalPad)
                        
//                        // Optional: Add unit picker if relevant
//                        Picker("Unit", selection: .constant("")) {
//                            Text("lbs").tag("lbs")
//                            Text("kg").tag("kg")
//                            Text("reps").tag("reps")
//                            // Add other relevant units
//                        }
                        Picker("Unit", selection: $selectedUnit) {
                            Text("lbs").tag("lbs")
                            Text("kg").tag("kg")
                            Text("reps").tag("reps")
                        }
                    }
                } header: {
                    Text("Enter Today's Value")
                } footer: {
                    Text("Track any numeric value like weight lifted, reps completed, or measurements")
                }
            }
            .navigationTitle("Add Progress Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let name = isCustomName ? customName : selectedName
                        if !name.isEmpty {
                            let log = AnalyticsLog(name: name, value: value, unit: selectedUnit)
                            modelContext.insert(log)
                            dismiss()
                        }
                    }
                    .disabled(isCustomName ? customName.isEmpty : selectedName.isEmpty)
                }
            }
        }
    }
}

// Updated WorkoutHistoryView
struct WorkoutHistoryView: View {
    @Query private var logs: [AnalyticsLog]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEntry = false
    @State private var selectedTimeRange: TimeRange = .week
    
    enum TimeRange {
        case week, month, year, all
    }
    
    private var uniqueNames: [String] {
        Array(Set(logs.map { $0.name })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No Progress Data",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Start tracking your progress by adding your first entry")
                    )
                } else {
                    Picker("Time Range", selection: $selectedTimeRange) {
                        Text("Week").tag(TimeRange.week)
                        Text("Month").tag(TimeRange.month)
                        Text("Year").tag(TimeRange.year)
                        Text("All Time").tag(TimeRange.all)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(uniqueNames, id: \.self) { name in
                                ChartCard(name: name, logs: logs.filter { $0.name == name })
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Progress Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add Entry", systemImage: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddLogEntryView()
            }
        }
    }
}

struct ChartCard: View {
    let name: String
    let logs: [AnalyticsLog]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                Text("\(logs.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
//            Chart {
//                ForEach(logs.sorted { $0.timestamp < $1.timestamp }) { item in
//                    LineMark(
//                        x: .value("Date", item.timestamp),
//                        y: .value("Value", item.value)
//                    )
//                    .symbol(.circle)
//                    .interpolationMethod(.catmullRom)
//                }
//            }
            Chart {
                ForEach(logs.sorted { $0.timestamp < $1.timestamp }) { item in
                    LineMark(
                        x: .value("Date", item.timestamp),
                        y: .value("Value (\(item.unit))", item.value)
                    )
                    .symbol(.circle)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .frame(height: 200)
            
            // Add latest value and change
//            if let latest = logs.max(by: { $0.timestamp < $1.timestamp }) {
//                HStack {
//                    Text("Latest: \(latest.value, specifier: "%.1f")")
//                        .font(.subheadline)
//                    Spacer()
//                    if let change = calculateChange() {
//                        Text(change >= 0 ? "↑" : "↓")
//                            .foregroundColor(change >= 0 ? .green : .red)
//                        Text("\(abs(change), specifier: "%.1f")")
//                            .font(.subheadline)
//                            .foregroundColor(change >= 0 ? .green : .red)
//                    }
//                }
//            }
            if let latest = logs.max(by: { $0.timestamp < $1.timestamp }) {
                HStack {
                    Text("Latest: \(latest.value, specifier: "%.1f") \(latest.unit)")
                        .font(.subheadline)
                    Spacer()
                    if let change = calculateChange() {
                        Text(change >= 0 ? "↑" : "↓")
                            .foregroundColor(change >= 0 ? .green : .red)
                        Text("\(abs(change), specifier: "%.1f") \(latest.unit)")
                            .font(.subheadline)
                            .foregroundColor(change >= 0 ? .green : .red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func calculateChange() -> Double? {
        let sortedLogs = logs.sorted { $0.timestamp < $1.timestamp }
        guard let latest = sortedLogs.last,
              let previous = sortedLogs.dropLast().last else {
            return nil
        }
        return latest.value - previous.value
    }
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components) ?? Date()
    }
}

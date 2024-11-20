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

enum TimeRange {
    case week, month, year, all
}

struct AddLogEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existingLogs: [AnalyticsLog]
    
    @State private var selectedName: String = ""
    @State private var customName: String = ""
    @State private var value: Double?
    @State private var chooseExisting: Bool = true
    
    private var uniqueNames: [String] {
        Array(Set(existingLogs.map { $0.name })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if uniqueNames.isEmpty {
                        //none
                    } else {
                        Picker("Category Type", selection: $chooseExisting) {
                            Text("Choose Existing").tag(true)
                            Text("Create New").tag(false)
                        }
                        .pickerStyle(.segmented)
                    }
                    if !chooseExisting || uniqueNames.isEmpty {
                        TextField("New Category Name", text: $customName)
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
                    Text(uniqueNames.isEmpty ? "Create your first tracking category" : "What do you want to track?")
                }
                
                Section {
                    HStack {
                        TextField("Value", value: $value, format: .number)
                            .keyboardType(.decimalPad)
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
                        // Use customName for first entry or when creating new, otherwise use selectedName
                        let name = (uniqueNames.isEmpty || !chooseExisting) ? customName : selectedName
                        if !name.isEmpty, let actualValue = value {
                            let log = AnalyticsLog(name: name, value: actualValue)
                            modelContext.insert(log)
                            dismiss()
                        }
                    }
                    .disabled(value == nil || (uniqueNames.isEmpty ? customName.isEmpty : (!chooseExisting ? customName.isEmpty : selectedName.isEmpty)))
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
    
    private var uniqueNames: [String] {
        Array(Set(logs.map { $0.name })).sorted()
    }
    
    private func filterLogs(_ logs: [AnalyticsLog]) -> [AnalyticsLog] {
           let calendar = Calendar.current
           let now = Date()
           
           switch selectedTimeRange {
           case .week:
               let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
               return logs.filter { $0.timestamp >= oneWeekAgo }
           case .month:
               let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
               return logs.filter { $0.timestamp >= oneMonthAgo }
           case .year:
               let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
               return logs.filter { $0.timestamp >= oneYearAgo }
           case .all:
               return logs
           }
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
                                ChartCard(
                                        name: name,
                                        logs: filterLogs(logs.filter { $0.name == name }),
                                        timeRange: selectedTimeRange

                                    )
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
//    let name: String
//    let logs: [AnalyticsLog]
    let name: String
    let logs: [AnalyticsLog]
    let timeRange: TimeRange  // Add this parameter
    
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
//                        y: .value("Value ", item.value)
//                    )
//                    .symbol(.circle)
//                    .interpolationMethod(.catmullRom)
//                }
//            }
//            .chartYAxis {
//                AxisMarks(position: .leading)
//            }
//            .chartXAxis {
//                AxisMarks(values: .stride(by: .day, count: 7)) { value in
//                    AxisGridLine()
//                    AxisValueLabel(format: .dateTime.month().day())
//                }
//            }
//            .frame(height: 200)
//            Chart {
//                ForEach(logs.sorted { $0.timestamp < $1.timestamp }) { item in
//                    LineMark(
//                        x: .value("Date", item.timestamp),
//                        y: .value("Value", item.value)
//                    )
//                    .symbol(.circle)
//                    .interpolationMethod(.linear) // Changed from .catmullRom to .linear for straight lines
//                }
//            }
//            .chartYAxis {
//                AxisMarks(position: .leading) {
//                    AxisValueLabel() // This ensures the value labels show
//                }
//            }
//            .chartXAxis {
//                AxisMarks { value in
//                    AxisGridLine()
//                    AxisValueLabel {
//                        // Customize date format based on selected time range
//                        if let date = value.as(Date.self) {
//                            switch timeRange {  // You'll need to pass timeRange as a parameter
//                            case .week:
//                                Text(date, format: .dateTime.weekday())
//                            case .month:
//                                Text(date, format: .dateTime.day())
//                            case .year:
//                                Text(date, format: .dateTime.month())
//                            case .all:
//                                Text(date, format: .dateTime.month().year())
//                            }
//                        }
//                    }
//                }
//            }
//            .frame(height: 200)
            Chart {
                ForEach(logs.sorted { $0.timestamp < $1.timestamp }) { item in
                    LineMark(
                        x: .value("Date", item.timestamp),
                        y: .value("Value", item.value)
                    )
                    .symbol(.circle)
                    .interpolationMethod(.linear)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisValueLabel()
                }
            }
            .chartXAxis {
                // Add appropriate stride based on time range
                switch timeRange {
                case .week:
                    AxisMarks(values: .stride(by: .day, count: 1)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                case .month:
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.day())
                            }
                        }
                    }
                case .year:
                    AxisMarks(values: .stride(by: .month, count: 1)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.month(.abbreviated))
                            }
                        }
                    }
                case .all:
                    AxisMarks(values: .stride(by: .month, count: 3)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.month(.abbreviated).year())
                            }
                        }
                    }
                }
            }
            .frame(height: 200)
            
            if let latest = logs.max(by: { $0.timestamp < $1.timestamp }) {
                HStack {
                    Text("Latest: \(latest.value, specifier: "%.1f")")
                        .font(.subheadline)
                    Spacer()
                    if let change = calculateChange() {
                        Text(change >= 0 ? "↑" : "↓")
                            .foregroundColor(change >= 0 ? .green : .red)
                        Text("\(abs(change), specifier: "%.1f")")
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

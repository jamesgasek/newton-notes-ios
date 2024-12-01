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
    @State private var isCumulative: Bool = false
    @State private var unit: String = ""
    @State private var dailyTotal: Double = 0
    @State private var dailyGoal: Double?
    
    init(preselectedName: String = "") {
        _selectedName = State(initialValue: preselectedName)
    }
    
    private var uniqueNames: [String] {
        Array(Set(existingLogs.map { $0.name })).sorted()
    }
    
    private var selectedLogInfo: (isCumulative: Bool, unit: String, dailyGoal: Double?)? {
        if chooseExisting, !selectedName.isEmpty {
            if let existingLog = existingLogs.first(where: { $0.name == selectedName }) {
                return (existingLog.isActuallyCumulative, existingLog.actualUnit, existingLog.dailyGoal)
            }
        }
        return nil
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
                        TextField("Unit (optional)", text: $unit)
                        Toggle("Cumulative Daily Tracking", isOn: $isCumulative)
                        if isCumulative {
                            HStack {
                                Text("Daily Goal")
                                Spacer()
                                TextField("Optional", value: $dailyGoal, format: .number)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    } else {
                        Picker("Select Category", selection: $selectedName) {
                            Text("Select a category").tag("")
                            ForEach(uniqueNames, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        if let info = selectedLogInfo {
                            if !info.unit.isEmpty {
                                Text("Unit: \(info.unit)")
                            }
                            if info.isCumulative {
                                Text("Daily cumulative tracking enabled")
                                if let goal = info.dailyGoal {
                                    Text("Daily Goal: \(goal, specifier: "%.1f")")
                                }
                            }
                        }
                    }
                } header: {
                    Text(uniqueNames.isEmpty ? "Create your first tracking category" : "What do you want to track?")
                } footer: {
                    if !chooseExisting || uniqueNames.isEmpty {
                        Text("Use Cumulative Daily Tracking for items you have a daily goal for- for instance, your daily water intake or protein intake. Throughout the day, you'll be able to view your progress, and at the end of the day, a single cumulative value will be recorded.")
                    }
                }
                
                Section {
                    HStack {
                        TextField("Value", value: $value, format: .number)
                            .keyboardType(.decimalPad)
                        if let info = selectedLogInfo, info.isCumulative || (!chooseExisting && isCumulative) {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Total: \(dailyTotal + (value ?? 0), specifier: "%.1f")")
                                    .foregroundStyle(.secondary)
                                if let goal = info.dailyGoal ?? (isCumulative ? dailyGoal : nil) {
                                    let total = dailyTotal + (value ?? 0)
                                    Text("\(Int((total/goal) * 100))% of goal")
                                        .foregroundStyle(total >= goal ? .green : .secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Enter Value")
                } footer: {
                    if let info = selectedLogInfo, info.isCumulative || (!chooseExisting && isCumulative) {
                        Text("Values will be added together for the daily total")
                    } else {
                        Text("Track any numeric value like weight lifted, reps completed, or measurements")
                    }
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
                        saveEntry()
                    }
                    .disabled(value == nil || (uniqueNames.isEmpty ? customName.isEmpty : (!chooseExisting ? customName.isEmpty : selectedName.isEmpty)))
                }
            }
            .onAppear {
                loadDailyTotal()
            }
        }
    }
    
    private func loadDailyTotal() {
        guard let info = selectedLogInfo, info.isCumulative else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        dailyTotal = existingLogs
            .filter { $0.name == selectedName && $0.timestamp >= today && $0.timestamp < tomorrow }
            .reduce(0) { $0 + $1.value }
    }
    
    private func saveEntry() {
        let name = (uniqueNames.isEmpty || !chooseExisting) ? customName : selectedName
        let actualUnit = chooseExisting ? (selectedLogInfo?.unit ?? "") : unit
        let actualIsCumulative = chooseExisting ? (selectedLogInfo?.isCumulative ?? false) : isCumulative
        let actualDailyGoal = chooseExisting ? selectedLogInfo?.dailyGoal : (isCumulative ? dailyGoal : nil)
        
        if !name.isEmpty, let actualValue = value {
            let log = AnalyticsLog(
                name: name,
                value: actualValue,
                isCumulative: actualIsCumulative,
                unit: actualUnit,
                dailyGoal: actualDailyGoal
            )
            modelContext.insert(log)
            dismiss()
        }
    }
}

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
                        .safeAreaInset(edge: .bottom) {
                            Color.clear.frame(height: 25)
                        }
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
    let timeRange: TimeRange
    @State private var showingAddEntry = false
    
    private var isCumulative: Bool {
        logs.first?.isActuallyCumulative ?? false
    }
    
    private var unit: String {
        logs.first?.actualUnit ?? ""
    }
    
    private var dailyGoal: Double? {
        logs.first?.dailyGoal
    }
    
    private var processedLogs: [(date: Date, value: Double)] {
        guard !logs.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let sortedLogs = logs.sorted { $0.timestamp < $1.timestamp }
        
        if isCumulative {
            // Group by day and sum values
            var dailyTotals: [Date: Double] = [:]
            
            for log in sortedLogs {
                let day = calendar.startOfDay(for: log.timestamp)
                dailyTotals[day, default: 0] += log.value
            }
            
            return dailyTotals.map { ($0.key, $0.value) }
                .sorted { $0.0 < $1.0 }
        } else {
            return sortedLogs.map { (date: $0.timestamp, value: $0.value) }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch timeRange {
        case .week:
            formatter.dateFormat = "EEE"
        case .month:
            formatter.dateFormat = "MMM d"
        case .year:
            formatter.dateFormat = "MMM"
        case .all:
            formatter.dateFormat = "MMM yyyy"
        }
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(name)
                    .font(.headline)
                if !unit.isEmpty {
                    Text("(\(unit))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isCumulative, let goal = dailyGoal {
                    Text("Goal: \(goal, specifier: "%.1f")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("\(logs.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !processedLogs.isEmpty {
                Chart {
                    ForEach(processedLogs, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Value", item.value)
                        )
                        .symbol(.circle)
                        .foregroundStyle(isCumulative && dailyGoal != nil ? .blue : .primary)
                        .interpolationMethod(.catmullRom)
                    }
                    
                    if isCumulative, let goal = dailyGoal {
                        RuleMark(
                            y: .value("Goal", goal)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(.green)
                        .annotation(position: .trailing) {
                            Text("Goal")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(dateFormatter.string(from: date))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text(String(format: "%.1f", doubleValue))
                            }
                        }
                    }
                }
            } else {
                Text("No data for selected time range")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(radius: 2)
        .onTapGesture {
            showingAddEntry = true
        }
        .sheet(isPresented: $showingAddEntry) {
            AddLogEntryView(preselectedName: name)
        }
    }
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components) ?? Date()
    }
}

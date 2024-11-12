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
    @State private var isCustomName: Bool = false
    
    private var uniqueNames: [String] {
        Array(Set(existingLogs.map { $0.name })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Type") {
                    Picker("Use existing or new", selection: $isCustomName) {
                        Text("Existing").tag(false)
                        Text("New").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    if isCustomName {
                        TextField("Enter new exercise name", text: $customName)
                    } else {
                        Picker("Select exercise", selection: $selectedName) {
                            ForEach(uniqueNames, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                    }
                }
                
                Section("Value") {
                    TextField("Value", value: $value, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Entry")
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
                            let log = AnalyticsLog(name: name, value: value)
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

struct WorkoutHistoryView: View {
    @Query private var logs: [AnalyticsLog]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddEntry = false
    
    private var uniqueNames: [String] {
        Array(Set(logs.map { $0.name })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(uniqueNames, id: \.self) { name in
                        VStack(alignment: .leading) {
                            Text(name)
                                .font(.headline)
                                .padding(.leading)
                            
                            let exerciseLogs = logs.filter { $0.name == name }
                                .sorted { $0.timestamp < $1.timestamp }
                            
                            Chart {
                                ForEach(exerciseLogs) { item in
                                    LineMark(
                                        x: .value("Date", item.timestamp),
                                        y: .value("Value", item.value)
                                    )
                                    .symbol(.circle)
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
                            .padding()
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Progress Track")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingAddEntry = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddLogEntryView()
            }
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

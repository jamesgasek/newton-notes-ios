import SwiftUI
import Foundation
import SwiftData

struct AddExerciseTemplateView: View {
   @Environment(\.dismiss) private var dismiss
   @Environment(\.modelContext) private var modelContext
   @State private var exerciseName = ""
   @State private var category = "Other"
   @State private var notes = ""
   @FocusState private var focusedField: Field?
   var onSave: (ExerciseTemplate) -> Void
   
   enum Field {
       case name, notes
   }
   
   let categories = [
       "Chest", "Back", "Legs", "Shoulders",
       "Arms", "Core", "Cardio", "Other"
   ]
  
   private func saveExercise() {
       let template = ExerciseTemplate(
           name: exerciseName,
           category: category
       )
       modelContext.insert(template)
       
       do {
           try modelContext.save()
           print("Successfully saved exercise: \(template.name)")
           focusedField = nil
           onSave(template)
       } catch {
           print("Failed to save exercise: \(error)")
       }
       dismiss()
   }
   
   var body: some View {
       NavigationStack {
           Form {
               TextField("Exercise Name", text: $exerciseName)
                   .focused($focusedField, equals: .name)
                   .submitLabel(.done)
               
               Picker("Category", selection: $category) {
                   ForEach(categories, id: \.self) { category in
                       Text(category).tag(category)
                   }
               }
               
               TextField("Notes (Optional)", text: $notes)
                   .focused($focusedField, equals: .notes)
                   .submitLabel(.done)
           }
           .navigationTitle("New Exercise")
           .navigationBarTitleDisplayMode(.inline)
           .toolbar {
               ToolbarItem(placement: .cancellationAction) {
                   Button("Cancel") {
                       focusedField = nil
                       dismiss()
                   }
               }
               ToolbarItem(placement: .confirmationAction) {
                   Button("Save") {
                       focusedField = nil
                       saveExercise()
                   }
                   .disabled(exerciseName.isEmpty)
               }
           }
       }
   }
}

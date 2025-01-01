import SwiftUI

class PreferenceManager: ObservableObject {
   @AppStorage("weightUnit") var weightUnit: String = "lbs"
   @AppStorage("distanceUnit") var distanceUnit: String = "mi"
   
   init() {}
}

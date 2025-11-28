import Combine
import Foundation
import SwiftData

class HistoryViewModel: ObservableObject {
  @Published var searchText = ""
  @Published var groupByExercise = false

  func filteredLifts(lifts: [LiftEvent]) -> [LiftEvent] {
    if searchText.isEmpty {
      return lifts
    } else {
      return lifts.filter {
        $0.exerciseName.localizedCaseInsensitiveContains(searchText)
          || String($0.reps).contains(searchText)
      }
    }
  }
}

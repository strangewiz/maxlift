import Foundation
import SwiftData
import Combine

class LogWorkoutViewModel: ObservableObject {
    @Published var date = Date()
    @Published var exerciseName = ""
    @Published var weightString = ""
    @Published var repsString = ""
    @Published var notes = ""
    @Published var showAlert = false

    func previousExercises(from recentLifts: [LiftEvent]) -> [String] {
        let commonExercises = [
            "Back Squat",
            "Back Pause Squat",
            "Front Squat",
            "Bench Press",
            "Deadlift"
        ]
        let historicalExercises = recentLifts.map { $0.exerciseName }
        return Array(Set(commonExercises + historicalExercises)).sorted()
    }

    func saveLift(modelContext: ModelContext) {
        guard let weight = Double(weightString), let reps = Int(repsString) else { return }
        
        let newLift = LiftEvent(
            date: date,
            exerciseName: exerciseName,
            weight: weight,
            reps: reps,
            notes: notes
        )
        
        modelContext.insert(newLift)
        
        // Clear fields
        weightString = ""
        repsString = ""
        notes = ""
        showAlert = true
    }
}

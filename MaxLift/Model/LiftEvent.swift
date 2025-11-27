import Foundation
import SwiftData

// MARK: - 1. DATA MODEL
@Model
final class LiftEvent: Identifiable {
    var id: UUID = UUID()
    var date: Date = Date()
    var exerciseName: String = ""
    var weight: Double = 0.0
    var reps: Int = 0
    var notes: String = ""
    
    init(date: Date = Date(), exerciseName: String, weight: Double, reps: Int, notes: String = "") {
        self.id = UUID()
        self.date = date
        self.exerciseName = exerciseName
        self.weight = weight
        self.reps = reps
        self.notes = notes
    }
    
    // Logic: Calculate One Rep Max (Brzycki Formula)
    var estimatedOneRepMax: Double {
        if reps == 1 { return weight }
        // Brzycki Formula: Weight / (1.0278 - (0.0278 * Reps))
        return weight * (36 / (37 - Double(reps)))
    }
}

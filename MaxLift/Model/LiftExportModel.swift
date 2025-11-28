import Foundation

// Helper Structs for Import/Export
struct LiftExportModel: Codable {
  let date: Date
  let exerciseName: String
  let weight: Double
  let reps: Int
  let notes: String
}

import Foundation

class LiftDetailViewModel {
  let lift: LiftEvent

  // Percentage Grid Logic
  let percentages = Array(stride(from: 30, through: 105, by: 5)).reversed()  // 105 down to 30

  init(lift: LiftEvent) {
    self.lift = lift
  }

  // Calculate theoretical maxes based on the Est 1RM
  func weightFor(percentage: Int) -> Double {
    return lift.estimatedOneRepMax * (Double(percentage) / 100.0)
  }

  // Rough estimate of how many reps are possible at a specific %
  func repsForPercentage(_ pct: Int) -> String {
    switch pct {
    case 100...: return "1"
    case 95: return "2"
    case 90: return "3-4"
    case 85: return "5-6"
    case 80: return "7-8"
    case 75: return "9-10"
    case 70: return "12"
    case 60...69: return "15+"
    default: return "Endurance"
    }
  }
}

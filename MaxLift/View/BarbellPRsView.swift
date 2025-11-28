import SwiftData
import SwiftUI

struct BarbellPRsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var allLifts: [LiftEvent]
  @Binding var selectedTab: Int
  @AppStorage("prLookbackYears") private var prLookbackYears: Int = 0

  // Filtered lifts based on lookback setting
  var relevantLifts: [LiftEvent] {
    if prLookbackYears == 0 {
      return allLifts
    } else {
      guard
        let cutoffDate = Calendar.current.date(
          byAdding: .year,
          value: -prLookbackYears,
          to: Date()
        )
      else {
        return allLifts
      }
      return allLifts.filter { $0.date >= cutoffDate }
    }
  }

  // Group lifts by exercise name
  var exercises: [String] {
    Array(Set(relevantLifts.map { $0.exerciseName })).sorted()
  }

  // Helper to get the best 1RM (actual or estimated) for an exercise
  func bestOneRepMax(for exerciseName: String) -> (Double, Bool) {
    let relevantLiftsForExercise = relevantLifts.filter {
      $0.exerciseName == exerciseName
    }

    // Try to find an actual 1-rep max first
    if let actual1RM = relevantLiftsForExercise.filter({ $0.reps == 1 }).max(
      by: {
        $0.weight < $1.weight
      })?.weight
    {
      return (actual1RM, false)  // False indicates it's an actual 1RM
    }

    // Otherwise, find the max estimated 1RM from any lift
    if let estimated1RM = relevantLiftsForExercise.max(by: {
      $0.estimatedOneRepMax < $1.estimatedOneRepMax
    })?.estimatedOneRepMax {
      return (estimated1RM, true)  // True indicates it's an estimated 1RM
    }

    return (0.0, false)  // Default if no lifts exist
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color.appBackground.ignoresSafeArea()

        if exercises.isEmpty {
          // Empty State
          VStack(spacing: 20) {
            Image(systemName: "dumbbell.fill")
              .font(.system(size: 80))
              .foregroundColor(.secondary)

            Text("No Personal Records Yet")
              .font(.title2).bold()

            if prLookbackYears > 0 {
              Text(
                "No lifts found in the past \(prLookbackYears) year\(prLookbackYears > 1 ? "s" : ""). Try adjusting your preferences or log a new workout."
              )
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
            } else {
              Text(
                "Log your first workout to see your progress and estimated 1 Rep Maxes here."
              )
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
            }

            Button {
              selectedTab = 2  // Switch to 'Log Lift' tab
            } label: {
              Text("Log a Workout")
                .bold()
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.appAccent)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
          }
        } else {
          List {
            ForEach(exercises, id: \.self) { exercise in
              NavigationLink(
                destination: ExercisePRDetailView(
                  exerciseName: exercise,
                  allLifts: relevantLifts
                )
              ) {
                HStack {
                  Text(exercise)
                    .font(.headline)
                  Spacer()
                  let (oneRM, isEstimated) = bestOneRepMax(for: exercise)
                  if oneRM > 0 {
                    Text("\(Int(oneRM))\(isEstimated ? " (est.)" : "") lbs")
                      .font(.subheadline)
                      .foregroundColor(.textSecondary)
                  } else {
                    Text("-- lbs")
                      .font(.subheadline)
                      .foregroundColor(.textSecondary)
                  }
                }
              }
              .listRowBackground(Color.cardBackground)
            }
          }
          .scrollContentBackground(.hidden)  // Allow ZStack background to show
        }
      }
      .navigationTitle("Barbell PRs")
    }
  }
}

struct ExercisePRDetailView: View {
  let exerciseName: String
  let allLifts: [LiftEvent]

  // Calculate best lifts for specific rep counts
  func bestLift(forReps targetReps: Int) -> LiftEvent? {
    let liftsForExercise = allLifts.filter { $0.exerciseName == exerciseName }

    // Exact match for reps is preferred
    let exactMatches = liftsForExercise.filter { $0.reps == targetReps }
    if let bestExact = exactMatches.max(by: { $0.weight < $1.weight }) {
      return bestExact
    }

    // Fallback: If no exact rep match, we can't accurately say "This is your 5RM"
    // purely from a 3-rep set without estimation. The prompt implies
    // showing the max *done* for that rep count.
    // So if no log exists for exactly 5 reps, we show nothing (or "--").
    return nil
  }

  // For the chart, we need a "reference" 1RM. We'll take the absolute max estimated 1RM
  // from *any* lift of this exercise type to drive the chart.
  var maxEstimatedOneRepMax: Double {
    let liftsForExercise = allLifts.filter { $0.exerciseName == exerciseName }
    return liftsForExercise.map { $0.estimatedOneRepMax }.max() ?? 0.0
  }

  var body: some View {
    ZStack {
      Color.appBackground.ignoresSafeArea()

      ScrollView {
        VStack(spacing: 24) {
          // Header
          Text(exerciseName)
            .font(.largeTitle).bold()
            .padding(.top)

          // PR Stats Grid
          LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 16
          ) {
            ForEach([1, 2, 3, 5], id: \.self) { reps in
              // Conditional NavigationLink
              if let lift = bestLift(forReps: reps) {
                NavigationLink(destination: LiftDetailView(lift: lift)) {
                  VStack(alignment: .leading, spacing: 4) {
                    Text("\(reps) Rep Max")
                      .font(.caption)
                      .foregroundColor(.textSecondary)
                      .textCase(.uppercase)

                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                      Text("\(Int(lift.weight))")
                        .font(.title2).bold()
                      Text("lbs")
                        .font(.caption).bold().foregroundColor(.textSecondary)
                    }
                    Text(
                      lift.date.formatted(date: .abbreviated, time: .omitted)
                    )
                    .font(.caption2)
                    .foregroundColor(.gray)
                  }
                  .padding()
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .background(Color.cardBackground)
                  .cornerRadius(12)
                  .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 4,
                    x: 0,
                    y: 2
                  )
                }
              } else {
                // Non-tappable view if no lift exists
                VStack(alignment: .leading, spacing: 4) {
                  Text("\(reps) Rep Max")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .textCase(.uppercase)

                  Text("--")
                    .font(.title2).bold()
                    .foregroundColor(.gray.opacity(0.3))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
              }
            }
          }
          .padding(.horizontal)

          Divider()
            .padding(.horizontal)

          // Percentage Chart
          VStack(alignment: .leading, spacing: 8) {
            Text("Reference Chart")
              .font(.headline)
              .padding(.horizontal)

            if maxEstimatedOneRepMax > 0 {
              PercentageReferenceView(oneRepMax: maxEstimatedOneRepMax)
            } else {
              Text("Log a lift to see your reference chart.")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
          }

          Spacer()
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

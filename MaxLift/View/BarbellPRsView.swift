import SwiftUI
import SwiftData

struct BarbellPRsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allLifts: [LiftEvent]
    @Binding var selectedTab: Int
    
    // Group lifts by exercise name
    var exercises: [String] {
        Array(Set(allLifts.map { $0.exerciseName })).sorted()
    }
    
    var body: some View {
        NavigationView {
            Group {
                if exercises.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.secondary)
                        
                        Text("No Personal Records Yet")
                            .font(.title2).bold()
                        
                        Text("Log your first workout to see your progress and estimated 1 Rep Maxes here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            selectedTab = 2 // Switch to 'Log Lift' tab
                        } label: {
                            Text("Log a Workout")
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    }
                } else {
                    List {
                        ForEach(exercises, id: \.self) { exercise in
                            NavigationLink(destination: ExercisePRDetailView(exerciseName: exercise, allLifts: allLifts)) {
                                Text(exercise)
                                    .font(.headline)
                            }
                        }
                    }
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
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text(exerciseName)
                    .font(.largeTitle).bold()
                    .padding(.top)
                
                // PR Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach([1, 2, 3, 5], id: \.self) { reps in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(reps) Rep Max")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            if let lift = bestLift(forReps: reps) {
                                HStack(alignment: .lastTextBaseline, spacing: 2) {
                                    Text("\(Int(lift.weight))")
                                        .font(.title2).bold()
                                    Text("lbs")
                                        .font(.caption).bold().foregroundColor(.secondary)
                                }
                                Text(lift.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            } else {
                                Text("--")
                                    .font(.title2).bold()
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
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
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

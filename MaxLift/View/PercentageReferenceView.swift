import SwiftUI

struct PercentageReferenceView: View {
    let oneRepMax: Double
    @State private var selectedRepBasis = 1
    
    let repOptions = [1, 2, 3, 5]
    let percentages = Array(stride(from: 105, through: 30, by: -5)).reversed().reversed() // 105 down to 30
    
    var body: some View {
        VStack(spacing: 16) {
            // Rep Picker
            Picker("Reps", selection: $selectedRepBasis) {
                ForEach(repOptions, id: \.self) { reps in
                    Text("\(reps) Rep Max").tag(reps)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // 4x4 Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(percentages, id: \.self) { pct in
                    VStack {
                        Text("\(pct)%")
                            .font(.caption)
                            .bold()
                            .foregroundColor(pct > 100 ? .red : .secondary)
                        
                        Text("\(Int(calculateWeight(percentage: pct)))")
                            .font(.headline)
                            .monospacedDigit()
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Logic: Calculate target weight based on 1RM, Target Reps, and Percentage
    // Formula: Weight = (1RM * (37 - Reps) / 36) * Percentage
    private func calculateWeight(percentage: Int) -> Double {
        let theoreticalMaxForReps = oneRepMax * (37.0 - Double(selectedRepBasis)) / 36.0
        return theoreticalMaxForReps * (Double(percentage) / 100.0)
    }
}

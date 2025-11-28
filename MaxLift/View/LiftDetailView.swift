import SwiftUI

// MARK: - 6. DETAIL & CHART VIEW
struct LiftDetailView: View {
  let lift: LiftEvent
  private let viewModel: LiftDetailViewModel

  init(lift: LiftEvent) {
    self.lift = lift
    self.viewModel = LiftDetailViewModel(lift: lift)
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        // Header Stats
        VStack {
          Text(lift.exerciseName)
            .font(.title).bold()
          Text("Logged: \(Int(lift.weight)) lbs x \(lift.reps)")
            .font(.title3).foregroundColor(.secondary)

          if !lift.notes.isEmpty {
            Text(lift.notes)
              .font(.body)
              .italic()
              .foregroundColor(.secondary)
              .padding(.vertical, 4)
              .padding(.horizontal)
              .multilineTextAlignment(.center)
          }

          Divider()

          HStack(spacing: 40) {
            VStack {
              Text("Est. 1RM")
                .font(.caption).textCase(.uppercase)
              Text("\(Int(lift.estimatedOneRepMax))")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundColor(.blue)
            }
          }
          .padding()
        }

        // The Chart
        Text("Percentage Reference Chart")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)

        PercentageReferenceView(oneRepMax: lift.estimatedOneRepMax)
          .padding(.bottom)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

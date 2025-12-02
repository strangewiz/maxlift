import SwiftData
import SwiftUI

// MARK: - 5. HISTORY VIEW
struct HistoryView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \LiftEvent.date, order: .reverse) private var lifts: [LiftEvent]

  @StateObject private var viewModel = HistoryViewModel()
  @Binding var selectedTab: Int  // Add binding for tab selection

  var body: some View {
    NavigationStack {
      ZStack {
        Color.appBackground.ignoresSafeArea()

        if lifts.isEmpty {
          VStack(spacing: 20) {
            Image(systemName: "clock.fill")
              .font(.system(size: 80))
              .foregroundColor(.secondary)

            Text("No Workout History Yet")
              .font(.title2).bold()

            Text("Log your first workout to see it appear here.")
              .font(.body)
              .foregroundColor(.textSecondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)

            Button {
              selectedTab = 2  // Navigate to the Log Lift tab
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
            if viewModel.groupByExercise {
              // Grouped View
              let grouped = Dictionary(
                grouping: viewModel.filteredLifts(lifts: lifts),
                by: { $0.exerciseName }
              )
              ForEach(grouped.keys.sorted(), id: \.self) { key in
                Section(header: Text(key)) {
                  ForEach(grouped[key]!) { lift in
                    NavigationLink(destination: LiftDetailView(lift: lift)) {
                      LiftRow(lift: lift)
                    }
                    .listRowBackground(Color.cardBackground)
                  }
                }
              }
            } else {
              // Standard List
              ForEach(viewModel.filteredLifts(lifts: lifts)) { lift in
                NavigationLink(destination: LiftDetailView(lift: lift)) {
                  LiftRow(lift: lift)
                }
                .listRowBackground(Color.cardBackground)
              }
              .onDelete(perform: deleteItems)
            }
          }
          .scrollContentBackground(.hidden)
          .searchable(
            text: $viewModel.searchText,
            prompt: "Search lift or reps..."
          )
          .navigationTitle("History")
          .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button(action: { viewModel.groupByExercise.toggle() }) {
                Image(
                  systemName: viewModel.groupByExercise
                    ? "list.bullet" : "folder"
                )
              }
            }
          }
        }
      }
      .navigationTitle("History")
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(viewModel.filteredLifts(lifts: lifts)[index])
      }
    }
  }
}

struct LiftRow: View {
  let lift: LiftEvent
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(lift.exerciseName).font(.headline)
        Text(lift.date.formatted(date: .abbreviated, time: .omitted))
          .font(.caption).foregroundColor(.secondary)
      }
      Spacer()
      VStack(alignment: .trailing) {
        Text("\(Int(lift.weight)) lbs").bold()
        Text("\(lift.reps) reps").foregroundColor(.gray)
      }
    }
  }
}

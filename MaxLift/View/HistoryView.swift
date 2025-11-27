import SwiftUI
import SwiftData

// MARK: - 5. HISTORY VIEW
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LiftEvent.date, order: .reverse) private var lifts: [LiftEvent]
    
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        NavigationView {
            List {
                if viewModel.groupByExercise {
                    // Grouped View
                    let grouped = Dictionary(grouping: viewModel.filteredLifts(lifts: lifts), by: { $0.exerciseName })
                    ForEach(grouped.keys.sorted(), id: \.self) { key in
                        Section(header: Text(key)) {
                            ForEach(grouped[key]!) { lift in
                                NavigationLink(destination: LiftDetailView(lift: lift)) {
                                    LiftRow(lift: lift)
                                }
                            }
                        }
                    }
                } else {
                    // Standard List
                    ForEach(viewModel.filteredLifts(lifts: lifts)) { lift in
                        NavigationLink(destination: LiftDetailView(lift: lift)) {
                            LiftRow(lift: lift)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search lift or reps...")
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.groupByExercise.toggle() }) {
                        Image(systemName: viewModel.groupByExercise ? "list.bullet" : "folder")
                    }
                }
            }
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

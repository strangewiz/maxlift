import SwiftUI
import SwiftData

// MARK: - 4. LOG WORKOUT VIEW
struct LogWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = LogWorkoutViewModel()
    
    @Query(sort: \LiftEvent.date, order: .reverse) private var recentLifts: [LiftEvent]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                    
                    // Exercise Input with History Dropdown
                    VStack(alignment: .leading) {
                        HStack {
                            TextField("Exercise (e.g. Squat)", text: $viewModel.exerciseName)
                            
                            // Clear button
                            if !viewModel.exerciseName.isEmpty {
                                Button(action: { viewModel.exerciseName = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }

                            Menu {
                                let exercises = viewModel.previousExercises(from: recentLifts)
                                if exercises.isEmpty {
                                    Text("No previous exercises")
                                } else {
                                    ForEach(exercises, id: \.self) { exercise in
                                        Button(exercise) {
                                            viewModel.exerciseName = exercise
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.down.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                        }

                        if !viewModel.exerciseName.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.previousExercises(from: recentLifts).filter { $0.localizedCaseInsensitiveContains(viewModel.exerciseName) }, id: \.self) { suggestion in
                                        Button(action: { viewModel.exerciseName = suggestion }) {
                                            Text(suggestion)
                                                .font(.caption)
                                                .padding(6)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Performance")) {
                    HStack {
                        TextField("Weight", text: $viewModel.weightString)
                            .keyboardType(.decimalPad)
                        Text("lbs")
                    }
                    HStack {
                        TextField("Reps", text: $viewModel.repsString)
                            .keyboardType(.numberPad)
                        Text("reps")
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Optional notes...", text: $viewModel.notes)
                }
                
                Button("Save Lift") {
                    viewModel.saveLift(modelContext: modelContext)
                }
                .disabled(viewModel.exerciseName.isEmpty || viewModel.weightString.isEmpty || viewModel.repsString.isEmpty)
                .frame(maxWidth: .infinity, alignment: .center)
                .bold()
                .foregroundColor(.white)
                .listRowBackground(Color.blue)
            }
            .navigationTitle("Log Workout")
            .alert("Lift Saved!", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

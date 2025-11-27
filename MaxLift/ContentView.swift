import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - 1. DATA MODEL
@Model
final class LiftEvent: Identifiable {
    var id: UUID
    var date: Date
    var exerciseName: String
    var weight: Double
    var reps: Int
    var notes: String
    
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

// MARK: - 2. MAIN APP ENTRY
@main
struct MaxLiftApp: App {
    // Configure SwiftData container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LiftEvent.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - 3. TAB NAVIGATION
struct MainTabView: View {
    var body: some View {
        TabView {
            LogWorkoutView()
                .tabItem {
                    Label("Log Lift", systemImage: "plus.circle.fill")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

// MARK: - 4. LOG WORKOUT VIEW
struct LogWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LiftEvent.date, order: .reverse) private var recentLifts: [LiftEvent]
    
    @State private var date = Date()
    @State private var exerciseName = ""
    @State private var weightString = ""
    @State private var repsString = ""
    @State private var notes = ""
    @State private var showAlert = false
    
    // Get unique exercise names for autocomplete
    var previousExercises: [String] {
        Array(Set(recentLifts.map { $0.exerciseName })).sorted()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    // Simple Autocomplete Logic
                    VStack(alignment: .leading) {
                        TextField("Exercise (e.g. Squat)", text: $exerciseName)
                        if !exerciseName.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(previousExercises.filter { $0.localizedCaseInsensitiveContains(exerciseName) }, id: \.self) { suggestion in
                                        Button(action: { exerciseName = suggestion }) {
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
                        TextField("Weight", text: $weightString)
                            .keyboardType(.decimalPad)
                        Text("lbs")
                    }
                    HStack {
                        TextField("Reps", text: $repsString)
                            .keyboardType(.numberPad)
                        Text("reps")
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextField("Optional notes...", text: $notes)
                }
                
                Button("Save Lift") {
                    saveLift()
                }
                .disabled(exerciseName.isEmpty || weightString.isEmpty || repsString.isEmpty)
                .frame(maxWidth: .infinity, alignment: .center)
                .bold()
                .foregroundColor(.white)
                .listRowBackground(Color.blue)
            }
            .navigationTitle("Log Workout")
            .alert("Lift Saved!", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func saveLift() {
        guard let weight = Double(weightString), let reps = Int(repsString) else { return }
        
        let newLift = LiftEvent(
            date: date,
            exerciseName: exerciseName,
            weight: weight,
            reps: reps,
            notes: notes
        )
        
        modelContext.insert(newLift)
        
        // Clear fields
        weightString = ""
        repsString = ""
        notes = ""
        showAlert = true
    }
}

// MARK: - 5. HISTORY VIEW
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LiftEvent.date, order: .reverse) private var lifts: [LiftEvent]
    
    @State private var searchText = ""
    @State private var groupByExercise = false
    
    var filteredLifts: [LiftEvent] {
        if searchText.isEmpty {
            return lifts
        } else {
            return lifts.filter { lift in
                lift.exerciseName.localizedCaseInsensitiveContains(searchText) ||
                String(lift.reps).contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                if groupByExercise {
                    // Grouped View
                    let grouped = Dictionary(grouping: filteredLifts, by: { $0.exerciseName })
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
                    ForEach(filteredLifts) { lift in
                        NavigationLink(destination: LiftDetailView(lift: lift)) {
                            LiftRow(lift: lift)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .searchable(text: $searchText, prompt: "Search lift or reps...")
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { groupByExercise.toggle() }) {
                        Image(systemName: groupByExercise ? "list.bullet" : "folder")
                    }
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredLifts[index])
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

// MARK: - 6. DETAIL & CHART VIEW
struct LiftDetailView: View {
    let lift: LiftEvent
    
    // Percentage Grid Logic
    let percentages = Array(stride(from: 30, through: 105, by: 5)).reversed() // 105 down to 30
    
    // Calculate theoretical maxes based on the Est 1RM
    func weightFor(percentage: Int, ofOneRepMax oneRepMax: Double) -> Double {
        return oneRepMax * (Double(percentage) / 100.0)
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
                
                VStack(spacing: 0) {
                    // Table Header
                    HStack {
                        Text("%").frame(width: 50, alignment: .leading).bold()
                        Spacer()
                        Text("Weight").bold()
                        Spacer()
                        Text("For Reps").font(.caption).foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    
                    // Table Rows
                    ForEach(percentages, id: \.self) { pct in
                        HStack {
                            Text("\(pct)%")
                                .frame(width: 50, alignment: .leading)
                                .bold()
                                .foregroundColor(pct > 100 ? .red : .primary)
                            
                            Spacer()
                            
                            Text("\(Int(weightFor(percentage: pct, ofOneRepMax: lift.estimatedOneRepMax))) lbs")
                                .font(.system(.body, design: .monospaced))
                            
                            Spacer()
                            
                            // Approximate reps you *might* get at this % (Standard Logic)
                            // This is a rough heuristic column for context
                            Text(repsForPercentage(pct))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        Divider()
                    }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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

// MARK: - 7. SETTINGS & EXPORT
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allLifts: [LiftEvent]
    @State private var showingExporter = false
    @State private var exportDocument: JSONDocument?
    @State private var showingImporter = false
    @State private var importAlertMessage = ""
    @State private var showImportAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Data Management")) {
                    Button {
                        prepareExport()
                    } label: {
                        Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import Data (JSON)", systemImage: "square.and.arrow.down")
                    }
                }
                
                Section(header: Text("About")) {
                    Text("This app stores data in your private iCloud via CloudKit.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            // EXPORT HANDLER
            .fileExporter(
                isPresented: $showingExporter,
                document: exportDocument,
                contentType: .json,
                defaultFilename: "MaxLift_Backup_\(Date().formatted(date: .numeric, time: .omitted)).json"
            ) { result in
                if case .success = result {
                    print("Export successful")
                }
            }
            // IMPORT HANDLER
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            .alert(importAlertMessage, isPresented: $showImportAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    // Export Logic
    func prepareExport() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        // Convert SwiftData models to codable struct if necessary,
        // but LiftEvent is Codable compatible if we add the conformance.
        // For simplicity, we map to a simple struct here:
        let exportableData = allLifts.map { LiftExportModel(date: $0.date, exerciseName: $0.exerciseName, weight: $0.weight, reps: $0.reps, notes: $0.notes) }
        
        if let data = try? encoder.encode(exportableData) {
            exportDocument = JSONDocument(data: data)
            showingExporter = true
        }
    }
    
    // Import Logic
    func handleImport(result: Result<[URL], Error>) {
        do {
            guard let selectedFile: URL = try result.get().first else { return }
            if selectedFile.startAccessingSecurityScopedResource() {
                let data = try Data(contentsOf: selectedFile)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let importedLifts = try decoder.decode([LiftExportModel].self, from: data)
                
                for lift in importedLifts {
                    let newEvent = LiftEvent(date: lift.date, exerciseName: lift.exerciseName, weight: lift.weight, reps: lift.reps, notes: lift.notes)
                    modelContext.insert(newEvent)
                }
                
                selectedFile.stopAccessingSecurityScopedResource()
                importAlertMessage = "Successfully imported \(importedLifts.count) lifts."
                showImportAlert = true
            }
        } catch {
            importAlertMessage = "Error importing: \(error.localizedDescription)"
            showImportAlert = true
        }
    }
}

// Helper Structs for Import/Export
struct LiftExportModel: Codable {
    let date: Date
    let exerciseName: String
    let weight: Double
    let reps: Int
    let notes: String
}

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data = Data()
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.data = data
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

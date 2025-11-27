import Foundation
import SwiftData
import UniformTypeIdentifiers
import Combine

class SettingsViewModel: ObservableObject {
    @Published var showingExporter = false
    @Published var exportDocument: JSONDocument?
    @Published var showingImporter = false
    @Published var importAlertMessage = ""
    @Published var showImportAlert = false
    
    // Export Logic
    func prepareExport(allLifts: [LiftEvent]) {
        let encoder = JSONEncoder()
        
        let exportableData = allLifts.map { LiftExportModel(date: $0.date, exerciseName: $0.exerciseName, weight: $0.weight, reps: $0.reps, notes: $0.notes) }
        
        if let data = try? encoder.encode(exportableData) {
            exportDocument = JSONDocument(data: data)
            showingExporter = true
        }
    }
    
    // Import Logic
    func handleImport(result: Result<[URL], Error>, modelContext: ModelContext) {
        do {
            guard let selectedFile: URL = try result.get().first else { return }
            if selectedFile.startAccessingSecurityScopedResource() {
                let data = try Data(contentsOf: selectedFile)
                let decoder = JSONDecoder()
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

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

// MARK: - 7. SETTINGS & EXPORT
struct SettingsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var allLifts: [LiftEvent]
  @StateObject private var viewModel = SettingsViewModel()
  @AppStorage("prLookbackYears") private var prLookbackYears: Int = 0

  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("Data Management")) {
          Button {
            viewModel.prepareExport(allLifts: allLifts)
          } label: {
            Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
          }

          Button {
            viewModel.showingImporter = true
          } label: {
            Label("Import Data (JSON)", systemImage: "square.and.arrow.down")
          }
        }

        Section(header: Text("Preferences")) {
          Picker("Calculate PRs from", selection: $prLookbackYears) {
            Text("All Time").tag(0)
            Text("Past Year").tag(1)
            Text("Past 2 Years").tag(2)
            Text("Past 3 Years").tag(3)
            Text("Past 5 Years").tag(5)
            Text("Past 7 Years").tag(7)
            Text("Past 10 Years").tag(10)
          }
        }

        Section(header: Text("About")) {
          Text("This app stores data in your private iCloud via CloudKit.")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }.navigationTitle("Settings")
        // EXPORT HANDLER
        .fileExporter(
          isPresented: $viewModel.showingExporter,
          document: viewModel.exportDocument,
          contentType: .json,
          defaultFilename:
            "MaxLift_Backup_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")).json"
        ) { result in
          if case .success = result {
            print("Export successful")
          }
        }
        // IMPORT HANDLER
        .fileImporter(
          isPresented: $viewModel.showingImporter,
          allowedContentTypes: [.json],
          allowsMultipleSelection: false
        ) { result in
          viewModel.handleImport(result: result, modelContext: modelContext)
        }
        .alert(
          viewModel.importAlertMessage,
          isPresented: $viewModel.showImportAlert
        ) {
          Button("OK", role: .cancel) {}
        }
    }
  }
}

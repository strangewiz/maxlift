import SwiftUI
import UniformTypeIdentifiers

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

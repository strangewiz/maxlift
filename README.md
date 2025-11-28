# MaxLift

MaxLift is a modern, no-nonsense strength training tracker for iOS. It focuses on what matters most to lifters: tracking progressive overload, calculating One Rep Maxes (1RM), and providing instant percentage-based training references.

Built with **SwiftUI** and **SwiftData**, MaxLift seamlessly syncs your workout history across all your Apple devices using **iCloud (CloudKit)**.

## 🚀 Features

### 📊 Barbell PRs & Analytics
*   **Automatic PR Tracking:** Instantly see your best lifts for 1, 2, 4, and 5 rep ranges.
*   **Estimated 1RM:** Uses the **Brzycki Formula** to estimate your theoretical one-rep max based on any set.
*   **Percentage Reference Chart:** A dynamic grid showing target weights for 30%–105% intensity across various rep ranges (1, 2, 3, 5).
*   **Time-Framed PRs:** Filter your "Personal Records" by time (e.g., Past Year, Past 2 Years) to benchmark against your *current* strength, not who you were a decade ago.

### 📝 Workout Logging
*   **Streamlined Entry:** Quick input for Date, Exercise, Weight, Reps, and Notes.
*   **Smart History:** Autocomplete suggestions and a quick-select dropdown based on your lift history.
*   **Keyboard Handling:** Polished UI with intuitive keyboard dismissal.

### ☁️ Data & Sync
*   **iCloud Sync:** Built on SwiftData with CloudKit, your data lives on your device and syncs privately to your iCloud account. No third-party accounts required.
*   **Import/Export:** Full JSON export and import capabilities for data backup or analysis.

### 🎨 Modern UI
*   **Adaptive Theme:** A custom-designed dark/light theme (Charcoal & Electric Blue) that feels premium and focused.
*   **Native Feel:** Adheres strictly to Apple's Human Interface Guidelines.

## 🛠 Tech Stack

*   **Language:** Swift 5+
*   **UI Framework:** SwiftUI
*   **Persistence:** SwiftData / Core Data
*   **Cloud:** CloudKit
*   **Architecture:** MVVM (Model-View-ViewModel)

## 📦 Installation & Setup

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/MaxLift.git
    ```
2.  **Open in Xcode**
    Open `MaxLift.xcodeproj`.
3.  **Configure Signing & Capabilities**
    *   Select the **MaxLift** target.
    *   Go to **Signing & Capabilities**.
    *   Ensure your **Team** is selected.
    *   **Important:** Under **iCloud**, you must create or select your own **CloudKit Container**.
    *   Update `MaxLiftApp.swift` with your container identifier if you are customizing the code, though the app now relies primarily on the Entitlements file configuration.
4.  **Run**
    Build and run on iPhone Simulator or a physical device.

## 🧪 Testing

MaxLift includes a robust suite of tests:
*   **Unit Tests (XCTest):** Covers data model logic, 1RM formulas, percentage calculations, and JSON encoding.
*   **UI Tests (XCUITest):** Covers navigation, data entry flows, empty states, and search functionality.

To run tests, press `Cmd + U` in Xcode.

## 📄 License

This project is open source. Feel free to fork and modify!

import XCTest

final class MaxLiftUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testEmptyStateAndNavigation() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetData"]
        app.launch()

        // 1. Assert 'Barbell PRs' is the first screen (tab selected)
        // If empty, we expect the empty state text
        let emptyStateTitle = app.staticTexts["No Personal Records Yet"]
        
        XCTAssertTrue(emptyStateTitle.exists, "Empty state should appear on fresh launch")
        XCTAssertTrue(app.buttons["Log a Workout"].exists)
        
        // 2. Test button navigation
        app.buttons["Log a Workout"].tap()
        
        // 3. Assert we are now on "Log Workout" tab
        // Check for navigation bar title
        XCTAssertTrue(app.navigationBars["Log Workout"].exists)
    }

    func testLogAndVerifyLift() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetData"]
        app.launch()
        
        // Navigate to Log Lift tab manually
        app.tabBars.buttons["Log Lift"].tap()
        
        // Fill out form
        let exerciseField = app.textFields["Exercise (e.g. Squat)"]
        XCTAssertTrue(exerciseField.waitForExistence(timeout: 2))
        
        exerciseField.tap()
        exerciseField.typeText("UITest Squat")
        
        let weightField = app.textFields["Weight"]
        weightField.tap()
        weightField.typeText("225")
        
        let repsField = app.textFields["Reps"]
        repsField.tap()
        repsField.typeText("5")
        
        // Dismiss keyboard using the toolbar 'Done' button we added
        if app.toolbars.buttons["Done"].exists {
            app.toolbars.buttons["Done"].tap()
        } else {
            // Fallback: Tap header to dismiss if toolbar not found
            app.staticTexts["Log Workout"].tap()
        }
        
        // Save
        let saveButton = app.buttons["Save Lift"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()
        
        // Handle Alert
        let alert = app.alerts["Lift Saved!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        alert.buttons["OK"].tap()
        
        // Verify in History
        app.tabBars.buttons["History"].tap()
        
        let liftRow = app.staticTexts["UITest Squat"]
        XCTAssertTrue(liftRow.waitForExistence(timeout: 2))
        
        // Verify details in row
        XCTAssertTrue(app.staticTexts["225 lbs"].exists)
        XCTAssertTrue(app.staticTexts["5 reps"].exists)
    }
    
    func testSearchFunctionality() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-resetData"]
        app.launch()
        
        // 1. Create Data for Search Test
        app.tabBars.buttons["Log Lift"].tap()
        
        let exerciseField = app.textFields["Exercise (e.g. Squat)"]
        XCTAssertTrue(exerciseField.waitForExistence(timeout: 2))
        exerciseField.tap()
        exerciseField.typeText("Searchable Squat")
        
        let weightField = app.textFields["Weight"]
        weightField.tap()
        weightField.typeText("315")
        
        let repsField = app.textFields["Reps"]
        repsField.tap()
        repsField.typeText("1")
        
        if app.toolbars.buttons["Done"].exists {
            app.toolbars.buttons["Done"].tap()
        }
        
        app.buttons["Save Lift"].tap()
        app.alerts["Lift Saved!"].buttons["OK"].tap()
        
        // 2. Perform Search Test
        app.tabBars.buttons["History"].tap()
        
        let searchField = app.searchFields["Search lift or reps..."]
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        
        searchField.tap()
        searchField.typeText("Searchable")
        
        // Assert matches
        XCTAssertTrue(app.staticTexts["Searchable Squat"].exists)
        
        // Clear search
        if let clearButton = searchField.buttons["Clear text"].firstMatch as? XCUIElement, clearButton.exists {
            clearButton.tap()
        }
    }
}

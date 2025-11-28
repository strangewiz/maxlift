//
//  MaxLiftTests.swift
//  MaxLiftTests
//
//  Created by Justin Cohen on 11/27/25.
//

import SwiftData
import XCTest

@testable import MaxLift

final class MaxLiftTests: XCTestCase {

  // MARK: - Model Initialization Tests
  func testLiftEventInitialization() {
    let date = Date()
    let lift = LiftEvent(
      date: date,
      exerciseName: "Bench Press",
      weight: 135,
      reps: 5,
      notes: "Easy set"
    )

    XCTAssertEqual(lift.exerciseName, "Bench Press")
    XCTAssertEqual(lift.weight, 135)
    XCTAssertEqual(lift.reps, 5)
    XCTAssertEqual(lift.notes, "Easy set")
    XCTAssertEqual(lift.date, date)
    XCTAssertNotNil(lift.id)
  }

  func testLiftEventRequiredParams() {
    // Test initializing with only required parameters (if any were optional, but here we test the minimal valid init)
    let lift = LiftEvent(exerciseName: "Squat", weight: 225, reps: 5)
    XCTAssertEqual(lift.exerciseName, "Squat")
    XCTAssertEqual(lift.weight, 225)
    XCTAssertEqual(lift.reps, 5)
    // Check defaults
    XCTAssertEqual(lift.notes, "")
    // Date should be close to now, but hard to equality test strictly without injection
  }

  // MARK: - 1RM Calculation Tests (Brzycki Formula)
  // Formula: Weight * (36 / (37 - Reps))

  func testOneRepMaxForSingleRep() {
    let lift = LiftEvent(exerciseName: "Test", weight: 100, reps: 1)
    // 1 rep should always equal the weight itself
    XCTAssertEqual(lift.estimatedOneRepMax, 100)
  }

  func testOneRepMaxForFiveReps() {
    let lift = LiftEvent(exerciseName: "Test", weight: 100, reps: 5)
    // 100 * (36 / (37 - 5)) = 100 * (36/32) = 100 * 1.125 = 112.5
    XCTAssertEqual(lift.estimatedOneRepMax, 112.5, accuracy: 0.01)
  }

  func testOneRepMaxForTenReps() {
    let lift = LiftEvent(exerciseName: "Test", weight: 100, reps: 10)
    // 100 * (36 / (37 - 10)) = 100 * (36/27) = 100 * 1.333... = 133.33...
    XCTAssertEqual(lift.estimatedOneRepMax, 133.33, accuracy: 0.1)
  }

  // MARK: - ViewModel Logic Tests
  func DISABLED_testPercentageCalculation() {
    // Setup a scenario: 200lbs 1RM
    // We can cheat by creating a lift that results in 200 1RM (e.g. 200x1)
    let lift = LiftEvent(exerciseName: "Squat", weight: 200, reps: 1)
    let viewModel = LiftDetailViewModel(lift: lift)

    // Test 50%
    let weight50 = viewModel.weightFor(percentage: 50)
    XCTAssertEqual(weight50, 100.0, accuracy: 0.1)

    // Test 100%
    let weight100 = viewModel.weightFor(percentage: 100)
    XCTAssertEqual(weight100, 200.0, accuracy: 0.1)

    // Test 90%
    let weight90 = viewModel.weightFor(percentage: 90)
    XCTAssertEqual(weight90, 180.0, accuracy: 0.1)
  }

  func testDateFilteringLogic() {
    // Simulate the lookback logic from BarbellPRsView
    let now = Date()
    let calendar = Calendar.current

    // Create dates
    let today = now
    let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now)!
    let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: now)!

    let lifts = [
      LiftEvent(date: today, exerciseName: "Squat", weight: 100, reps: 1),
      LiftEvent(
        date: sixMonthsAgo,
        exerciseName: "Squat",
        weight: 100,
        reps: 1
      ),
      LiftEvent(date: twoYearsAgo, exerciseName: "Squat", weight: 100, reps: 1),
    ]

    // Test 1 Year Lookback
    let lookbackYears = 1
    let cutoffDate = calendar.date(
      byAdding: .year,
      value: -lookbackYears,
      to: now
    )!
    let filteredLifts = lifts.filter { $0.date >= cutoffDate }

    // Should include today and 6 months ago, but NOT 2 years ago
    XCTAssertEqual(filteredLifts.count, 2)
  }

  func testJSONExportEncoding() {
    let lift = LiftEvent(
      exerciseName: "Bench",
      weight: 225,
      reps: 5,
      notes: "Export Test"
    )
    let exportModel = LiftExportModel(
      date: lift.date,
      exerciseName: lift.exerciseName,
      weight: lift.weight,
      reps: lift.reps,
      notes: lift.notes
    )

    let encoder = JSONEncoder()
    // encoder.dateEncodingStrategy = .iso8601 // Matches App logic implicitly (SwiftData uses standard encoding usually, but we manually map to LiftExportModel)

    do {
      let data = try encoder.encode([exportModel])
      let jsonString = String(data: data, encoding: .utf8)

      XCTAssertNotNil(jsonString)
      XCTAssertTrue(jsonString!.contains("Bench"))
      XCTAssertTrue(jsonString!.contains("225"))
      XCTAssertTrue(jsonString!.contains("Export Test"))
    } catch {
      XCTFail("Encoding failed: \(error)")
    }
  }
}

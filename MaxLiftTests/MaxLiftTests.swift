//
//  MaxLiftTests.swift
//  MaxLiftTests
//
//  Created by Justin Cohen on 11/27/25.
//

import XCTest
import SwiftData
@testable import MaxLift

final class MaxLiftTests: XCTestCase {

    // MARK: - Model Initialization Tests
    func testLiftEventInitialization() {
        let date = Date()
        let lift = LiftEvent(date: date, exerciseName: "Bench Press", weight: 135, reps: 5, notes: "Easy set")
        
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
    
    func DISABLED_testRepsForPercentageHeuristic() {
        let lift = LiftEvent(exerciseName: "Mock", weight: 0, reps: 0)
        let viewModel = LiftDetailViewModel(lift: lift)
        
        XCTAssertEqual(viewModel.repsForPercentage(100), "1")
        XCTAssertEqual(viewModel.repsForPercentage(95), "2")
        XCTAssertEqual(viewModel.repsForPercentage(75), "9-10")
        XCTAssertEqual(viewModel.repsForPercentage(50), "Endurance")
    }
}

//
//  CheckerUtilities.swift
//  DiceV1
//
//  Created by Nicolas Baez on 4/10/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

extension Dice {
  func loadAndConfigureCheckers(in content: RealityViewContent) async {
    do {
      let scene = try await Entity(named: "Scene", in: realityKitContentBundle)
      print("Scene loaded successfully")
      // Arrays to store initialized CheckerData
      var player1Checkers: [CheckerData] = []
      var player2Checkers: [CheckerData] = []

      // Load and initialize Player 1's checkers
      for idx in 1 ... 7 {
        let checkerName = "P1C_\(idx)"
        if let checkerEntity = await scene.findEntity(named: checkerName) {
          await checkerEntity.components.set(PlayerComponent(owner: .player1))
          content.add(checkerEntity)

          let checkerData = CheckerData(
            id: UUID(),
            physicalEntity: checkerEntity,
            currentPosition: 0, // Set initial position based on your game logic
            previousPosition: nil,
            isOnBar: false,
            isBorneOff: false,
            owner: .player1
          )
          player1Checkers.append(checkerData)
        } else {
          print("Failed to load \(checkerName)")
        }
      }

      // Load and initialize Player 2's checkers
      for idx in 1 ... 7 {
        let checkerName = "P2C_\(idx)"
        if let checkerEntity = await scene.findEntity(named: checkerName) {
          await checkerEntity.components.set(PlayerComponent(owner: .player2))
          content.add(checkerEntity)

          let checkerData = CheckerData(
            id: UUID(),
            physicalEntity: checkerEntity,
            currentPosition: 0, // Set initial position based on your game logic
            previousPosition: nil,
            isOnBar: false,
            isBorneOff: false,
            owner: .player2
          )
          player2Checkers.append(checkerData)
        } else {
          print("Failed to load \(checkerName)")
        }
      }

      // Assuming you have a way to store or use these checker arrays within your game model
      gameModel.player1Checkers = player1Checkers
      gameModel.player2Checkers = player2Checkers

    } catch {
      print("Failed to load checkers due to error: \(error)")
    }
  }

  func setUpInitialBoard() {
    // Ensure there are enough points to place checkers
    if gameModel.points.count >= 24 {
      // Set up for Player 1
      placeCheckers(playerCheckers: gameModel.player1Checkers, pointIndex: 0, count: 2)
      placeCheckers(playerCheckers: gameModel.player1Checkers, pointIndex: 1, count: 5)

      // Set up for Player 2
      placeCheckers(playerCheckers: gameModel.player2Checkers, pointIndex: 23, count: 3)
      placeCheckers(playerCheckers: gameModel.player2Checkers, pointIndex: 22, count: 4)
    } else {
      print("Points array not fully initialized.")
    }
  }

  func placeCheckers(playerCheckers: [CheckerData], pointIndex: Int, count: Int) {
    // Calculate the number of checkers to place based on available checkers
    let maxCount = min(count, playerCheckers.count)
    for idx in 0 ..< maxCount {
      let checker = playerCheckers[idx] // Directly access the checker
//            let offset = Float(idx) * 0.5  // Offset each checker by 0.5 on the x-axis
      var newPosition = gameModel.points[pointIndex].position
      print("Checker placed at \(newPosition)")
//            newPosition.x += offset

      checker.currentPosition = pointIndex
      checker.physicalEntity.position = newPosition
      gameModel.points[pointIndex].checkerEntities.append(checker)
    }
  }
}

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
      // gameModel.player1Checkers = player1Checkers
      // gameModel.player2Checkers = player2Checkers

    } catch {
      print("Failed to load checkers due to error: \(error)")
    }
  }
}

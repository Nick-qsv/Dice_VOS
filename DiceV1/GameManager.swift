//
//  GameManager.swift
//  DiceV1
//
//  Created by Nicolas Baez on 4/12/24.
// This can be done eventually...

import RealityKit
import SwiftUI

class GameManager {
  var gameModel: GameModel

  init(gameModel: GameModel) {
    self.gameModel = gameModel
  }

  func rollDice() {
    gameModel.rolledNumLeft = Int.random(in: 1 ... 6)
    gameModel.rolledNumRight = Int.random(in: 1 ... 6)
    gameModel.rolled = true
    // Check rules post-dice roll
    checkGameRules()
  }

  private func checkGameRules() {
    if gameModel.rolledNumLeft == gameModel.rolledNumRight {
      gameModel.doublesRolled = true
    }
    // Additional rules logic
  }
}

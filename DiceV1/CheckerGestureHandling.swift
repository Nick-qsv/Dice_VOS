//
//  CheckerGestureHandling.swift
//  DiceV1
//
//  Created by Nicolas Baez on 4/9/24.
//

import RealityKit
import SwiftUI

extension Dice {
  func handleTap(value: EntityTargetValue<TapGesture.Value>) {
    let entity = value.entity
    // Determine which player is interacting and call the appropriate function
    if let _ = entity.components[Player1Component.self] {
      gameModel.handleCheckerMove(for: .player1, at: entity)
    } else if let _ = entity.components[Player2Component.self] {
      gameModel.handleCheckerMove(for: .player2, at: entity)
    }
  }
}

struct CheckerComponent: Component {}
struct Player1Component: Component {}
struct Player2Component: Component {}

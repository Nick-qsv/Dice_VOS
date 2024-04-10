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

    switch gameModel.turnState {
    case .player1:
      guard entity.components[Player1Component.self] != nil else {
        return // Entity does not have the Player1Component
      }
      print("Player 1 entity tapped")

    case .player2:
      guard entity.components[Player2Component.self] != nil else {
        return // Entity does not have the Player2Component
      }
      print("Player 2 entity tapped")
    }
  }
}

struct CheckerComponent: Component {}
struct Player1Component: Component {}
struct Player2Component: Component {}

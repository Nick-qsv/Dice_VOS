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
    if let playerComponent = entity.components[PlayerComponent.self] {
      gameModel.handleCheckerMove(for: playerComponent.owner, at: entity)
    }
  }
}

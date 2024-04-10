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
    guard entity.components[CheckerComponent.self] != nil else {
      return // This entity does not have the CheckerComponent, so we ignore it
    }
    // The entity has the CheckerComponent, so handle it accordingly
    print("Entity with CheckerComponent tapped")
  }
}

struct CheckerComponent: Component {}

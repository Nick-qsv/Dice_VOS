//
//  GestureHandling.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/25/24.
//
import RealityKit
import SwiftUI

extension Dice {
  func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
    guard let rightDie = rightDie, let leftDie = leftDie, gameModel.rollCount == 0 else { return }

    // Determine which die is being dragged
    let draggedDie = value.entity
    guard draggedDie.components[DiceComponent.self] != nil else {
      return // This entity does not have the DiceComponent, so we ignore it
    }
    // Calculate the new position based on the drag
    let newPosition = value.convert(value.location3D, from: .local, to: draggedDie.parent!)

    let offset = SIMD3<Float>(0.4, 0, 0) // Adjust the offset as needed
    // Apply the new position to the dragged die
    draggedDie.position = newPosition
    draggedDie.components[PhysicsBodyComponent.self]?.mode = .kinematic

    nonDraggedDie = draggedDie == rightDie ? leftDie : rightDie
    targetPosition = newPosition + (draggedDie == rightDie ? offset : -offset)

    chasing = true
    startRotatingEntity(nonDraggedDie!, &leftDieRotationTimer)
    startRotatingEntity(draggedDie, &rightDieRotationTimer)
  }

  func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
    rightDie?.components[PhysicsBodyComponent.self]?.mode = .dynamic
    leftDie?.components[PhysicsBodyComponent.self]?.mode = .dynamic

    stopRotatingEntity(&rightDieRotationTimer)
    stopRotatingEntity(&leftDieRotationTimer)
    chasing = false
    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
      gameModel.rollCount += 1
    }
  }
}

// when it's rolled something needs to change if its the first roll of the turn, if like they should turn off to prevent
// more rolls.  You can't play around with the dice.
// So maybe a first roll variable in the game state
// Like it checks if firstroll = 0
// or if firstroll > 0 turn off the gesture

struct DiceComponent: Component {}

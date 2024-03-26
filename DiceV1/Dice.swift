//
//  Dice.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/9/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct Dice: View {
  var diceData: DiceData
  var movementFactor: Float = 2.5
  @State var rightDieRotationTimer: Timer?
  @State var leftDieRotationTimer: Timer?
  @State var rightDie: Entity?
  @State var leftDie: Entity?
  @State var moveTimer: Timer?
  @State var targetPosition: SIMD3<Float>?
  @State var droppedDice = false
  @State var chasing = false
  @State var nonDraggedDie: Entity?

  var body: some View {
    RealityView { content in
      setupFloor(in: content)
      await loadAndConfigureDice(in: content)
      _ = content.subscribe(to: SceneEvents.Update.self) { _ in
        guard droppedDice,
              let motionLeft = leftDie?.components[PhysicsMotionComponent.self],
              let motionRight = rightDie?.components[PhysicsMotionComponent.self] else { return }

        let isMoving = simd_length(motionLeft.linearVelocity) >= 0.01 ||
          simd_length(motionRight.linearVelocity) >= 0.01 ||
          simd_length(motionLeft.angularVelocity) >= 0.01 ||
          simd_length(motionRight.angularVelocity) >= 0.01

        if !isMoving {
          print("Updating die state")
          updateDieState(leftDie!, isLeft: true)
          updateDieState(rightDie!, isLeft: false)
          diceData.rolled = true
        }
      }
      _ = content.subscribe(to: SceneEvents.Update.self) { _ in
        guard chasing, let nonDraggedDie = nonDraggedDie, let targetPosition = targetPosition else { return }
        nonDraggedDie.components[PhysicsBodyComponent.self]?.mode = .kinematic

        let currentPosition = nonDraggedDie.position(relativeTo: nil) // Assuming world coordinates
        let direction = targetPosition - currentPosition
        let distanceToTarget = simd_length(direction)

        if distanceToTarget > 0.01 { // Check if the entity is close enough to stop
          let stepSize = min(movementFactor * Float(1.0 / 60.0), distanceToTarget) // Move a bit each frame
          let step = simd_normalize(direction) * stepSize
          nonDraggedDie.position += step
          print("hi")
        } else {
          chasing = false // Stop chasing when the target is reached
        }
      }
    }
    .gesture(
      DragGesture()
        .targetedToAnyEntity()
        .onChanged(handleDrag)
        .onEnded(handleDragEnd)
    )
  }

  private func setupFloor(in content: RealityViewContent) {
    let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
    floor.generateCollisionShapes(recursive: false)
    floor.components[PhysicsBodyComponent.self] = .init(
      massProperties: .default,
      mode: .static
    )
    content.add(floor)
  }
}

#Preview {
  Dice(diceData: DiceData())
}

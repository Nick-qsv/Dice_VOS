//
//  LeftDie.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/9/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct LeftDie: View {
  @State private var rightDieRotationTimer: Timer?
  @State private var leftDieRotationTimer: Timer?
  @State private var rightDie: Entity?
  @State private var leftDie: Entity?
  @State private var moveTimer: Timer?
  @State private var targetPosition: SIMD3<Float>?

  var body: some View {
    RealityView { content in
      let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
      floor.generateCollisionShapes(recursive: false)
      floor.components[PhysicsBodyComponent.self] = .init(
        massProperties: .default,
        mode: .static
      )
      content.add(floor)

      if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
        print("Scene loaded successfully")

        // Configure both dice
        let diceNames = ["Right_Die", "Left_Die"]
        for dieName in diceNames {
          if let die = scene.findEntity(named: dieName) {
            configureDie(die)
            content.add(die)
            if dieName == "Right_Die" {
              rightDie = die
            } else if dieName == "Left_Die" {
              leftDie = die
            }
          } else {
            print("Failed to load Entity named \(dieName)")
          }
        }
      } else {
        print("Failed to load Scene")
      }
    }
    .gesture(
      DragGesture()
        .targetedToAnyEntity()
        .onChanged(handleDrag)
        .onEnded(handleDragEnd)
    )
  }

  func configureDie(_ die: Entity) {
    die.generateCollisionShapes(recursive: false)
  }

  func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
    guard let rightDie = rightDie, let leftDie = leftDie else { return }

    // Determine which die is being dragged
    let draggedDie = value.entity

    // Calculate the new position based on the drag
    let newPosition = value.convert(value.location3D, from: .local, to: draggedDie.parent!)

    let offset = SIMD3<Float>(0.4, 0, 0) // Adjust the offset as needed
    // Apply the new position to the dragged die
    draggedDie.position = newPosition
    draggedDie.components[PhysicsBodyComponent.self]?.mode = .kinematic

    // NEW
    let nonDraggedDie = draggedDie == rightDie ? leftDie : rightDie
    targetPosition = newPosition + (draggedDie == rightDie ? offset : -offset)
    nonDraggedDie.components[PhysicsBodyComponent.self]?.mode = .kinematic

    // Move the other die gradually towards the target position
    moveTimer?.invalidate() // Invalidate the existing timer if any
    moveTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
      // Gradually move the non-dragged die towards the target position
      let currentPos = nonDraggedDie.position
      let movementSpeed: Float = 0.1 // Adjust the speed as needed
      let newPos = currentPos + (targetPosition! - currentPos) * movementSpeed

      // Update the position of the non-dragged die
      nonDraggedDie.position = newPos

      // Stop the timer if the target position is reached approximately
      if simd_distance(currentPos, targetPosition!) < 0.3 { // 0.05 is the threshold, adjust as needed
        nonDraggedDie.position = targetPosition! // Snap to the exact target position
//            nonDraggedDie.components[PhysicsBodyComponent.self]?.mode = .dynamic
        timer.invalidate()
      }
    }
    startRotatingEntity(nonDraggedDie, &leftDieRotationTimer)
    startRotatingEntity(draggedDie, &rightDieRotationTimer)
  }

  // Helper function to calculate the distance between two points
  func distance(_ primary: SIMD3<Float>, _ secondary: SIMD3<Float>) -> Float {
    return simd_length(secondary - primary)
  }

  func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
    rightDie?.components[PhysicsBodyComponent.self]?.mode = .dynamic
    leftDie?.components[PhysicsBodyComponent.self]?.mode = .dynamic

    stopRotatingEntity(&rightDieRotationTimer)
    stopRotatingEntity(&leftDieRotationTimer)
  }

  private func startRotatingEntity(_ entity: Entity, _ timer: inout Timer?) {
    guard timer == nil else { return }
    let rotationSpeed = Float.pi / 90 // Adjust this for faster or slower rotation

    // Create a slightly random rotation axis each time
    let randomComponent = Float.random(in: -0.2 ... 0.2) // Small random addition
    let baseAxis = SIMD3<Float>(1, 1, 1) // Base axis direction
    let randomAxis = baseAxis + SIMD3<Float>(randomComponent, randomComponent, randomComponent)
//    let normalizedAxis = simd_normalize(randomAxis) // Normalize the axis

    timer = Timer.scheduledTimer(withTimeInterval: 1 / 120, repeats: true) { _ in
      var rotation = simd_quatf(angle: rotationSpeed, axis: randomAxis) // Spin around all axes
      rotation = simd_normalize(rotation) // Normalize the quaternion
      entity.orientation = simd_mul(entity.orientation, rotation)
      entity.orientation = simd_normalize(entity.orientation) // Normalize to prevent scaling
    }
  }

  private func stopRotatingEntity(_ timer: inout Timer?) {
    timer?.invalidate()
    timer = nil
  }
}

#Preview {
  LeftDie()
}

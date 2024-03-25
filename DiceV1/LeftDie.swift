//
//  LeftDie.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/9/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

let diceMap = [
  // + | -
  [4, 6], /// X
  [5, 3], // Y
  [2, 1] // Z
]

struct LeftDie: View {
  var diceData: DiceData
  var movementFactor: Float = 1.0
  @State private var rightDieRotationTimer: Timer?
  @State private var leftDieRotationTimer: Timer?
  @State private var rightDie: Entity?
  @State private var leftDie: Entity?
  @State private var moveTimer: Timer?
  @State private var targetPosition: SIMD3<Float>?
  @State private var droppedDice = false
  @State private var chasing = false
  @State private var nonDraggedDie: Entity?

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
      _ = content.subscribe(to: SceneEvents.Update.self) { _ in
        guard droppedDice else { return }
        let motionLeft = leftDie!.components[PhysicsMotionComponent.self]
        let motionRight = rightDie!.components[PhysicsMotionComponent.self]
        guard
          simd_length(motionLeft!.linearVelocity) < 0.01,
          simd_length(motionRight!.linearVelocity) < 0.01,
          simd_length(motionLeft!.angularVelocity) < 0.01,
          simd_length(motionRight!.angularVelocity) < 0.01
        else { return }
        print("Updating die state")
        updateDieState(leftDie!, isLeft: true)
        updateDieState(rightDie!, isLeft: false)
        diceData.rolled = true
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

  private func updateDieState(_ die: Entity?, isLeft: Bool) {
    guard let die = die else { return }

    let xDirection = die.convert(direction: SIMD3(x: 1, y: 0, z: 0), to: nil)
    let yDirection = die.convert(direction: SIMD3(x: 0, y: 1, z: 0), to: nil)
    let zDirection = die.convert(direction: SIMD3(x: 0, y: 0, z: 1), to: nil)
    let greatestDirection = [
      0: xDirection.y,
      1: yDirection.y,
      2: zDirection.y
    ].sorted(by: { abs($0.1) > abs($1.1) })[0]

    if isLeft {
      diceData.rolledNumLeft = diceMap[greatestDirection.key][greatestDirection.value > 0 ? 0 : 1]
    } else {
      diceData.rolledNumRight = diceMap[greatestDirection.key][greatestDirection.value > 0 ? 0 : 1]
    }

    print("\(isLeft ? "Left" : "Right") die rolled: \(isLeft ? diceData.rolledNumLeft : diceData.rolledNumRight)")
    print("\(isLeft ? "Right" : "Left") die rolled: \(isLeft ? diceData.rolledNumRight : diceData.rolledNumLeft)")

    droppedDice = false
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

    nonDraggedDie = draggedDie == rightDie ? leftDie : rightDie
    targetPosition = newPosition + (draggedDie == rightDie ? offset : -offset)

    chasing = true
    startRotatingEntity(nonDraggedDie!, &leftDieRotationTimer)
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
    chasing = false
    if !droppedDice {
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
        droppedDice = true
      }
    }
  }

  private func startRotatingEntity(_ entity: Entity, _ timer: inout Timer?) {
    guard timer == nil else { return }
    let rotationSpeed = Float.pi / 75 // Adjust this for faster or slower rotation

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
  LeftDie(diceData: DiceData())
}

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
    die.components[PhysicsBodyComponent.self] = .init(PhysicsBodyComponent(
      massProperties: .init(mass: 0.5),
      material: .generate(staticFriction: 1.2, dynamicFriction: 0.5, restitution: 0.5),
      mode: .dynamic
    ))
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
    // Move the other die by the same amount
    if draggedDie == rightDie {
      leftDie.position = newPosition + offset
      leftDie.components[PhysicsBodyComponent.self]?.mode = .kinematic
      startRotatingEntity(leftDie, &leftDieRotationTimer)
      startRotatingEntity(draggedDie, &rightDieRotationTimer)

    } else if draggedDie == leftDie {
      rightDie.position = newPosition + offset
      rightDie.components[PhysicsBodyComponent.self]?.mode = .kinematic
      startRotatingEntity(draggedDie, &leftDieRotationTimer)
      startRotatingEntity(rightDie, &rightDieRotationTimer)
    }
  }

  func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
    rightDie?.components[PhysicsBodyComponent.self]?.mode = .dynamic
    leftDie?.components[PhysicsBodyComponent.self]?.mode = .dynamic

    stopRotatingEntity(&rightDieRotationTimer)
    stopRotatingEntity(&leftDieRotationTimer)
  }

  private func startRotatingEntity(_ entity: Entity, _ timer: inout Timer?) {
    guard timer == nil else { return }
    let rotationSpeed = Float.pi / 60 // Adjust this for faster or slower rotation

    // Create a slightly random rotation axis each time
    let randomComponent = Float.random(in: -0.2 ... 0.2) // Small random addition
    let baseAxis = SIMD3<Float>(1, 1, 1) // Base axis direction
    let randomAxis = baseAxis + SIMD3<Float>(randomComponent, randomComponent, randomComponent)
//    let normalizedAxis = simd_normalize(randomAxis) // Normalize the axis

    timer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { _ in
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

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
  @State private var rotationTimer: Timer?
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
          } else {
            print("Failed to load Entity named \(dieName)")
          }
        }
      } else {
        print("Failed to load Scene")
      }
    }
    .gesture(TapGesture().targetedToAnyEntity().onEnded(handleTap))
    .gesture(
      DragGesture()
        .targetedToAnyEntity()
        .onChanged(reHandleDrag)
        .onEnded(reHandleDragEnd)
    )
  }

  func configureDie(_ die: Entity) {
    die.generateCollisionShapes(recursive: false)
    die.components[PhysicsBodyComponent.self] = .init(PhysicsBodyComponent(
      massProperties: .init(mass: 0.6),
      material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 0.4),
      mode: .dynamic
    ))
  }

  func handleTap(value: EntityTargetValue<TapGesture.Value>) {
    print("Entity tapped")
    var transform = value.entity.transform

    // Increase the translation to make the movement more noticeable
    transform.translation += SIMD3(1, 0, -1) // Adjust these values as needed

    // Add rotation for visual effect
    let angle = Float.pi / 4 // 45 degrees rotation
    let rotation = simd_quatf(angle: angle, axis: [0, 1, 0]) // Rotate around the y-axis
    transform.rotation = rotation * transform.rotation

    // Move and rotate the entity over 3 seconds
    value.entity.move(
      to: transform,
      relativeTo: nil,
      duration: 3,
      timingFunction: .easeInOut
    )
  }

  func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
    let entity = value.entity
    value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
    value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic

//    // Apply a constant rotational change to make the dice spin
//    let rotationSpeed = Float.pi / 60 // Adjust for faster or slower rotation
//    let rotationX = simd_quatf(angle: rotationSpeed, axis: SIMD3<Float>(1, 0, 0)) // Rotation around x-axis
//    let rotationY = simd_quatf(angle: rotationSpeed, axis: SIMD3<Float>(0, 1, 0)) // Rotation around y-axis
//    let rotationZ = simd_quatf(angle: rotationSpeed, axis: SIMD3<Float>(0, 0, 1)) // Rotation around z-axis
//
//    // Combine rotations to get a composite rotation effect
//    let rotation = rotationX * rotationY * rotationZ
//
//    entity.orientation *= rotation

    // Use the drag translation to determine the amount of rotation
    let translation = value.translation
    let rotationFactor = Float(0.01) // Adjust this factor to control the rotation sensitivity

    // Create rotation quaternions based on the translation of the drag
    let rotationX = simd_quatf(angle: Float(translation.height) * rotationFactor, axis: [1, 0, 0])
    let rotationY = simd_quatf(angle: Float(translation.width) * rotationFactor, axis: [0, 1, 0])

    // For z-axis rotation, you could use some other aspect of the gesture, like the speed or combine x and y
    let rotationZ = simd_quatf(
      angle: sqrt(Float(translation.width * translation.width + translation.height * translation.height)) *
        rotationFactor,
      axis: [0, 0, 1]
    )

    // Composite rotation by combining rotations around each axis
    let compositeRotation = rotationX * rotationY * rotationZ

    // Apply the composite rotation to the entity's orientation
    entity.orientation *= compositeRotation
  }

  func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
    let entity = value.entity
    entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
  }

  var dragGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
      .onChanged { value in
        print("entity dragged")
        value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
        value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
      }
      .onEnded { value in
        value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
      }
  }

  func reHandleDrag(value: EntityTargetValue<DragGesture.Value>) {
    value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
    value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
    startRotatingEntity(value.entity)
  }

  func reHandleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
    let entity = value.entity
    entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
    stopRotatingEntity()
  }

  private func startRotatingEntity(_ entity: Entity) {
    rotationTimer?.invalidate() // Stop any existing timer

    rotationTimer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { _ in
      let rotationSpeed = Float.pi / 30 // Adjust this for faster or slower rotation
      var rotation = simd_quatf(angle: rotationSpeed, axis: [1, 1, 1]) // Spin around all axes
      rotation = simd_normalize(rotation) // Normalize the quaternion

      entity.orientation = simd_mul(entity.orientation, rotation)
      entity.orientation = simd_normalize(entity.orientation) // Normalize to prevent scaling
    }
  }

  private func stopRotatingEntity() {
    rotationTimer?.invalidate()
    rotationTimer = nil
  }
}

#Preview {
  LeftDie()
}

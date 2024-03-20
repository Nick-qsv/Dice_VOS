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
      massProperties: .init(mass: 0.6),
      material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 0.4),
      mode: .dynamic
    ))
  }

  func handleDrag(value: EntityTargetValue<DragGesture.Value>) {
    value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
    value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
    startRotatingEntity(value.entity)
  }

  func handleDragEnd(value: EntityTargetValue<DragGesture.Value>) {
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

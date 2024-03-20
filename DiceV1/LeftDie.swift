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
    .gesture(dragGesture)
  }

  func configureDie(_ die: Entity) {
    die.generateCollisionShapes(recursive: false)
    die.components[PhysicsBodyComponent.self] = .init(PhysicsBodyComponent(
        massProperties: .init(mass:0.1),
      material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 0.9),
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
}

#Preview {
  LeftDie()
}

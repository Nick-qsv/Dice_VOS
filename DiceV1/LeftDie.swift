//
//  LeftDie.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/9/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct LeftDie: View {
    var body: some View {
        RealityView{content in
           if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
               print("Scene loaded successfully")
               if let entity = scene.findEntity(named: "Left_Die") {
                   // Now you can manipulate or interact with the entity
                   print("Entity loaded successfully")
                   content.add(entity)
               }else{
                   print("Failed to load Entity")
               }
           }else{
               print("Failed to load Scene")
           }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
            print("Entity tapped")
            var transform = value.entity.transform
            
            // Increase the translation to make the movement more noticeable
            transform.translation += SIMD3(1, 0, -1)  // Adjust these values as needed
            
            // Add rotation for visual effect
            let angle = Float.pi / 4  // 45 degrees rotation
            let rotation = simd_quatf(angle: angle, axis: [0, 1, 0]) // Rotate around the y-axis
            transform.rotation = rotation * transform.rotation
            
            // Move and rotate the entity over 3 seconds
            value.entity.move(
                to: transform,
                relativeTo: nil,
                duration: 3,
                timingFunction: .easeInOut
            )
        })

    }
}

#Preview {
    LeftDie()
}

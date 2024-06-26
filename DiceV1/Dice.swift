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
  var gameModel: GameModel
  var movementFactor: Float = 2.5
  @State var rightDieRotationTimer: Timer?
  @State var leftDieRotationTimer: Timer?
  @State var rightDie: Entity?
  @State var leftDie: Entity?
  @State var moveTimer: Timer?
  @State var targetPosition: SIMD3<Float>?
  @State var chasing = false
  @State var nonDraggedDie: Entity?
  @State var collisionSubscription: EventSubscription?
  @State var resultSubscription: EventSubscription?
  @State var chaseSubscription: EventSubscription?
  @State private var floor: Entity? // State variable for the floor entity
  @State var diceMP3: AudioFileResource?
  @State var leftDieAudioController: AudioPlaybackController?
  @State var rightDieAudioController: AudioPlaybackController?
  @State var p1C: Entity?
  @State var p2C: Entity?
  @State var board: Entity?
  var body: some View {
    RealityView { content in
      setupFloor(in: content)
      await loadAndConfigureDice(in: content)
      await preloadAudioAndEntities(leftDie: leftDie, rightDie: rightDie)
      await preloadPointArray(with: content)
      await loadBoard(in: content)
      await loadAndConfigureCheckers(in: content)
      setupBoardCollision(board)
      setUpInitialBoard()
      collisionSubscription = content.subscribe(to: CollisionEvents.Began.self, on: nil) { event in
        Task {
          handleCollisionStart(for: event)
        }
      }
      resultSubscription = content.subscribe(to: SceneEvents.Update.self) { _ in
        guard !gameModel.rolled, gameModel.rollCount == 1,
              let motionLeft = leftDie?.components[PhysicsMotionComponent.self],
              let motionRight = rightDie?.components[PhysicsMotionComponent.self] else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Delay of 0.5 seconds
          let isStationary = simd_length(motionLeft.linearVelocity) <= 0.01 &&
            simd_length(motionRight.linearVelocity) <= 0.01 &&
            simd_length(motionLeft.angularVelocity) <= 0.01 &&
            simd_length(motionRight.angularVelocity) <= 0.01

          if isStationary && gameModel.ranAlready {
            print("Updating die state")
            updateDieState(leftDie!, isLeft: true)
            updateDieState(rightDie!, isLeft: false)
            gameModel.rolled = true
            gameModel.ranAlready = false
          }
        }
      }
      chaseSubscription = content.subscribe(to: SceneEvents.Update.self) { _ in
        guard chasing, let nonDraggedDie = nonDraggedDie, let targetPosition = targetPosition else { return }
        nonDraggedDie.components[PhysicsBodyComponent.self]?.mode = .kinematic

        let currentPosition = nonDraggedDie.position(relativeTo: nil) // Assuming world coordinates
        let direction = targetPosition - currentPosition
        let distanceToTarget = simd_length(direction)

        if distanceToTarget > 0.01 { // Check if the entity is close enough to stop
          let stepSize = min(movementFactor * Float(1.0 / 60.0), distanceToTarget) // Move a bit each frame
          let step = simd_normalize(direction) * stepSize
          nonDraggedDie.position += step
        } else {
          chasing = false // Stop chasing when the target is reached
        }
      }
    }
    .simultaneousGesture(
      DragGesture()
        .targetedToAnyEntity()
        .onChanged(handleDrag)
        .onEnded(handleDragEnd)
    )
    .simultaneousGesture(
      TapGesture()
        .targetedToAnyEntity()
        .onEnded(handleTap)
    )
  }

  private func setupFloor(in content: RealityViewContent) {
    let floorEntity = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
    floorEntity.generateCollisionShapes(recursive: false)
    floorEntity.components[PhysicsBodyComponent.self] = .init(
      massProperties: .default,
      mode: .static
    )
    content.add(floorEntity)
    floor = floorEntity // Assign the floor entity to the state variable
  }

  private func handleCollisionStart(for event: CollisionEvents.Began) {
    if (event.entityA == leftDie && event.entityB == rightDie) ||
      (event.entityA == rightDie && event.entityB == leftDie)
    {
      print("The dice collided with each other")
      // Optionally, play a sound specific to dice collision
    } else if event.entityA == floor && (event.entityB == leftDie || event.entityB == rightDie) {
//      print("A die collided with the floor")
      playDiceSound(die: event.entityB) // Pass the colliding die
    } else if event.entityB == floor && (event.entityA == leftDie || event.entityA == rightDie) {
//      print("A die collided with the floor")
      playDiceSound(die: event.entityA) // Pass the colliding die
    }
  }

  func preloadAudioAndEntities(leftDie: Entity?, rightDie: Entity?) async {
    do {
      // Load the audio file resource
      diceMP3 = try await AudioFileResource.load(
        named: "/Root/dice_mp3",
        from: "Scene.usda",
        in: realityKitContentBundle
      )
      print("Audio preloaded successfully")
      // Check if the dice entities and the audio resource are available
      if let leftDie = leftDie, let rightDie = rightDie, let resource = diceMP3 {
        // Prepare audio for left die
        if let leftAudioEntity = await leftDie.findEntity(named: "LeftDieAud") {
          leftDieAudioController = await leftAudioEntity.prepareAudio(resource)
          print("Left die audio controller prepared")
        }

        // Prepare audio for right die
        if let rightAudioEntity = await rightDie.findEntity(named: "RightDieAud") {
          rightDieAudioController = await rightAudioEntity.prepareAudio(resource)
          print("Right die audio controller prepared")
        }
      }

    } catch {
      print("Failed to preload audio", error)
    }
  }
}

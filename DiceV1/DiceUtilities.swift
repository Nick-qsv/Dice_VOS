//
//  DiceUtilities.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/25/24.
//
import RealityKit
import RealityKitContent
import SwiftUI

let diceMap: [[Int]] = [
  // + | -
  [4, 6], /// X
  [5, 3], // Y
  [2, 1] // Z
]

func configureDie(_ die: Entity) {
  die.generateCollisionShapes(recursive: false)
}

func startRotatingEntity(_ entity: Entity, _ timer: inout Timer?) {
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

func stopRotatingEntity(_ timer: inout Timer?) {
  timer?.invalidate()
  timer = nil
}

extension Dice {
  func updateDieState(_ die: Entity?, isLeft: Bool) {
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

  func loadAndConfigureDice(in content: RealityViewContent) async {
    do {
      let scene = try await Entity(named: "Scene", in: realityKitContentBundle)
      print("Scene loaded successfully")

      let diceNames = ["Right_Die", "Left_Die"]
      for dieName in diceNames {
        guard let die = await scene.findEntity(named: dieName) else {
          print("Failed to load Entity named \(dieName)")
          continue
        }
        configureDie(die)
        content.add(die)

        switch dieName {
        case "Right_Die":
          rightDie = die
        case "Left_Die":
          leftDie = die
        default:
          break // Optionally handle unexpected cases
        }
      }
    } catch {
      print("Failed to load Scene")
    }
  }

  func playJetSound(_ die: Entity?) {
    guard let die = die else { return }
    let audioNames = ["RightDieAud", "LeftDieAud"]
    for audioName in audioNames {
      guard let audioEntity = die.findEntity(named: audioName) else {
        print("failed to load Audio Entity named \(audioName)")
        continue
      }
      if let resource = try? AudioFileResource.load(
        named: "/Root/JetOne",
        from: "Scene.usda",
        in: realityKitContentBundle
      ) {
        print("loaded audio! \(resource)")
        let audioPlaybackController = audioEntity.prepareAudio(resource)
        audioPlaybackController.play()
      } else {
        print("no go on audio :(")
      }
    }
  }

  func playDiceSoundAsync(_ die: Entity?) async {
    guard let die = die, let resource = diceMP3 else { return }
    let audioNames = ["RightDieAud", "LeftDieAud"]

    for audioName in audioNames {
      guard let audioEntity = await die.findEntity(named: audioName) else {
        print("failed to load Audio Entity named \(audioName)")
        continue
      }
      let audioPlaybackController = await audioEntity.prepareAudio(resource)
      await audioPlaybackController.play()
    }
  }
}

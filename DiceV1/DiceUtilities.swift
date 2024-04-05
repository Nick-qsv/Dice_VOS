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
      gameModel.rolledNumLeft = diceMap[greatestDirection.key][greatestDirection.value > 0 ? 0 : 1]
    } else {
      gameModel.rolledNumRight = diceMap[greatestDirection.key][greatestDirection.value > 0 ? 0 : 1]
    }

    print("\(isLeft ? "Left" : "Right") die rolled: \(isLeft ? gameModel.rolledNumLeft : gameModel.rolledNumRight)")
    print("\(isLeft ? "Right" : "Left") die rolled: \(isLeft ? gameModel.rolledNumRight : gameModel.rolledNumLeft)")

    droppedDice = false
  }

  func loadAndConfigureDice(in content: RealityViewContent) async {
    do {
      let scene = try await Entity(named: "Scene", in: realityKitContentBundle)
      print("Scene loaded successfully")
      guard let board = await scene.findEntity(named: "board_vc3") else {
        print("Failed to load board")
        return
      }

      content.add(board)
      guard let check1 = await scene.findEntity(named: "CheckerP1") else {
        print("Faile to load checker 1")
        return
      }
      content.add(check1)
      p1C = check1
      guard let check2 = await scene.findEntity(named: "CheckerP2") else {
        print("Faile to load checker 2")
        return
      }
      content.add(check2)
      p2C = check2
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

  func playDiceSound(die: Entity?) {
    guard let die = die else { return }

    if die == leftDie, let controller = leftDieAudioController {
      controller.play()
    } else if die == rightDie, let controller = rightDieAudioController {
      controller.play()
    }
  }
}

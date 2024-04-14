//
//  BoardUtilities.swift
//  DiceV1
//
//  Created by Nicolas Baez on 4/5/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

extension Dice {
  func loadBoard(in content: RealityViewContent) async {
    do {
      let scene = try await Entity(named: "Scene", in: realityKitContentBundle)
      print("Scene loaded successfully")
      guard let boardE = await scene.findEntity(named: "board_vc3") else {
        print("Failed to load board")
        return
      }
      board = boardE
      content.add(boardE)
    } catch {
      print("error in setupboard")
    }
  }

  func setupBoardCollision(_ board: Entity?) {
    guard let board = board else { return }
    board.components[CollisionComponent.self] = .none
    let base = ShapeResource.generateBox(width: 2.5, height: 0.264, depth: 5.333)
      .offsetBy(translation: [0, 0.315, 0])
    let centerBox = ShapeResource.generateBox(width: 2.5, height: 0.4, depth: 0.31)
      .offsetBy(translation: [0, 0.53, 0])
    let rightWall = ShapeResource.generateBox(width: 2.5, height: 0.4, depth: 0.12)
      .offsetBy(translation: [
        0,
        0.53,
        2.57
      ])
    let closeWall = ShapeResource.generateBox(width: 0.12, height: 0.4, depth: 5.33)
      .offsetBy(translation: [
        -1.15,
        0.53,
        0
      ])
    let leftWall = ShapeResource.generateBox(width: 2.5, height: 0.4, depth: 0.12)
      .offsetBy(translation: [
        0,
        0.53,
        -2.57
      ])
    let farWall = ShapeResource.generateBox(width: 0.12, height: 0.4, depth: 5.33)
      .offsetBy(translation: [
        1.15,
        0.53,
        0
      ])
    board.components[CollisionComponent.self] = CollisionComponent(shapes: [
      base,
      centerBox,
      rightWall,
      closeWall,
      leftWall,
      farWall
    ])
  }

  func preloadPointArray(with content: RealityViewContent) async {
    do {
      let scene = try await Entity(named: "Scene", in: realityKitContentBundle)
      print("Scene for Points loaded successfully")
      for idx in 1 ... 24 {
        let pointName = "P_\(idx)"
        guard let point = await scene.findEntity(named: pointName) else {
          print("Failed to load Entity named \(pointName)")
          continue
        }
        // Convert the local position to a global position
        let globalPosition = await point.position

        print("Loaded \(pointName) at global position \(globalPosition)") // Print the global position to verify
        let pointData = PointData(
          position: globalPosition, // Use the global position for your PointData
          checkerEntities: [] // Start with no checkers on this point
        )
        gameModel.points.append(pointData)
        // Visual debugging: place a visual marker at each point's global position
//        await MainActor.run {
//          addVisualMarker(at: globalPosition, with: content)
//        }
      }

      guard let bar1 = await scene.findEntity(named: "P1Bar") else {
        print("Failed to load Entity named P1Bar")
        return
      }
      gameModel.p1BarPosition = await BarPoint(point: bar1, position: bar1.position)

      guard let bar2 = await scene.findEntity(named: "P2Bar") else {
        print("Failed to load Entity named P2Bar")
        return
      }
      gameModel.p2BarPosition = await BarPoint(point: bar2, position: bar2.position)

    } catch {
      print("Failed to load point entities")
    }
  }

  @MainActor func addVisualMarker(at position: SIMD3<Float>, with content: RealityViewContent) {
    // Create the mesh
    let mesh = MeshResource.generateSphere(radius: 0.02)

    // Create the material
    let material = SimpleMaterial(color: .red, isMetallic: false)

    // Create the model entity with the mesh and material
    let marker = ModelEntity(mesh: mesh, materials: [material])
    marker.position = position
    content.add(marker)
  }
}

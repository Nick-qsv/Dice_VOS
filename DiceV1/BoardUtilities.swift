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

  func preloadPointArray() async {
    do {
      let scene = try await Entity(named: "Scene", in: realityKitContentBundle)
      print("Scene for Points loaded successfully")
      for idx in 1 ... 24 {
        let pointName = "P_\(idx)"
        guard let point = await scene.findEntity(named: pointName) else {
          print("Failed to load Entity named \(pointName)")
          continue
        }
        // Create the PointData for the loaded entity
        let pointData = await PointData(point: point, position: point.position, count: 0, pbe: .empty)

        // Add to P1Points in forward order
        gameModel.p1Points.append(pointData)
      }

      // For P2Points, load in reverse order
      for idx in (1 ... 24).reversed() {
        let pointName = "P_\(idx)"
        guard let point = await scene.findEntity(named: pointName) else {
          print("Failed to load Entity named \(pointName)")
          continue
        }

        // Create the PointData for the loaded entity
        let pointData = await PointData(point: point, position: point.position, count: 0, pbe: .empty)

        // Add to P2Points in reverse order
        gameModel.p2Points.append(pointData)
      }
      guard let bar1 = await scene.findEntity(named: "P1Bar") else {
        print("Failed to load Entity named P1Bar")
        return
      }
      gameModel.p1Bar = await BarPoint(point: bar1, position: bar1.position, count: 0)

      guard let bar2 = await scene.findEntity(named: "P2Bar") else {
        print("Failed to load Entity named P2Bar")
        return
      }
      gameModel.p2Bar = await BarPoint(point: bar2, position: bar2.position, count: 0)

      //      print("P1 Points:")
      //      for pointData in gameModel.p1Points {
      //        print(
      //          "Entity Name: \(await pointData.point.name), Position: \(pointData.position), Count:
      //          \(pointData.count),
      //          Point/Blot: \(pointData.pb)"
      //        )
      //      }
      //
      //      print("P2 Points:")
      //      for pointData in gameModel.p2Points {
      //        print(
      //          "Entity Name: \(await pointData.point.name), Position: \(pointData.position), Count:
      //          \(pointData.count),
      //          Point/Blot: \(pointData.pb)"
      //        )
      //      }
    } catch {
      print("Failed to load point entities")
    }
  }
}

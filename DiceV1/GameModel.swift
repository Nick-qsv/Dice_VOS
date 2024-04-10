//
//  GameModel.swift
//  DiceV1
//
//  Created by Nicolas Baez on 4/4/24.
//

import RealityKit
import SwiftUI

@Observable
class GameModel {
  var rolledNumLeft = 0
  var rolledNumRight = 0
  var rolled = false
  var rollCount = 0
  var turnState = TurnState.player1
  var gameState = GameState.mainMenu
  var p1Points: [PointData] = [] // Assuming you need an array of points for player 1
  var p2Points: [PointData] = []
  var p1Bar = BarPoint(point: Entity(), position: SIMD3<Float>(0, 0, 0), count: 0)
  var p2Bar = BarPoint(point: Entity(), position: SIMD3<Float>(0, 0, 0), count: 0)
  func toggleGameState() {
    if gameState == .mainMenu {
      gameState = .playing
    } else {
      gameState = .mainMenu
    }
  }
  // Position the next point (If it lands there) can go
  // If its a point or a blot Done
  // Bar
  // Number of checkers on the bar
  // Opening Position (eventually)
}

enum TurnState {
  case player1
  case player2
}

enum GameState {
  case mainMenu
  case playing
}

enum PointBlot {
  case point
  case blot
  case empty
}

// Define a struct to represent an entity, its position, and count
struct PointData {
  var point: Entity
  var position: SIMD3<Float>
  var count: Int
  var pbe: PointBlot
}

struct BarPoint {
  var point: Entity
  var position: SIMD3<Float>
  var count: Int
}

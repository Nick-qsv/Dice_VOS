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
  var doublesRolled = false
  var turnState = TurnState.player1
  var gameState = GameState.mainMenu
  var bar: [TurnState: Int] = [.player1: 0, .player2: 0] // Checkers on the bar
  var borneOff: [TurnState: Int] = [.player1: 0, .player2: 0] // Checkers borne off
  var p1Points: [PointData] = [] // Assuming you need an array of points for player 1
  var p2Points: [PointData] = []
  var checkers: [CheckerData] = []
  var p1BarPosition = BarPoint(point: Entity(), position: SIMD3<Float>(0, 0, 0))
  var p2BarPosition = BarPoint(point: Entity(), position: SIMD3<Float>(0, 0, 0))
  func toggleGameState() {
    if gameState == .mainMenu {
      gameState = .playing
    } else {
      gameState = .mainMenu
    }
  }

  func handleCheckerMove(for player: TurnState, at entity: Entity) {
    if player == .player1 {
      if checkForDoubles() {
        // There were doubles
        if checkForBarP1() {
          // There are pieces on the bar
          if checkForBarEntryPoints(player: player) {
            // You can enter from the bar
          } else {
            // You have fanned
          }
        } else {
          // There are no pieces on the bar
        }
      } else {
        // There were no doubles
        if checkForBarP1() {
          // There are pieces on the bar
          if checkForBarEntryPoints(player: player) {
            // You can enter from the bar
          } else {
            // You have fanned
          }
        } else {
          // There are no pieces on the bar
        }
      }
    } else if player == .player2 {
      // Handle Player 2's moves
    }
  }

  func checkForDoubles() -> Bool {
    return rolledNumLeft == rolledNumRight
  }

  func checkForBarP1() -> Bool {
    return bar[.player1]! > 0
  }

  func checkForBarP2() -> Bool {
    return bar[.player2]! > 0
  }

  func checkForBarEntryPoints(player: TurnState) -> Bool {
    // Get the two rolled numbers
    // Check if either rolled number has a point on it
    // If no then it has to go to the next turn.  Maybe a little display box that says (Fan) or something.  Maybe an
    // entity that appears and vanishes.
    let idx1 = rolledNumLeft - 1
    let idx2 = rolledNumRight - 1
    return idx1 == idx2
  }

  func enterFromBarP1() {
    if turnState == .player1 {
      // player1
      //
    } else {
      // player2
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
  var owner: TurnState? // Owner of the checkers at this point, nil if empty
  var pbe: PointBlot {
    if count == 0 {
      return .empty
    } else if count == 1 {
      return .blot
    } else {
      return .point
    }
  }
}

struct BarPoint {
  var point: Entity
  var position: SIMD3<Float>
}

struct CheckerData {
  var checker: Entity
  var currentPosition: Int // Current position index in the points array
  var previousPosition: Int? // Previous position index in the points array before the move
  var isOnBar: Bool
  var isBornOff: Bool
  var owner: TurnState
}

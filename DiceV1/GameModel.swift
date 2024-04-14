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
  var ranAlready = true
  var doublesRolled = false
  var turnState = TurnState.player1
  var gameState = GameState.mainMenu
  var bar: [TurnState: Int] = [.player1: 0, .player2: 0] // Checkers on the bar
  var borneOff: [TurnState: Int] = [.player1: 0, .player2: 0] // Checkers borne off
  var points: [PointData] = [] // Assuming you need an array of points for player 1
  var player1Checkers: [CheckerData] = []
  var player2Checkers: [CheckerData] = []
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

enum GameState {
  case mainMenu
  case playing
}

enum PointBlot: Codable {
  case madePoint
  case blot
  case emptyPoint
}

// Define a class to represent an entity, its position, and count
class PointData {
  var position: SIMD3<Float> // 3D position of the point
  var checkerEntities: [CheckerData] // Array to store checker entities at this point

  var count: Int {
    return checkerEntities.count
  }

  var owner: TurnState? { // Determine the owner based on the first checker, if any
    guard let firstChecker = checkerEntities.first else { return nil }
    return firstChecker.owner
  }

  var pbe: PointBlot {
    switch checkerEntities.count {
    case 0:
      return .emptyPoint
    case 1:
      return .blot
    default:
      return .madePoint
    }
  }

  // Initializer for the PointData class
  init(position: SIMD3<Float>, checkerEntities: [CheckerData] = []) {
    self.position = position
    self.checkerEntities = checkerEntities
  }
}

struct BarPoint {
  var point: Entity
  var position: SIMD3<Float>
}

class CheckerData {
  let id: UUID // Unique identifier for each checker
  var physicalEntity: Entity
  var currentPosition: Int // Current position index in the points array
  var previousPosition: Int? // Previous position index in the points array before the move
  var isOnBar: Bool
  var isBorneOff: Bool
  var owner: TurnState
  init(
    id: UUID,
    physicalEntity: Entity,
    currentPosition: Int,
    previousPosition: Int?,
    isOnBar: Bool,
    isBorneOff: Bool,
    owner: TurnState
  ) {
    self.id = id
    self.physicalEntity = physicalEntity
    self.currentPosition = currentPosition
    self.previousPosition = previousPosition
    self.isOnBar = isOnBar
    self.isBorneOff = isBorneOff
    self.owner = owner
  }
}

struct PlayerComponent: Component, Codable {
  let owner: TurnState
}

enum TurnState: Codable {
  case player1
  case player2
}

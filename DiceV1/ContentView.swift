//
//  ContentView.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/4/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {
  @State private var showImmersiveSpace = false
  @State private var immersiveSpaceIsShown = false

  @Environment(\.openImmersiveSpace) var openImmersiveSpace
  @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
  var gameModel: GameModel

  var body: some View {
    VStack {
      switch gameModel.gameState {
      case .mainMenu:
        Text("Click the button below to start the game")
          .foregroundStyle(.green)
          .font(.custom("Menlo", size: 40))
          .bold()
      case .playing:
        if !gameModel.rolled {
          Text("\(gameModel.rollState == .player1Turn ? "Player 1" : "Player 2"), roll the dice!")
            .foregroundStyle(.green)
            .font(.custom("Menlo", size: 40))
            .bold()
        } else {
          Text("You rolled: \(gameModel.rolledNumLeft) & \(gameModel.rolledNumRight)")
            .foregroundColor(.green)
            .font(.custom("Menlo", size: 50))
          Button("Next Player's Turn") {
            // Move to the next player and reset the rolled state
            gameModel.rollState = gameModel.rollState == .player1Turn ? .player2Turn : .player1Turn
            gameModel.rolled = false
          }
          .foregroundColor(.white)
          .padding()
          .cornerRadius(10)
        }
      }
      Toggle(gameModel.gameState == .playing ? "End the Game" : "Start the Game", isOn: $showImmersiveSpace)
        .toggleStyle(.button)
        .padding(.top, 50)
    }
    .padding()
    .onChange(of: showImmersiveSpace) { _, newValue in
      print("Toggle changed: \(newValue)")
      gameModel.toggleGameState()
      gameModel.rollState = .player1Turn
      Task {
        if newValue {
          print("Attempting to open immersive space")
          switch await openImmersiveSpace(id: "die") {
          case .opened:
            immersiveSpaceIsShown = true
            print("Immersive space opened")
          case .error, .userCancelled:
            fallthrough
          @unknown default:
            immersiveSpaceIsShown = false
            showImmersiveSpace = false
          }
        } else if immersiveSpaceIsShown {
          print("Attempting to dismiss immersive space")
          await dismissImmersiveSpace()
          immersiveSpaceIsShown = false
          gameModel.rolled = false
        }
      }
    }
  }
}

#Preview(windowStyle: .automatic) {
  ContentView(gameModel: GameModel())
}

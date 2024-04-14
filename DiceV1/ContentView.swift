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
  @State private var volumeIsShown = false
  @State private var showVolume = false

  @Environment(\.dismissWindow) var dismissWindow
  @Environment(\.openWindow) var openWindow

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
          Text("\(gameModel.turnState == .player1 ? "Player 1" : "Player 2"), roll the dice!")
            .foregroundStyle(.green)
            .font(.custom("Menlo", size: 40))
            .bold()
        } else {
          Text("You rolled: \(gameModel.rolledNumLeft) & \(gameModel.rolledNumRight)")
            .foregroundColor(.green)
            .font(.custom("Menlo", size: 50))
          Button("Next Player's Turn") {
            // Move to the next player and reset the rolled state
            gameModel.turnState = gameModel.turnState == .player1 ? .player2 : .player1
            gameModel.rolled = false
            gameModel.rollCount = 0
            gameModel.ranAlready = true
          }
          .foregroundColor(.white)
          .padding()
          .cornerRadius(10)
        }
      }
      Toggle(gameModel.gameState == .playing ? "End the Game" : "Start the Game", isOn: $showVolume)
        .toggleStyle(.button)
        .padding(.top, 50)
    }
    .padding()
    .onChange(of: showVolume) { _, newValue in
      print("Toggle changed: \(newValue)")
      gameModel.toggleGameState()
      gameModel.turnState = .player1
      if newValue {
        print("Attempting to open volume")
        openWindow(id: "die")
        volumeIsShown = true // Assuming the volume opens without a specific opened case
        print("Volume opened")
      } else if volumeIsShown {
        print("Attempting to dismiss volume")
        dismissWindow(id: "die")
        volumeIsShown = false
      }
    }
  }
}

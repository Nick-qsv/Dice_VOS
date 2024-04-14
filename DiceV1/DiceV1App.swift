//
//  DiceV1App.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/4/24.
//

import SwiftUI

@main
struct DiceV1App: App {
  @State var gameModel = GameModel()
  var body: some Scene {
    WindowGroup {
      ContentView(gameModel: gameModel)
    }.defaultSize(width: 1200, height: 500)
    WindowGroup(id: "die") {
      Dice(gameModel: gameModel)
    }.windowStyle(.volumetric)
      .defaultSize(width: 2, height: 0.2, depth: 2, in: .meters)
  }
}

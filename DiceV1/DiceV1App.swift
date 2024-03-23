//
//  DiceV1App.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/4/24.
//

import SwiftUI

@Observable
class DiceData {
  var rolledNumLeft = 0
  var rolledNumRight = 0
}

@main
struct DiceV1App: App {
  @State var diceData = DiceData()
  var body: some Scene {
    WindowGroup {
      ContentView(diceData: diceData)
    }.defaultSize(width: 400, height: 400)
    ImmersiveSpace(id: "die") {
      LeftDie(diceData: diceData)
    }
  }
}

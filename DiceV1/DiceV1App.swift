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
  var rolled = false
}

@main
struct DiceV1App: App {
  @State var diceData = DiceData()
  var body: some Scene {
    WindowGroup {
      ContentView(diceData: diceData)
    }.defaultSize(width: 1200, height: 500)
    ImmersiveSpace(id: "die") {
      Dice(diceData: diceData)
    }
  }
}

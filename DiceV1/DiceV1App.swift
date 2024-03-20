//
//  DiceV1App.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/4/24.
//

import SwiftUI

@main
struct DiceV1App: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }.defaultSize(width: 400, height: 400)
    ImmersiveSpace(id: "die") {
      LeftDie()
    }
  }
}

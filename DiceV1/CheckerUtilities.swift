//
//  CheckerUtilities.swift
//  DiceV1
//
//  Created by Nicolas Baez on 4/10/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

extension Dice {
  func loadAndConfigureCheckers(in content: RealityViewContent) async {
    do {
      let scene = try await Entity(named: "Scene", in: realityKitContentBundle)
      print("Scene loaded successfully")
      guard let check1 = await scene.findEntity(named: "CheckerP1") else {
        print("Faile to load checker 1")
        return
      }
      await check1.components.set(CheckerComponent())
      await check1.components.set(Player1Component())
      content.add(check1)
      p1C = check1
      guard let check2 = await scene.findEntity(named: "CheckerP2") else {
        print("Faile to load checker 2")
        return
      }
      await check2.components.set(CheckerComponent())
      await check2.components.set(Player2Component())
      content.add(check2)
      p2C = check2
    } catch {
      print("Failed to load Checkers")
    }
  }
}

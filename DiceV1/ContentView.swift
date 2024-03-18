//
//  ContentView.swift
//  DiceV1
//
//  Created by Nicolas Baez on 3/4/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    
    var body: some View {
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.bottom, 50)

            Text("Roll the Dice!")
            Toggle("Show Immersive Space", isOn: $showImmersiveSpace)
                .toggleStyle(.button)
                .padding(.top, 50)
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            print("Toggle changed: \(newValue)")
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
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}

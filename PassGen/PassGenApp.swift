//
//  PassGenApp.swift
//  PassGen
//
//  Created by Leandro Serzo on 7/23/26.
//

import SwiftUI

@main
struct PassGenApp: App {
    var body: some Scene {
        MenuBarExtra("PassGen", systemImage: "key.fill") {
            ContentView()
        }.menuBarExtraStyle(.window)
    }
}

//
//  MoovieApp.swift
//  Moovie
//
//  Created by Baptiste Dangy on 15/06/2025.
//

import SwiftUI

@main
struct MoovieApp: App {
    @ObservedObject private var userManager = UserManager.shared
    @State private var path = NavigationPath()
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                if userManager.isSetupComplete {
                    HomeView(path: $path)
                } else {
                    UserSetupView(path: $path)
                }
            }
        }
    }
}

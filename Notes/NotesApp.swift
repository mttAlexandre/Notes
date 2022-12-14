//
//  NotesApp.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

@main
struct NotesApp: App {

    @StateObject private var model = Model()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}

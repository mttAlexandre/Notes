//
//  NotesApp.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

@main
struct NotesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(groups: Model.testGroups, notes: Model.testNotes)
        }
    }
}

//
//  Model.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 21/08/2022.
//

import Foundation

enum ModelError: Error {
    case groupError(String)
    case noteError(String)
    case none
}

final class Model: ObservableObject {

    @Published var groups = [Group]()
    @Published var notes = [Note]()

    init() {
#if DEBUG
        generateSampleData()
        return
#endif
    }

// MARK: - DEBUG data

#if DEBUG
    private func generateSampleData() {
        groups = [
            Group(name: "🏠 Home"),
            Group(name: "📕 Recipes", color: .teal),
            Group(name: "💻 Work", color: .purple),
            Group(name: "🏖 Holidays", color: .mint)
        ]

        notes = [
            Note(group: groups[1], title: "🍩 Donuts", titleColor: .pink,
                 content: """
    **Ingredients :**
        - eggs
        - sugar
        - flour
    """),
            Note(group: groups[1], title: "🍫 Chocolat cake", titleColor: .brown,
                 content: """
    **Ingredients :**
        - chocolat
        - eggs
        - sugar
        - flour
    """),
            Note(group: groups[0], title: "🪴 Garden", titleColor: .green, content: ""),
            Note(group: groups[2], title: "🚨 Deadlines", titleColor: .red, content: ""),
            Note(group: groups[2], title: "☑ Todo", titleColor: .indigo, content: ""),
            Note(group: groups[3], title: "🏔 Hikes", titleColor: .green, content: ""),
            Note(group: groups[3], title: "⛈ Indoor activities", titleColor: .blue, content: ""),
            Note(group: groups[3], title: "🧳 Bags", titleColor: .orange, content: "")
        ]
    }
#endif

    func addGroup(_ group: Group) throws {
        if group.name.isEmpty {
            throw ModelError.groupError("Group name cannot be empty")
        }

        if groups.map({ $0.name }).contains(group.name) {
            throw ModelError.groupError("A group with this name already exists")
        }

        groups.append(group)
    }

    func deleteGroup(_ group: Group) {
        groups.removeAll {
            $0 == group
        }
    }

    func addNote(_ note: Note) throws {
        if !groups.contains(note.group) {
            try addGroup(note.group)
        }

        if note.title.isEmpty {
            throw ModelError.noteError("Note title cannot be empty")
        }

        if notes.map({ $0.title }).contains(note.title) {
            throw ModelError.noteError("A note with this title already exists")
        }

        notes.append(note)
    }

    func deleteNote(_ note: Note) {
        notes.removeAll {
            $0 == note
        }
    }

    func modifyNote(_ note: Note) throws {
        if !groups.contains(note.group) {
            try addGroup(note.group)
        }

        if note.title.isEmpty {
            throw ModelError.noteError("Note title cannot be empty")
        }

        if notes.compactMap({ $0.id == note.id ? nil : $0.title }).contains(note.title) {
            throw ModelError.noteError("A note with this title already exists")
        }

        guard let index = notes.firstIndex(where: {
            $0.id == note.id
        }) else {
            throw ModelError.noteError("Could not find index of note to modify")
        }

        notes[index] = note
    }
}

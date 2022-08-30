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

    private static func storageURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("Storage.sqlite")
    }

    func load() throws {
#if DEBUG
        try generateSampleData()
        return
#else
        let groupdDal = try instanciateGroupDal()
        let noteDal = try instanciateNoteDal()

        groups = groupdDal.selectAll()
        notes = noteDal.selectAll()
#endif
    }

    // MARK: - Group handling

    private func instanciateGroupDal() throws -> GroupDal {
        GroupDal(dbURL: try Model.storageURL())
    }

    func addGroup(_ group: Group) throws {
        if group.name.isEmpty {
            throw ModelError.groupError("Group name cannot be empty")
        }

        if groups.map({ $0.name }).contains(group.name) {
            throw ModelError.groupError("A group with this name already exists")
        }

        let groupdDal = try instanciateGroupDal()
        try groupdDal.insert(group)
        groups.append(group)
    }

    func deleteGroup(_ group: Group) throws {
        let noteDal = try instanciateNoteDal()
        try noteDal.deleteAllWithGroup(group)

        notes.removeAll {
            $0.group == group
        }

        let groupdDal = try instanciateGroupDal()
        try groupdDal.delete(group)

        groups.removeAll {
            $0 == group
        }
    }

    // MARK: - Note handling

    private func instanciateNoteDal() throws -> NoteDal {
        NoteDal(dbURL: try Model.storageURL())
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

        let noteDal = try instanciateNoteDal()
        try noteDal.insert(note)

        notes.append(note)
    }

    func deleteNote(_ note: Note) throws {
        let noteDal = try instanciateNoteDal()
        try noteDal.delete(note)

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

        let noteDal = try instanciateNoteDal()
        try noteDal.update(note)

        notes[index] = note
    }

    // MARK: - DEBUG data

#if DEBUG
    private func generateSampleData() throws {
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

        let groupDal = try instanciateGroupDal()
        let noteDal = try instanciateNoteDal()
        let groupConnection = try groupDal.getConnection()
        let noteConnection = try noteDal.getConnection()

        try noteDal.dropTable(ifExists: true, db: noteConnection)
        try groupDal.dropTable(ifExists: true, db: groupConnection)

        for group in groups {
            try groupDal.insert(group, db: groupConnection)
        }

        for note in notes {
            try noteDal.insert(note, db: noteConnection)
        }
    }
#endif
}

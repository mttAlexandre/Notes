//
//  NoteDal.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 29/08/2022.
//

import Foundation
import SQLite
import SwiftUI

// swiftlint: disable identifier_name
class NoteDal {

    private let notes = Table("notes")
    private let id = Expression<String>("id")
    private let title = Expression<String>("title")
    private let titleColor = Expression<String>("titleColor")
    private let content = Expression<String>("content")
    private let groupFK = Expression<String>("groupFK")

    private let groups = Table("groups")
    private let groupId = Expression<String>("id")

    private let dbPath: String

    init(dbURL: URL) {
        dbPath = dbURL.relativePath
    }

    private func createTable(_ db: Connection) throws {
        try db.run(notes.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title, unique: true)
            t.column(titleColor)
            t.column(content)
            t.column(groupFK)
            t.foreignKey(groupFK, references: groups, groupId, delete: .setNull)
        })
    }

    func getConnection() throws -> Connection {
        try Connection(dbPath)
    }

    func selectAll(withGroup group: Group? = nil, db: Connection? = nil) -> [Note] {
        do {
            var res = [Note]()

            try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
                for note in try db.prepare(notes) {
                    res.append(Note(id: UUID(uuidString: note[id])!,
                                    group: Group(name: ""),
                                    title: note[title],
                                    titleColor: Color(hex: note[titleColor]),
                                    content: note[content]))
                }
            })

            return res
        } catch {
            print("NoteDal.selectAll : " + error.localizedDescription)
            return []
        }
    }

    func insert(_ note: Note, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            try createTable(db)
            let insert = notes.insert(id <- note.id.description,
                                      title <- note.title,
                                      titleColor <- note.titleColor.toHex!,
                                      content <- note.content,
                                      groupFK <- note.group.id.description)
            try db.run(insert)
        })
    }

    func update(_ note: Note, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            try createTable(db)
            let noteToUpdate = notes.filter(id == note.id.description)
            try db.run(noteToUpdate.update(title <- note.title,
                                           titleColor <- note.titleColor.toHex!,
                                           content <- note.content,
                                           groupFK <- note.group.id.description))
        })
    }

    func delete(_ note: Note, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            let noteToDelete = notes.filter(id == note.id.description)
            try db.run(noteToDelete.delete())
        })
    }

    func dropTable(ifExists exists: Bool = false, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            try db.run(notes.drop(ifExists: exists))
        })
    }
}

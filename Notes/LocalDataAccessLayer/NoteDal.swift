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

    private let dbURL: URL
    private let dbPath: String

    init(dbURL: URL) {
        self.dbURL = dbURL
        self.dbPath = dbURL.relativePath
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

            let groupDal = GroupDal(dbURL: dbURL)

            try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
                for note in try db.prepare(notes) {
                    guard let noteID = UUID(uuidString: note[id]) else {
                        print("NoteDal.selectAll : note id is not a UUID")
                        try delete(note[id], db: db)
                        continue
                    }
                    
                    guard let groupID = UUID(uuidString: note[groupFK]) else {
                        print("NoteDal.selectAll : Invalid groupFK UUID")
                        try delete(note[id], db: db)
                        continue
                    }

                    guard let group = groupDal.selectOneWithID(groupID, db: db) else {
                        print("NoteDal.selectAll : No group found")
                        try delete(note[id], db: db)
                        continue
                    }

                    res.append(Note(id: noteID,
                                    group: group,
                                    title: note[title],
                                    titleColor: Color(hex: note[titleColor]) ?? Color.black,
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
                                      titleColor <- note.titleColor.toHex() ?? "",
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
                                           titleColor <- note.titleColor.toHex() ?? "",
                                           content <- note.content,
                                           groupFK <- note.group.id.description))
        })
    }

    func delete(_ note: Note, db: Connection? = nil) throws {
        try delete(note.id.description, db: db)
    }
    
    private func delete(_ idString: String, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            let noteToDelete = notes.filter(id == idString)
            try db.run(noteToDelete.delete())
        })
    }

    func deleteAllWithGroup(_ group: Group, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            let noteToDelete = notes.filter(groupFK == group.id.description)
            try db.run(noteToDelete.delete())
        })
    }

    func dropTable(ifExists exists: Bool = false, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            try db.run(notes.drop(ifExists: exists))
        })
    }
}

//
//  GroupDal.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 29/08/2022.
//

import Foundation
import SQLite
import SwiftUI

// swiftlint: disable identifier_name
class GroupDal {

    private let groups = Table("groups")
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let color = Expression<String>("color")

    private let dbPath: String

    init(dbURL: URL) {
        dbPath = dbURL.relativePath
    }

    private func createTable(_ db: Connection) throws {
        try db.run(groups.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name, unique: true)
            t.column(color)
        })
    }

    func getConnection() throws -> Connection {
        try Connection(dbPath)
    }

    func selectAll(_ db: Connection? = nil) -> [Group] {
        do {
            var res = [Group]()

            try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
                for group in try db.prepare(groups) {
                    res.append(Group(id: UUID(uuidString: group[id])!,
                                     name: group[name],
                                     color: Color(hex: group[color]) ?? Color.black))
                }
            })

            return res
        } catch {
            print("GroupDal.selectAll : " + error.localizedDescription)
            return []
        }
    }

    func insert(_ group: Group, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            try createTable(db)
            let insert = groups.insert(id <- group.id.description,
                                       name <- group.name,
                                       color <- group.color.toHex() ?? "")
            try db.run(insert)
        })
    }

    func update(_ group: Group, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            try createTable(db)
            let groupToUpdate = groups.filter(id == group.id.description)
            try db.run(groupToUpdate.update(name <- group.name,
                                            color <- group.color.toHex() ?? ""))
        })
    }

    func delete(_ group: Group, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            let groupToDelete = groups.filter(id == group.id.description)
            try db.run(groupToDelete.delete())
        })
    }

    func count(_ db: Connection? = nil) throws -> Int? {
        var res: Int?

        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            res = try db.scalar(groups.count)
        })

        return res
    }

    func dropTable(ifExists exists: Bool = false, db: Connection? = nil) throws {
        try DalHelpers.openConnectionFromPath(dbPath, orUseConnection: db, andExecute: { db in
            try db.run(groups.drop(ifExists: exists))
        })
    }
}

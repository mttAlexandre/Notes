//
//  DalHelpers.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 29/08/2022.
//

import Foundation
import SQLite

// swiftlint: disable identifier_name
class DalHelpers {

    static func openConnectionFromPath(_ path: String, orUseConnection connection: Connection?,
                                       andExecute block: (_ db: Connection) throws -> Void) throws {
        if let connection = connection {
            try DalHelpers.executeBlockIn(connection, block: block)
            return
        }

        try DalHelpers.openConnection(path, andExecute: block)
    }

    private static func openConnection(_ dbPath: String, andExecute block: (_ db: Connection) throws -> Void) throws {
        let db = try Connection(dbPath)
        // foreign keys are not allowed by default in SQLite
        try db.execute("PRAGMA foreign_keys = ON;")
        try DalHelpers.executeBlockIn(db, block: block)
    }

    private static func executeBlockIn(_ db: Connection, block: (_ db: Connection) throws -> Void) throws {
        try block(db)
    }
}

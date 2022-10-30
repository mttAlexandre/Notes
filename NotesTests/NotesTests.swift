//
//  NotesTests.swift
//  NotesTests
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import XCTest
@testable import Notes
import SQLite
import SQLiteObjc
import SwiftUI

final class NotesTests: XCTestCase {

    private let fileName = "StorageTest.sqlite"
    private var fileURL: URL!

    override func setUpWithError() throws {
        _ = FileManager.deleteFile(fileName)
        fileURL = try FileManager.default.url(for: .documentDirectory,
                                                          in: .userDomainMask,
                                                          appropriateFor: nil,
                                                          create: false)
            .appendingPathComponent(fileName)
    }

    override func tearDownWithError() throws {
        _ = FileManager.deleteFile(fileName)
    }

// MARK: - DAL create tables

    func testDalTablesCreation() throws {
        // test data
        var group = Group(name: "DevGroup")
        let note = Note(group: group, title: "DevNote")
        // create dal instances
        let groupDal = GroupDal(dbURL: fileURL)
        let noteDal = NoteDal(dbURL: fileURL)
        // keep connection for all operations
        let groupConnection = try groupDal.getConnection()
        let noteConnection = try noteDal.getConnection()
        // drop tables
        try noteDal.dropTable(ifExists: true, db: noteConnection)
        try groupDal.dropTable(ifExists: true, db: groupConnection)
        // insert test data
        try groupDal.insert(group, db: groupConnection)
        try noteDal.insert(note, db: noteConnection)
        // modify inserted group
        group.name = "Modified name"
        try groupDal.update(group, db: groupConnection)
        // get all groups
        let groups = groupDal.selectAll(groupConnection)
        // verify group count and update
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first!.name, "Modified name")
    }

    func testColorCodable() throws {
        for _ in 0...500 {
            let colorA = Color.random
            let hex = colorA.toHex()
            XCTAssertNotNil(hex)
            let colorB = Color(hex: hex!)
            XCTAssertNotNil(colorB)
            XCTAssertEqual(colorA.description, colorB!.description)
        }
    }

    func testMarkdownIntoSqlite() throws {
        let content = #"""
# Title
## Subtitle
### Sub-subtitle
**bold**

*italic*

[link](https://github.com/gonzalezreal/MarkdownUI)

`var success = true`

---

1. First
    - a
    - b
2. Second
    - c

"""#
        let group = Group(name: "DevGroup")
        var note = Note(group: group, title: "DevNote")
        note.content = content
        // create dal instances
        let groupDal = GroupDal(dbURL: fileURL)
        let noteDal = NoteDal(dbURL: fileURL)
        // keep connection for all operations
        let groupConnection = try groupDal.getConnection()
        let noteConnection = try noteDal.getConnection()
        // insert test data
        try groupDal.insert(group, db: groupConnection)
        try noteDal.insert(note, db: noteConnection)

        let notes = noteDal.selectAll(db: noteConnection)
        XCTAssertEqual(notes.count, 1)

        let firstNote = notes.first
        XCTAssertNotNil(firstNote)
        print(firstNote!.content)
        XCTAssertEqual(firstNote!.content, content)
    }
}

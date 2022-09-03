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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

// MARK: - DAL create tables

    func testDalTablesCreation() throws {
        let url = try FileManager.default.url(for: .documentDirectory,
                                              in: .userDomainMask,
                                              appropriateFor: nil,
                                              create: false)
            .appendingPathComponent("Storage.sqlite")
        // test data
        var group = Group(name: "DevGroup")
        let note = Note(group: group, title: "DevNote")
        // create dal instances
        let groupDal = GroupDal(dbURL: url)
        let noteDal = NoteDal(dbURL: url)
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

}

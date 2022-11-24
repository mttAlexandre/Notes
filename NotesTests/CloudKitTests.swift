//
//  CloudKitTests.swift
//  NotesTests
//
//  Created by Alexandre MONTCUIT on 01/11/2022.
//

import XCTest
@testable import Notes

final class CloudKitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        let group1 = Group(name: "CKTestGroup1", color: .white)
        let group2 = Group(name: "CKTestGroup2", color: .black)

        let note11 = Note(
            group: group1,
            title: "CKTestTitle11",
            titleColor: .red,
            content: "CKTestContent11"
        )

        let note21 = Note(
            group: group2,
            title: "CKTestTitle21",
            titleColor: .pink,
            content: "CKTestContent21"
        )

        let note22 = Note(
            group: group2,
            title: "CKTestTitle22",
            titleColor: .blue,
            content: "CKTestContent22"
        )

        let service = CloudKitService()

        do {
            try await service.save(group1.record)
            try await service.save(group2.record)

            try await service.save(note11.record)
            try await service.save(note21.record)
            try await service.save(note22.record)

            let groups = try await service.fetchGroups()
            XCTAssertEqual(groups.count, 2)

            // knowing groups are sorted by title
            let notes1 = try await service.fetchNotes(inGroup: groups.first!)
            XCTAssertEqual(notes1.count, 1)

            let notes2 = try await service.fetchNotes(inGroup: groups.last!)
            XCTAssertEqual(notes2.count, 2)

            // deleting the group should also delete the note referencing it
            try await service.delete(group1.record)

            // check the group deletion
            let groupsAfterDelete = try await service.fetchGroups()
            XCTAssertEqual(groupsAfterDelete.count, 1)

            // check the note automatic deletion
            let notes1AfterDelete = try await service.fetchNotes(inGroup: groups.first!)
            XCTAssertEqual(notes1AfterDelete.count, 0)

            // check remaining notes
            let notes2AfterDelete = try await service.fetchNotes(inGroup: groups.last!)
            XCTAssertEqual(notes2AfterDelete.count, 2)

            // clean base by deleting the other group
            try await service.delete(group2.record)
        } catch {
            print(error.localizedDescription)
            XCTAssert(false)
        }
    }

    func testFetchGroups() async throws {
        let service = CloudKitService()

        do {
            let groups = try await service.fetchGroups()
            print("Group count: \(groups.count)")
        } catch {
            print(error.localizedDescription)
            XCTAssert(false)
        }
    }
}

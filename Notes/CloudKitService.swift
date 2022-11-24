//
//  CloudKitService.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 01/11/2022.
//

import Foundation
import CloudKit
import Combine

// swiftlint: disable switch_case_alignment
final class CloudKitService {

    func checkAccountStatus() async throws -> CKAccountStatus {
        try await CKContainer.default().accountStatus()
    }

    // MARK: Save

    func save(_ record: CKRecord) async throws {
        try await CKContainer.default().privateCloudDatabase.save(record)
    }

    // MARK: Fetch

    func fetchNotes(inGroup group: Group) async throws -> [Note] {
        let reference = CKRecord.Reference(record: group.record, action: .deleteSelf)
        let pred = NSPredicate(format: "\(NoteCKRecordKeys.group.rawValue) == %@", reference)
        let sort = NSSortDescriptor(key: NoteCKRecordKeys.title.rawValue, ascending: true)
        let query = CKQuery(recordType: NoteCKRecordKeys.type.rawValue, predicate: pred)
        query.sortDescriptors = [sort]

        var notes = [Note]()

        let records = try await CKContainer.default().privateCloudDatabase.records(matching: query)

        for (recordID, recordResult) in records.matchResults {
            switch recordResult {
                case .failure(let error):
                    throw error

                case .success(let record):
                    guard let note = Note(from: record, withGroup: group) else {
                        throw "Invalid note for ID: \(recordID)"
                    }

                    notes.append(note)
            }
        }

        return notes
    }

    func fetchGroups() async throws -> [Group] {
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: GroupCKRecordKeys.name.rawValue, ascending: true)
        let query = CKQuery(recordType: GroupCKRecordKeys.type.rawValue, predicate: pred)
        query.sortDescriptors = [sort]

        var groups = [Group]()

        let records = try await CKContainer.default().privateCloudDatabase.records(matching: query)

        for (recordID, recordResult) in records.matchResults {
            switch recordResult {
                case .failure(let error):
                    throw error

                case .success(let record):
                    guard let group = Group(from: record) else {
                        throw "Invalid group for ID: \(recordID)"
                    }

                    groups.append(group)
            }
        }

        return groups
    }

    // MARK: Delete

    func delete(_ record: CKRecord) async throws {
        _ = try await CKContainer.default().privateCloudDatabase.deleteRecord(withID: record.recordID)
    }
}

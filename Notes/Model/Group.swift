//
//  Group.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 21/08/2022.
//

import Foundation
import SwiftUI
import CloudKit

struct Group: Identifiable, Hashable {

    let id: UUID
    var name: String
    var color: Color

    init(id: UUID = UUID(), name: String, color: Color = .random) {
        self.id = id
        self.name = name
        self.color = color
    }

    private init(recordID: CKRecord.ID, name: String, color: Color) {
        self.id = UUID(uuidString: recordID.recordName)!
        self.name = name
        self.color = color
    }
}

// MARK: - CloudKit record extension

enum GroupCKRecordKeys: String {
    case type = "Group"
    case name
    case color
}

extension Group {

    // get the record stored in CloudKit
    var record: CKRecord {
        let record = CKRecord(
            recordType: GroupCKRecordKeys.type.rawValue,
            recordID: CKRecord.ID(recordName: id.uuidString)
        )

        record[GroupCKRecordKeys.name.rawValue] = name
        record[GroupCKRecordKeys.color.rawValue] = color.toHex()
        return record
    }
}

extension Group {

    // init from a record stored in CloudKit
    init?(from record: CKRecord) {
        guard
            let name = record[GroupCKRecordKeys.name.rawValue] as? String,
            let colorHex = record[GroupCKRecordKeys.color.rawValue] as? String
        else { return nil }

        self = .init(
            recordID: record.recordID,
            name: name,
            color: Color(hex: colorHex)!
        )
    }
}

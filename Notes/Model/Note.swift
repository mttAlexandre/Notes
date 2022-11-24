//
//  Note.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import Foundation
import SwiftUI
import CloudKit

struct Note: Identifiable, Hashable {

    let id: UUID
    // Foreign key to the related group
    var group: Group
    var title: String
    var titleColor: Color
    var content: String

    init(id: UUID = UUID(), group: Group, title: String, titleColor: Color = .random, content: String = "") {
        self.id = id
        self.group = group
        self.title = title
        self.titleColor = titleColor
        self.content = content
    }

    private init(recordID: CKRecord.ID, group: Group, title: String, titleColor: Color, content: String) {
        self.id = UUID(uuidString: recordID.recordName)!
        self.group = group
        self.title = title
        self.titleColor = titleColor
        self.content = content
    }
}

// MARK: - CloudKit record extension

enum NoteCKRecordKeys: String {
    case type = "Note"
    case group
    case title
    case titleColor
    case content
}

extension Note {

    // get the record stored in CloudKit
    var record: CKRecord {
        let record = CKRecord(
            recordType: NoteCKRecordKeys.type.rawValue,
            recordID: CKRecord.ID(recordName: id.uuidString)
        )

        record[NoteCKRecordKeys.group.rawValue] = CKRecord.Reference(record: group.record, action: .deleteSelf)
        record[NoteCKRecordKeys.title.rawValue] = title
        record[NoteCKRecordKeys.titleColor.rawValue] = titleColor.toHex() ?? ""
        record[NoteCKRecordKeys.content.rawValue] = content
        return record
    }
}

extension Note {

    // init from a record stored in CloudKit
    init?(from record: CKRecord, withGroup group: Group) {
        guard
            let title = record[NoteCKRecordKeys.title.rawValue] as? String,
            let titleColorHex = record[NoteCKRecordKeys.titleColor.rawValue] as? String,
            let content = record[NoteCKRecordKeys.content.rawValue] as? String
        else { return nil }

        self = .init(
            recordID: record.recordID,
            group: group,
            title: title,
            titleColor: Color(hex: titleColorHex)!,
            content: content
        )
    }
}

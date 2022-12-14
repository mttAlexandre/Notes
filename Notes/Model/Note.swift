//
//  Note.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import Foundation
import SwiftUI

struct Note: Identifiable, Hashable, Codable {

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
}

//
//  Group.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 21/08/2022.
//

import Foundation
import SwiftUI

struct Group: Identifiable, Hashable, Codable {

    let id: UUID
    var name: String
    var color: Color

    init(id: UUID = UUID(), name: String, color: Color = .random) {
        self.id = id
        self.name = name
        self.color = color
    }
}

//
//  Color+random.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 24/08/2022.
//

import Foundation
import SwiftUI

extension Color {

    // generate a random Color, opacity is always 1.0
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: 1.0
        )
    }
}

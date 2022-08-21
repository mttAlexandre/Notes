//
//  Model.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 21/08/2022.
//

import Foundation

final class Model {

#if DEBUG
    static let testGroups: [Group] = [
        Group(name: "🏠 Home"),
        Group(name: "📕 Recipes", color: .teal),
        Group(name: "💻 Work", color: .purple),
        Group(name: "🏖 Holidays", color: .mint)
    ]

    static let testNotes: [Note] = [
        Note(group: testGroups[1], title: "🍩 Donuts", titleColor: .pink,
             content: """
Ingredients :
    - eggs
    - sugar
    - flour
"""),
        Note(group: testGroups[1], title: "🍫 Chocolat cake", titleColor: .brown,
             content: """
Ingredients :
    - chocolat
    - eggs
    - sugar
    - flour
"""),
        Note(group: testGroups[0], title: "🪴 Garden", titleColor: .green, content: ""),
        Note(group: testGroups[2], title: "🚨 Deadlines", titleColor: .red, content: ""),
        Note(group: testGroups[2], title: "☑ Todo", titleColor: .indigo, content: ""),
        Note(group: testGroups[3], title: "🏔 Hikes", titleColor: .green, content: ""),
        Note(group: testGroups[3], title: "⛈ Indoor activities", titleColor: .blue, content: ""),
        Note(group: testGroups[3], title: "🧳 Bags", titleColor: .orange, content: "")
    ]
#endif

}

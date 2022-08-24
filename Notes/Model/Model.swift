//
//  Model.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 21/08/2022.
//

import Foundation

final class Model: ObservableObject {

    @Published var groups = [Group]()
    @Published var notes = [Note]()

    init() {
#if DEBUG
        generateSampleData()
        return
#endif
    }

// MARK: - DEBUG data

#if DEBUG
    private func generateSampleData() {
        groups = [
            Group(name: "🏠 Home"),
            Group(name: "📕 Recipes", color: .teal),
            Group(name: "💻 Work", color: .purple),
            Group(name: "🏖 Holidays", color: .mint)
        ]

        notes = [
            Note(group: groups[1], title: "🍩 Donuts", titleColor: .pink,
                 content: """
    Ingredients :
        - eggs
        - sugar
        - flour
    """),
            Note(group: groups[1], title: "🍫 Chocolat cake", titleColor: .brown,
                 content: """
    Ingredients :
        - chocolat
        - eggs
        - sugar
        - flour
    """),
            Note(group: groups[0], title: "🪴 Garden", titleColor: .green, content: ""),
            Note(group: groups[2], title: "🚨 Deadlines", titleColor: .red, content: ""),
            Note(group: groups[2], title: "☑ Todo", titleColor: .indigo, content: ""),
            Note(group: groups[3], title: "🏔 Hikes", titleColor: .green, content: ""),
            Note(group: groups[3], title: "⛈ Indoor activities", titleColor: .blue, content: ""),
            Note(group: groups[3], title: "🧳 Bags", titleColor: .orange, content: "")
        ]
    }
#endif
}

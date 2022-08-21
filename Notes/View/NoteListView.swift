//
//  NoteListView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

struct NoteListView: View {

    let notes: [Note]
    @Binding var selection: Note?

    private var sortedNotes: [Note] {
        notes.sorted {
            $0.title < $1.title
        }
    }

    var body: some View {
        List(sortedNotes, selection: $selection) { note in
            NavigationLink(value: note) {
                Text(note.title)
                    .bold()
                    .underline(selection == note, color: note.titleColor)
                    .foregroundColor(note.titleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background {
                        note.titleColor
                            .opacity(selection == note ? 0.05 : 0)
                            .cornerRadius(5)
                    }
            }
            .listRowBackground(
                note.titleColor
                    .opacity(0.1)
                    .cornerRadius(5)
            )
        }
        .listStyle(.sidebar)
        .cornerRadius(16)
        .navigationTitle(notes.first!.group.name)
    }
}

// MARK: - Preview

struct NoteListView_Previews: PreviewProvider {

    @State static var selection: Note? = Model.testNotes.first!

    static var previews: some View {
        NoteListView(notes: Model.testNotes, selection: $selection)
    }
}

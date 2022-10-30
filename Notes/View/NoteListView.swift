//
//  NoteListView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

struct NoteListView: View {

    @EnvironmentObject var model: Model

    let notes: [Note]
    @Binding var selection: Note?

    private var sortedNotes: [Note] {
        notes.sorted {
            $0.title < $1.title
        }
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(sortedNotes) { note in
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
                                .opacity(getBackgroundOpacity(note))
                                .cornerRadius(5)
                        }
                }
                .listRowBackground(
                    note.titleColor
                        .opacity(0.1)
                        .cornerRadius(5)
                )
                .contentShape(RoundedRectangle(cornerRadius: 5))
            }
            .onDelete(perform: delete)
        }
        .listStyle(.sidebar)
        .cornerRadius(16)
        .toolbar { EditButton() }
        .navigationTitle(notes.first?.group.name ?? "")
    }

    private func delete(at offsets: IndexSet) {
        do {
            let noteToDelete = sortedNotes[offsets[offsets.startIndex]]
            try model.deleteNote(noteToDelete)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func getBackgroundOpacity(_ note: Note) -> Double {
        selection == note ? 0.05 : 0
    }
}

// MARK: - Preview

struct NoteListView_Previews: PreviewProvider {

    @StateObject private static var model = Model()
    @State static var selection: Note?

    static var previews: some View {
        NoteListView(notes: model.notes, selection: $selection)
    }
}

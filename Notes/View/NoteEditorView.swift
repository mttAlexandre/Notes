//
//  NoteEditorView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

struct NoteEditorView: View {

    @Binding var note: Note

    @FocusState private var edit: Bool

    var body: some View {
        ScrollView {
            TextField("", text: $note.content, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .focused($edit)
                .onSubmit {
                    edit = false
                }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(note.title)
        .onTapGesture {
            edit.toggle()
        }
    }
}

// MARK: - Preview

struct NoteEditorView_Previews: PreviewProvider {

    @State private static var note = Model.testNotes.first!

    static var previews: some View {
        NoteEditorView(note: $note)
    }
}

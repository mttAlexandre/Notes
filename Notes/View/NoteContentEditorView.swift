//
//  NoteEditorView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

struct NoteContentEditorView: View {

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

struct NoteContentEditorView_Previews: PreviewProvider {

    @State private static var note = Model().notes.first!

    static var previews: some View {
        NoteContentEditorView(note: $note)
    }
}

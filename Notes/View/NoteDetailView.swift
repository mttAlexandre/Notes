//
//  NoteDetailView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 28/08/2022.
//

import SwiftUI

struct NoteDetailView: View {

    @Binding var note: Note

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NoteContentEditorView(note: $note)
                .tabItem {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                .tag(0)

            NotePreviewView(noteContent: note.content)
                .tabItem {
                    Label("View", systemImage: "note.text")
                }
                .tag(1)
        }
        .navigationTitle(note.title)
        .onAppear {
            selectedTab = note.content.isEmpty ? 0 : 1
        }
    }
}

// MARK: - Preview

struct NoteDetailView_Previews: PreviewProvider {

    @State private static var note = Model().notes.first!

    static var previews: some View {
        NoteDetailView(note: $note)
    }
}

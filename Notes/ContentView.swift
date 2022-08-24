//
//  ContentView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var model: Model

    @State private var selectedGroup: Group?
    @State private var selectedNote: Note?
    @State private var showNewNoteSheet = false

    private var notesToShow: [Note] {
        model.notes.filter {
            $0.group == selectedGroup
        }
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            GroupListView(groups: model.groups, selection: $selectedGroup)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        addNewButton
                    }
                }
        } content: {
            if selectedGroup != nil {
                NoteListView(notes: notesToShow, selection: $selectedNote)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            addNewButton
                        }
                    }
            } else {
                Text("Select a group")
            }
        } detail: {
            if selectedNote != nil {
                // Require a custom binding to bind a non optional Note to the NoteEditorView
                let noteBinding = Binding {
                    selectedNote ?? Note(group: Group(name: ""), title: "")
                } set: {
                    selectedNote = $0
                }

                NoteEditorView(note: noteBinding)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            addNewButton
                        }
                    }
            } else {
                Text("Select a note")
            }
        }
        .sheet(isPresented: $showNewNoteSheet) {
            NavigationStack {
                NewNoteView(group: selectedGroup)
            }
        }
    }

    private var addNewButton: some View {
        Button {
            showNewNoteSheet.toggle()
        } label: {
            Image(systemName: "plus")
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    @StateObject private static var model = Model()

    static var previews: some View {
        ContentView()
            .environmentObject(model)
    }
}

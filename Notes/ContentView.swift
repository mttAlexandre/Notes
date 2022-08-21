//
//  ContentView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

struct ContentView: View {

    var groups: [Group]
    var notes: [Note]

    @State private var selectedGroup: Group?
    @State private var selectedNote: Note?

    private var notesToShow: [Note] {
        notes.filter {
            $0.group == selectedGroup
        }
    }

    var body: some View {
        NavigationSplitView {
            GroupListView(groups: groups, selection: $selectedGroup)
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
                let noteBinding = Binding {
                    selectedNote ?? Note(group: Group(name: ""), title: "")
                } set: {
                    selectedNote = $0
                }

                NoteEditorView(note: noteBinding)
            } else {
                Text("Select a note")
            }
        }
    }
    
    private var addNewButton: some View {
        Button {
            
        } label: {
            Image(systemName: "plus")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(groups: Model.testGroups, notes: Model.testNotes)
    }
}

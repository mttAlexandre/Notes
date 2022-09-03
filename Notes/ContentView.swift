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
    @State private var editSheet = false

    private var selectedNoteIndex: Int {
        model.notes.firstIndex {
            $0.title == selectedNote?.title ?? ""
        }!
    }

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
                NoteDetailView(note: $model.notes[selectedNoteIndex])
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                editSheet.toggle()
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                    .sheet(isPresented: $editSheet) {
                        NavigationStack {
                            EditNoteView(noteToEdit: selectedNote,
                                         model: model,
                                         selectedGroup: $selectedGroup,
                                         selectedNote: $selectedNote)
                        }
                    }
            } else {
                Text("Select a note")
            }
        }
        .sheet(isPresented: $showNewNoteSheet) {
            NavigationStack {
                EditNoteView(model: model,
                             selectedGroup: $selectedGroup,
                             selectedNote: $selectedNote)
            }
        }
        .onAppear {
            do {
                try model.load()
            } catch {
                print(error.localizedDescription)
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

//
//  NewNoteView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 21/08/2022.
//

import SwiftUI

struct EditNoteView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var selectedGroup: Group?
    @Binding var selectedNote: Note?

    // error handling
    @State private var showGroupError = false
    @State private var showNoteError = false
    @State private var errorMessage = ""

    @StateObject private var viewModel: NewNoteViewModel

    init(noteToEdit: Note? = nil, model: Model, selectedGroup: Binding<Group?>, selectedNote: Binding<Note?>) {
        _selectedGroup = selectedGroup
        _selectedNote = selectedNote
        _viewModel = StateObject(wrappedValue:
                                    NewNoteViewModel(noteToEdit: noteToEdit,
                                                     model: model,
                                                     group: selectedGroup.wrappedValue)
        )
    }

    var body: some View {
        Form {
            Section("Group") {
                Toggle(isOn: $viewModel.createNewGroup) {
                    Text("Create new group")
                        .bold()
                }

                if viewModel.createNewGroup {
                    ColorPicker("Group color",
                                selection: $viewModel.newNote.group.color,
                                supportsOpacity: false)

                    TextField("Group name", text: $viewModel.newNote.group.name)
                    .textFieldStyle(.roundedBorder)

                    if showGroupError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .italic()
                            .bold()
                    }
                } else {
                    Picker("Choose a group", selection: $viewModel.newNote.group) {
                        ForEach(viewModel.model.groups) { group in
                            Text(group.name)
                                .tag(group)
                        }
                    }
                }
            }

            Section("Note") {
                ColorPicker("Note color",
                            selection: $viewModel.newNote.titleColor,
                            supportsOpacity: false)

                TextField("Note title", text: $viewModel.newNote.title)
                    .textFieldStyle(.roundedBorder)

                if showNoteError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .italic()
                        .bold()
                }
            }
        }
        .navigationTitle("Add note")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    do {
                        try viewModel.save()
                        dismiss()
                    } catch SaveError.groupError(let message) {
                        errorMessage = message
                        showGroupError = true
                    } catch SaveError.noteError(let message) {
                        errorMessage = message
                        showNoteError = true
                    } catch {
                        return
                    }
                } label: {
                    Text("Done")
                        .bold()
                }
            }
        }
        .onAppear {
            viewModel.didFinishSaving = navigateToNewNote
        }
    }

    private func navigateToNewNote(_ note: Note) {
        DispatchQueue.main.async {
            self.selectedGroup = viewModel.newNote.group
            self.selectedNote = viewModel.newNote
        }
    }
}

// MARK: - Preview

 struct EditNoteView_Previews: PreviewProvider {

     @State static var model = Model()
     @State static var selectedNote: Note?
     @State static var selectedGroup: Group? = Model().groups.first

    static var previews: some View {
        NavigationStack {
            EditNoteView(model: model, selectedGroup: $selectedGroup, selectedNote: $selectedNote)
        }
    }
 }

// MARK: - View Model

enum SaveError: Error {
    case groupError(String)
    case noteError(String)
    case none
}

private final class NewNoteViewModel: ObservableObject {

    @Published var newNote: Note
    @Published var createNewGroup: Bool
    @Published var model: Model
    var didFinishSaving: (Note) -> Void = { _ in return }

    init(noteToEdit: Note? = nil, model: Model, group: Group?) {
        self.model = model
        self.newNote = noteToEdit ?? Note(
            group: group ?? Group(name: ""),
            title: ""
        )
        self.createNewGroup = group == nil
    }

    func save() throws {
        if createNewGroup {
            if newNote.group.name.isEmpty {
                throw SaveError.groupError("Group name cannot be empty")
            }

            let existingGroupName = model.groups.map { $0.name }

            if existingGroupName.contains(newNote.group.name) {
                throw SaveError.groupError("A group with this name already exists")
            }
        }

        if !createNewGroup {
            let existingNoteTitleForGroup = model.notes.compactMap {
                $0.group == newNote.group ? $0.title : nil
            }

            if existingNoteTitleForGroup.contains(newNote.title) {
                throw SaveError.noteError("A note with this name already exists")
            }
        }

        if newNote.title.isEmpty {
            throw SaveError.noteError("A note with this title already exists")
        }

        if createNewGroup {
            model.groups.append(newNote.group)
        }

        // edit an existing note
        if let index = model.notes.firstIndex(where: {
            $0.id == newNote.id
        }) {
            model.notes[index] = newNote
        }
        // create a note
        else {
            model.notes.append(newNote)
        }

        didFinishSaving(newNote)
    }
}

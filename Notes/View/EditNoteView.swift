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
                .onChange(of: viewModel.createNewGroup) {
                    if $0 {
                        viewModel.note.group = Group(name: "")
                    } else {
                        viewModel.note.group = selectedGroup ?? Group(name: "")
                    }
                }

                if viewModel.createNewGroup {
                    ColorPicker("Group color",
                                selection: $viewModel.note.group.color,
                                supportsOpacity: false)

                    TextField("Group name", text: $viewModel.note.group.name)
                    .textFieldStyle(.roundedBorder)

                    if showGroupError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .italic()
                            .bold()
                    }
                } else {
                    Picker("Choose a group", selection: $viewModel.note.group) {
                        ForEach(viewModel.model.groups) { group in
                            Text(group.name)
                                .tag(group)
                        }
                    }
                }
            }

            Section("Note") {
                ColorPicker("Note color",
                            selection: $viewModel.note.titleColor,
                            supportsOpacity: false)

                TextField("Note title", text: $viewModel.note.title)
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
                    } catch ModelError.groupError(let message) {
                        errorMessage = message
                        showGroupError = true
                    } catch ModelError.noteError(let message) {
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
            self.selectedGroup = viewModel.note.group
            self.selectedNote = viewModel.note
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

private final class NewNoteViewModel: ObservableObject {

    @Published var note: Note
    @Published var createNewGroup: Bool
    @Published var model: Model
    var didFinishSaving: (Note) -> Void = { _ in return }
    private let newNote: Bool

    init(noteToEdit: Note? = nil, model: Model, group: Group?) {
        self.newNote = noteToEdit == nil
        self.model = model
        self.note = noteToEdit ?? Note(
            group: group ?? Group(name: ""),
            title: ""
        )
        self.createNewGroup = group == nil
    }

    func save() throws {
        if newNote {
            try model.addNote(note)
        } else {
            try model.modifyNote(note)
        }

        didFinishSaving(note)
    }
}

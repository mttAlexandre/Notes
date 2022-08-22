//
//  NewNoteView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 21/08/2022.
//

import SwiftUI

struct NewNoteView: View {

    @Environment(\.dismiss) private var dismiss

    // error handling
    @State private var showGroupError = false
    @State private var showNoteError = false
    @State private var errorMessage = ""

    @StateObject private var viewModel: NewNoteViewModel
    @State private var newGroup = false

    init(group: Group?) {
        _viewModel = StateObject(wrappedValue: NewNoteViewModel(model: Model(), group: group))
        _newGroup = State(initialValue: group == nil)
    }

    var body: some View {
        Form {
            Section("Group") {
                Toggle(isOn: $newGroup) {
                    Text("Create new group")
                        .bold()
                }

                if newGroup {
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
                        ForEach(Model.testGroups) { group in
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
                        try viewModel.saveNewNote()
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
    }
}

// MARK: - Preview

struct NewNoteView_Previews: PreviewProvider {
    static let group = Model.testGroups.first

    static var previews: some View {
        NavigationStack {
            NewNoteView(group: group)
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
    var model: Model

    init(model: Model, group: Group?) {
        self.model = model
        self.newNote = Note(group: group ?? Group(name: ""), title: "")
    }

    func saveNewNote() throws {
        // TODO: save note
//        throw SaveError.groupError("A group with this name already exists")
        throw SaveError.noteError("A note with this title already exists")
    }
}

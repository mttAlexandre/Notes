//
//  NotePreviewView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 28/08/2022.
//

import SwiftUI

struct NotePreviewView: View {

    var noteContent: String

    var body: some View {
        ScrollView {
            Text(LocalizedStringKey(noteContent))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding()
        }
    }
}

// MARK: - Preview

struct NotePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NotePreviewView(noteContent: "Hello :D")
    }
}

//
//  NotePreviewView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 28/08/2022.
//

import SwiftUI
import MarkdownUI

struct NotePreviewView: View {

    var noteContent: String
    var noteColor: Color

    var body: some View {
        ScrollView {
            Markdown(noteContent)
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .leading)
                .padding()
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(noteColor, lineWidth: 2)
        }
        .padding()
    }
}

// MARK: - Preview

struct NotePreviewView_Previews: PreviewProvider {
    static let content = #"""
# Title
## Subtitle
### Sub-subtitle
**bold**

*italic*

[link](https://github.com/gonzalezreal/MarkdownUI)

`var success = true`

---

1. First
    - a
    - b
2. Second
    - c

"""#

    static var previews: some View {
        NotePreviewView(noteContent: content, noteColor: .red)

        Markdown(content)
    }
}

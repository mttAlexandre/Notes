//
//  GroupListView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

struct GroupListView: View {

    let groups: [Group]
    @Binding var selection: Group?

    private var sortedGroups: [Group] {
        groups.sorted {
            $0.name < $1.name
        }
    }

    var body: some View {
        List(sortedGroups, selection: $selection) { group in
            NavigationLink(value: group) {
                Text(group.name)
                    .bold()
                    .underline(selection == group, color: group.color)
                    .foregroundColor(group.color)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background {
                        group.color
                            .opacity(selection == group ? 0.05 : 0)
                            .cornerRadius(5)
                    }
            }
            .listRowBackground(
                group.color
                    .opacity(0.1)
                    .cornerRadius(5)
            )
        }
        .navigationTitle("Notes 📝")
    }
}

// MARK: - Preview

struct GroupListView_Previews: PreviewProvider {

    @State static var selection: Group?

    static var previews: some View {
        GroupListView(groups: Model.testGroups, selection: $selection)
    }
}

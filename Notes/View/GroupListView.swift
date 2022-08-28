//
//  GroupListView.swift
//  Notes
//
//  Created by Alexandre MONTCUIT on 20/08/2022.
//

import SwiftUI

struct GroupListView: View {

    @EnvironmentObject var model: Model

    let groups: [Group]
    @Binding var selection: Group?

    private var sortedGroups: [Group] {
        groups.sorted {
            $0.name < $1.name
        }
    }

    var body: some View {
        List {
            ForEach(sortedGroups) { group in
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
                                .opacity(getBackgroundOpacity(group))
                                .cornerRadius(5)
                        }
                }
                .listRowBackground(
                    group.color
                        .opacity(0.1)
                        .cornerRadius(5)
                )
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .onTapGesture {
                    selection = group
                }
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Notes 📝")
    }

    private func delete(at offsets: IndexSet) {
        let groupToDelete = sortedGroups[offsets[offsets.startIndex]]
        // delete all notes in this group
        model.notes.removeAll {
            $0.group == groupToDelete
        }
        // delete the group itself
        model.groups.removeAll {
            $0 == groupToDelete
        }
    }

    private func getBackgroundOpacity(_ group: Group) -> Double {
        selection == group ? 0.05 : 0
    }
}

// MARK: - Preview

struct GroupListView_Previews: PreviewProvider {

    @State static var selection: Group?

    static var previews: some View {
        GroupListView(groups: Model().groups, selection: $selection)
    }
}

//
//  TodoItemCellView.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 15.09.24.
//

import Foundation
import SwiftUI


struct TodoItemCellView : TodoListView {
    @ObservedObject var vm : TodoListMainViewModel
    let item : TodoItemViewData
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(verbatim: item.title)
                        .font(.system(size: 17,weight: .medium))
                        .strikethrough(item.isCompleted)
                    Text(verbatim: item.description)
                        .font(.system(size: 12,weight: .medium))
                        .foregroundStyle(.secondary)
                    Divider()
                }
                Button(action: {
                    vm.send(
                        event: .didRequestEditTodoItem(
                            action: .updating(
                                id: item.id,
                                data: TodoItemViewData(old: item, isCompleted: !item.isCompleted)
                            )
                        )
                    )
                }, label: {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22,weight: .medium))
                })
            }
        }
    }
}

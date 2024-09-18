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
                        .strikethrough(item.isCompleted)
                        .textSize(.big)
                    if !item.description.isEmpty {
                        Text(verbatim: item.description)
                            .textSize(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
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
            if item.todoDate.startDate != nil {
                Divider()
                item.todoDate.todoItemCellDateFooterData()
            }
        }
    }
}

extension TodoItemViewData.TodoItemDate {
    @ViewBuilder func todoItemCellDateFooterData() -> some View {
        let dayFormatter =  {
           let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter
        }()
        HStack(spacing : 5) {
            switch self {
                case .empty:
                    EmptyView()
                case .date(let date):
                    Group {
                        if self.isToday == true {
                            Text(verbatim: "Today")
                        } else {
                            Text(verbatim: dayFormatter.string(from: date))
                        }
                    }
                    .foregroundStyle(.secondary)
                    Text(date, style: .time)
                        .foregroundStyle(.secondary.opacity(0.6))
                case .range(let start, let end):
                    if self.startAndEndAreTheSameDay == true {
                        Group {
                            if self.isToday == true {
                                Text(verbatim: "Today")
                            } else {
                                Text(verbatim: dayFormatter.string(from: start))
                            }
                        }
                        .foregroundStyle(.secondary)
                        Text(start, style: .time)
                            .foregroundStyle(.secondary.opacity(0.6))
                        Text("-")
                            .foregroundStyle(.secondary.opacity(0.6))
                        Text(end, style: .time)
                            .foregroundStyle(.secondary.opacity(0.6))
                    } else {
                        Text(verbatim: dayFormatter.string(from: start))
                            .foregroundStyle(.secondary)
                        Text(start, style: .time)
                            .foregroundStyle(.secondary.opacity(0.6))
                        Text("-")
                            .foregroundStyle(.secondary.opacity(0.6))
                        Text(verbatim: dayFormatter.string(from: end))
                            .foregroundStyle(.secondary)
                        Text(end, style: .time)
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
            }
            Spacer()
        }
        .textSize(.medium)
    }
}


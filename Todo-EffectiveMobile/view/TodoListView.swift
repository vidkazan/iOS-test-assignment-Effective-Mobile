//
//  TodoListView.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 14.09.24.
//

import Foundation
import SwiftUI

struct TodoListMainView : TodoListView {
    @ObservedObject var vm : TodoListMainViewModel = .init(coreDataStore: .init())
    @State var filterState : FilterState = .All
    var body: some View {
        VStack {
            header()
            filter()
            list()
        }
        .padding()
    }
}


extension TodoListMainView {
    enum FilterState : String, CaseIterable {
        case All
        case Open
        case Closed
        
        func todoItemsCount(items : [TodoItemViewData]) -> Int {
            switch self {
                case .All:
                    items.count
                case .Open:
                    items.filter({$0.isCompleted == false}).count
                case .Closed:
                    items.filter({$0.isCompleted == true}).count
            }
        }
    }
}

private extension TodoListMainView {
    func list() -> some View {
        ScrollView {
            LazyVStack {
                ForEach(vm.state.todoItems.sorted(by: {
                    $0.creationDate > $1.creationDate
                }),id:\.creationDate) {
                    TodoItemCellView(vm: vm, item: $0)
                        .padding()
                        .background(.secondary.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
    }
}

private extension TodoListMainView {
    func header() -> some View {
        HStack {
            VStack(alignment: .leading){
                Text("Today's Task",comment: "TodoListMainView: Header")
                    .font(.system(size: 22,weight: .bold))
                Text(.now, style: .date)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            Spacer()
            Button(action: {
                vm.send(event: .didRequestEditTodoItem(action: .adding(data: .init(
                    id: .init(),
                    title: "Title",
                    description: "Description",
                    creationDate: .now,
                    todoDateStart: .now + 3000,
                    todoDateEnd: .now + 6000,
                    isCompleted: false
                ))))
            }, label: {
                Label("New Task", systemImage: "plus")
                    .font(.system(size: 15,weight: .medium))
                    .padding(.horizontal,10)
                    .padding(10)
                    .foregroundStyle(.blue)
                    .background(.blue.opacity(0.15),
                       in: RoundedRectangle(cornerRadius: 10))
            })
        }
    }
}

private extension TodoListMainView {
    func filter() -> some View {
        HStack(spacing: 15) {
            ForEach(Self.FilterState.allCases, id: \.rawValue) { filterCase in
                Button(action: {
                    self.filterState = filterCase
                }, label: {
                    HStack(spacing: 5) {
                        Text(filterCase.rawValue)
                            .font(.system(size: 15,weight: self.filterState == filterCase ? .semibold : .medium))
                            .foregroundStyle(self.filterState == filterCase ? .blue : .secondary)
                        Text(verbatim: "\(filterCase.todoItemsCount(items: vm.state.todoItems))")
                            .padding(.horizontal,2)
                            .padding(1)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .background(self.filterState == filterCase ? .blue : .secondary)
                            .cornerRadius(10)
                    }
                    if filterCase == .All {
                        Divider()
                            .frame(height: 30)
                    }
                })
                .frame(minHeight: 43)
            }
            Spacer()
        }
    }
}

#Preview {
    TodoListMainView(vm: .init(coreDataStore: .preview))
}

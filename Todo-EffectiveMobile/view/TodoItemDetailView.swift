//
//  TodoItemDetailView.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 15.09.24.
//

import Foundation
import SwiftUI

struct TodoItemDetailView : View {
    let vm : TodoListMainViewModel
    let closeAction : () -> ()
    let mode : Mode
    
    @FocusState var focus : Self.Focus?
    @State var title : String
    @State var description : String
    @State var startDate : Date
    @State var endDate : Date
    @State var pickerState : Self.DatePickerState
    
    init(vm: TodoListMainViewModel, mode: Mode,closeAction : @escaping ()->()) {
        let item = mode.todoViewData()
        self.mode = mode
        self.vm = vm
        self.title = item.title
        self.description = item.description
        self.closeAction = closeAction
        self.startDate = item.todoDateStart ?? .now
        self.endDate = item.todoDateEnd ?? .now + 3600
        self.pickerState = {
            if item.todoDateStart != nil {
                if item.todoDateEnd != nil {
                    return .all
                }
                return .startDate
            }
            return .empty
        }()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    TextField("", text: .init(get: {
                        title
                    }, set: {
                        title = $0
                    }))
                    .focused($focus, equals: .title)
                    TextField("description", text: .init(get: {
                        description
                    }, set: {
                        description = $0
                    }))
                    .focused($focus, equals: .description)
                }, header: {})
                Section {
                    Toggle(isOn: .init(
                        get: {
                            self.pickerState != .empty
                        },
                        set: {
                            if $0 == true {
                                self.pickerState = .startDate
                            } else {
                                self.pickerState = .empty
                            }
                        }
                    ), label: {
                        Label(title: {
                            Text("Start date", comment: "TodoItemDetailView: section name")
                        }, icon: {
                            Image(systemName: "calendar.badge.clock")
                        })
                    })
                    .focused($focus, equals: .startDate)
                    if self.pickerState != .empty {
                        DatePicker(
                            selection: $startDate,
                            in: ...(endDate),
                            label: {}
                        )
                    }
                }
                Section {
                    Toggle(isOn: .init(
                        get: {
                            self.pickerState == .all
                        },
                        set: {
                            if $0 == true {
                                self.pickerState = .all
                            } else {
                                self.pickerState = .startDate
                            }
                        }
                    ), label: {
                        Label(title: {
                            Text("End date", comment: "TodoItemDetailView: section name")
                        }, icon: {
                            Image(systemName: "calendar.badge.clock")
                        })
                    })
                    if case .all = self.pickerState {
                        DatePicker(
                            selection: $endDate,
                            in: (startDate)...,
                            label: {}
                        )
                    }
                }
                .disabled(self.pickerState == DatePickerState.empty)
            }
            .onSubmit {
                if case .description = self.focus {
                    self.pickerState = .startDate
                }
                self.focus = self.focus?.next()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Button(action: closeAction, label: {
                        Text(
                            "Close",
                             comment: "SheetView: toolbar: button name"
                        )
                    })
                })
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                        switch mode {
                            case .create:
                                vm.send(
                                    event: .didRequestEditTodoItem(
                                        action: .adding(
                                            data: .init(
                                                id: .init(),
                                                title: self.title,
                                                description: self.description,
                                                creationDate: .now,
                                                todoDateStart: self.pickerState != .empty ? self.startDate : nil,
                                                todoDateEnd: self.pickerState == .all ? self.endDate : nil,
                                                isCompleted: false
                                            )
                                        )
                                    )
                                )
                            case .edit(let item):
                                vm.send(
                                    event: .didRequestEditTodoItem(
                                        action: .updating(id: item.id, data: .init(
                                            id: item.id,
                                            title: self.title,
                                            description: self.description,
                                            creationDate: item.creationDate,
                                            todoDateStart: self.pickerState != .empty ? self.startDate : nil,
                                            todoDateEnd: self.pickerState == .all ? self.endDate : nil,
                                            isCompleted: item.isCompleted
                                        ))
                                    )
                                )
                        }
                        closeAction()
                    }, label: {
                        Text(
                            "Save",
                            comment: "SheetView: toolbar: button name"
                        )
                    })
                })
            }
        }
    }
}

extension TodoItemDetailView {
    enum Mode {
        case create
        case edit(item : TodoItemViewData)
        
        func todoViewData() -> TodoItemViewData  {
            switch self {
                case .create:
                    return TodoItemViewData.defaultItem
                case .edit(let item):
                    return item
            }
        }
    }
}

extension TodoItemDetailView.Mode : Identifiable {
    var id: UUID {
        .init()
    }
}

extension TodoItemDetailView {
    enum DatePickerState {
        case empty
        case startDate
        case all
    }
    enum Focus : CaseIterable {
        case title
        case description
        case startDate
        case endDate
    }
}

//
//  TodoListViewData.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation

struct TodoItemViewData : Hashable {
    enum TodoItemDate : Hashable {
        case empty
        case date(Date)
        case range(start : Date, end : Date)
        
        init(start : Date?, end : Date?) {
            if let start = start {
                if let end = end {
                    self = .range(start: start, end: end)
                }
                self = .date(start)
            } else {
                self = .empty
            }
        }
        
        var isToday : Bool {
            switch self {
                case .empty:
                   return true
                case .date(let date):
                    return Calendar.current.isDateInToday(date)
                case .range(let start, let end):
                    return Calendar.current.isDateInToday(start) || Calendar.current.isDateInToday(end)
            }
        }
    }
    
    static let defaultItem = Self.init(
        id: .init(),
        title: "New Todo",
        description: "",
        creationDate: .now,
        todoDateStart: nil,
        todoDateEnd: nil,
        isCompleted: false
    )
    
    let id : UUID
    let title : String
    let description : String
    let creationDate : Date
    let todoDateStart : Date?
    let todoDateEnd : Date?
    let todoDate : Self.TodoItemDate
    let isCompleted : Bool
    
    init(id : UUID, title: String, description: String, creationDate: Date, todoDateStart: Date?, todoDateEnd: Date?, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.creationDate = creationDate
        self.todoDateStart = todoDateStart
        self.todoDateEnd = todoDateEnd
        self.isCompleted = isCompleted
        self.todoDate = .init(start: todoDateStart, end: todoDateEnd)
    }
}

extension TodoItemViewData : Identifiable {
    init(old : Self,isCompleted: Bool) {
        self.id = old.id
        self.title = old.title
        self.description = old.description
        self.creationDate = old.creationDate
        self.todoDateStart = old.todoDateStart
        self.todoDateEnd = old.todoDateEnd
        self.isCompleted = isCompleted
        self.todoDate = old.todoDate
    }
}

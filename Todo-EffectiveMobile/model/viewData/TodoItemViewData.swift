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
                    return
                }
                self = .date(start)
                return
            } else {
                self = .empty
                return
            }
        }
        
        var isToday : Bool? {
            switch self {
                case .empty:
                   return nil
                case .date(let date):
                    return Calendar.current.isDateInToday(date)
                case .range(let start, let end):
                    return Calendar.current.isDateInToday(start) || Calendar.current.isDateInToday(end)
            }
        }
        
        var startAndEndAreTheSameDay : Bool? {
            switch self {
                case .empty:
                   return nil
                case .date:
                    return nil
                case .range(let start, let end):
                    return Calendar.current.component(.day, from: start) == Calendar.current.component(.day, from: end)
            }
        }
        
        var startDate : Date? {
            switch self {
                case .empty:
                    nil
                case .date(let date):
                    date
                case .range(let start, _):
                    start
            }
        }
        
        var endDate : Date? {
            switch self {
                case .empty:
                    nil
                case .date:
                    nil
                case .range(_, let end):
                    end
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
    let todoDate : Self.TodoItemDate
    let isCompleted : Bool
    
    init(id : UUID, title: String, description: String, creationDate: Date, todoDateStart: Date?, todoDateEnd: Date?, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.creationDate = creationDate
        self.isCompleted = isCompleted
        self.todoDate = .init(start: todoDateStart, end: todoDateEnd)
    }
    
    init(old : Self,isCompleted: Bool) {
        self.id = old.id
        self.title = old.title
        self.description = old.description
        self.creationDate = old.creationDate
        self.isCompleted = isCompleted
        self.todoDate = old.todoDate
    }
}

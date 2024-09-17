//
//  TodoListViewData.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation

struct TodoItemViewData : Hashable {
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
    let isCompleted : Bool
    
    init(id : UUID, title: String, description: String, creationDate: Date, todoDateStart: Date?, todoDateEnd: Date?, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.creationDate = creationDate
        self.todoDateStart = todoDateStart
        self.todoDateEnd = todoDateEnd
        self.isCompleted = isCompleted
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
    }
}

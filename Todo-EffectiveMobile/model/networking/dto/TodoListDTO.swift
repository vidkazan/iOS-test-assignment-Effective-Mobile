//
//  TodoListDTO.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation

struct TodoListDTO : Codable {
    var todos : [TodoItemDTO]
}

struct TodoItemDTO : Codable {
    var todo : String?
    var completed : Bool?
}

extension TodoListDTO {
    func viewData() -> [TodoItemViewData] {
        self.todos.compactMap {
            guard let title = $0.todo,
                  let isCompleted = $0.completed
            else {
                return nil
            }
            return .init(
                id: .init(),
                title: title,
                description: "",
                creationDate: .now,
                todoDateStart: nil,
                todoDateEnd: nil,
                isCompleted: isCompleted
            )
        }
    }
}

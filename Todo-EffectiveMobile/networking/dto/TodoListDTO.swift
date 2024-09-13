//
//  TodoListDTO.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation

struct TodoListDTO : Codable {
    var todos : TodoItemDTO
}

struct TodoItemDTO : Codable {
    var id : Int?
    var todo : String?
    var completed : Bool?
}

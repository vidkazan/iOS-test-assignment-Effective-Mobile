//
//  TodoListViewData.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation

struct TodoItemViewData : Hashable {
    let id : Int
    let title : String
    let description : String
    let creationDate : Date
    let todoDateStart : Date?
    let todoDateEnd : Date?
    let isCompleted : Bool
}

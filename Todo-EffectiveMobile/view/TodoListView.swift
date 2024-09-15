//
//  TodoListView.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 14.09.24.
//

import Foundation
import SwiftUI

struct TodoListMainView : View {
    @ObservedObject var vm : TodoListMainViewModel = .init(coreDataStore: .init())
    
    var body: some View {
        VStack {
            Text(verbatim: vm.state.status.description)
            List(vm.state.todoItems,id:\.id) {
                Text(verbatim: $0.title)
                Text(verbatim: $0.description)
            }
            Spacer()
            Button(action: {
                vm.send(event: .didRequestEditTodoItem(action: .adding(data: .init(
                    id: UUID().hashValue,
                    title: "title",
                    description: "description",
                    creationDate: .now,
                    todoDateStart: .now + 3000,
                    todoDateEnd: .now + 6000,
                    isCompleted: false
                ))))
            }, label: {
                Text(verbatim: "add")
            })
        }
    }
}

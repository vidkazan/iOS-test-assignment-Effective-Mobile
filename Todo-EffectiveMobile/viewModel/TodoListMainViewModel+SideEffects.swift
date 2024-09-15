//
//  TodoListMainViewModel+SideEffects.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation
import Combine
import OSLog

extension TodoListMainViewModel {
    static func whenStart(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
        Feedback {  (state: State) -> AnyPublisher<Event, Never> in
            guard case .start = state.status else {
                return Empty().eraseToAnyPublisher()
            }
            return Just(Event.didStart).eraseToAnyPublisher()
        }
    }
    
    static func whenLoadingFromDB(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
        Feedback {  (state: State) -> AnyPublisher<Event, Never> in
            guard case .loadingFromDB = state.status else {
                return Empty().eraseToAnyPublisher()
            }
            guard coreDataStore.fetchUser() != nil else {
                Logger.loadingsInitialData.info("\(#function): user is nil: loading default data")
                return Just(Event.didLoadInitialData(items: []))
                    .eraseToAnyPublisher()
            }
            guard let items = coreDataStore.fetchTodoItems() else {
                Logger.loadingsInitialData.info("\(#function): user is nil: loading default data")
                return Just(Event.didLoadInitialData(items: []))
                    .eraseToAnyPublisher()
            }
            return Just(Event.didLoadInitialData(items: items)).eraseToAnyPublisher()
        }
    }
    
    static func whenEditing(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
        Feedback {  (state: State) -> AnyPublisher<Event, Never> in
            guard case let .editing(action) = state.status else {
                return Empty().eraseToAnyPublisher()
            }

            var items = state.todoItems
            switch action {
            case let .updating(id, data):
                guard let index = items.firstIndex(where: { $0.id == id} ) else {
                    return Just(Event.didFailToEditTodoItem(action: action))
                        .eraseToAnyPublisher()
                }
                guard coreDataStore.updateTodoItem(id: id, viewData: data) == true else {
                    return Just(Event.didFailToEditTodoItem(action: action))
                        .eraseToAnyPublisher()
                }
                items.remove(at: index)
                items.append(data)
                return Just(
                    Event.didEditTodoItem(action: action,items: items)
                )
                .eraseToAnyPublisher()
            case .adding(let viewData):
                guard !items.contains(where: {$0.id == viewData.id}) else {
                    return Just(Event.didFailToEditTodoItem(action: action))
                        .eraseToAnyPublisher()
                }
                guard
                    coreDataStore.addTodoItem(
                        todoItem: viewData
                    ) == true
                else {
                    return Just(Event.didFailToEditTodoItem(action: action))
                        .eraseToAnyPublisher()
                }
                items.append(viewData)
                return Just(Event.didEditTodoItem(action: action, items: items))
                    .eraseToAnyPublisher()
            case .deleting(let id):
                guard let index = items.firstIndex(where: { $0.id == id} ) else {
                    return Just(Event.didFailToEditTodoItem(action: action))
                        .eraseToAnyPublisher()
                }
                    guard coreDataStore.deleteTodoItemIfFound(id: id) == true else {
                    return Just(Event.didFailToEditTodoItem(action: action))
                        .eraseToAnyPublisher()
                }
                items.remove(at: index)
                return Just(
                    Event.didEditTodoItem(action: action,items: items)
                )
                .eraseToAnyPublisher()
            }
        }
    }
}

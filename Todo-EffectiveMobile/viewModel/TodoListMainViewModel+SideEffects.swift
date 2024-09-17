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
    
    static func whenValidatingAPICallIfNeeded(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
        Feedback {  (state: State) -> AnyPublisher<Event, Never> in
            guard case .validatingIfLoadedFromAPI = state.status else {
                return Empty().eraseToAnyPublisher()
            }
            if state.didLoadFromAPI {
                return Just(Event.didCancelledLoadingFromAPI).eraseToAnyPublisher()
            } else {
                return Just(Event.didRequestTodoListFromAPI).eraseToAnyPublisher()
            }
        }
    }
    
    static func whenLoadingFromAPI(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
        Feedback {  (state: State) -> AnyPublisher<Event, Never> in
            guard case .loadingFromAPI = state.status else {
                return Empty().eraseToAnyPublisher()
            }
            return ApiService(client: ApiClient()).fetch(TodoListDTO.self, type: .todoList)
            .map {
                coreDataStore.updateUser(didLoadFromAPI: true)
                return Event.didLoadFromAPI(items: $0.viewData())
            }
            .catch {
               return Just(Event.didFailToLoadFromAPI(error: $0))
            }
            .eraseToAnyPublisher()
        }
    }
    
    static func whenLoadingFromDB(coreDataStore : CoreDataStore) -> Feedback<State, Event> {
        Feedback {  (state: State) -> AnyPublisher<Event, Never> in
            guard case .loadingFromDB = state.status else {
                return Empty().eraseToAnyPublisher()
            }
            guard let didLoadFromAPI = coreDataStore.didLoadFromAPI() else {
                Logger.loadingsInitialData.info("\(#function): user is nil: loading default data")
                return Just(Event.didLoadInitialData(items: [], didLoadFromAPI: false))
                    .eraseToAnyPublisher()
            }
            guard let items = coreDataStore.fetchTodoItems() else {
                Logger.loadingsInitialData.info("\(#function): failed to fetch todoItems")
                return Just(Event.didLoadInitialData(items: [], didLoadFromAPI: didLoadFromAPI))
                    .eraseToAnyPublisher()
            }
            return Just(Event.didLoadInitialData(items: items, didLoadFromAPI: didLoadFromAPI)).eraseToAnyPublisher()
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
                    return Just(Event.didFailToEditTodoItem(action: action, error: .generic(description: "failed to update todo: todo not found")))
                        .eraseToAnyPublisher()
                }
                guard coreDataStore.updateTodoItem(id: id, viewData: data) == true else {
                    return Just(Event.didFailToEditTodoItem(action: action, error: .generic(description: "failed to update todo")))
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
                    return Just(Event.didFailToEditTodoItem(action: action,error: .generic(description: "failed to add todo: this todo is already present")))
                        .eraseToAnyPublisher()
                }
                guard
                    coreDataStore.addTodoItem(todoItem: viewData) == true
                else {
                    return Just(Event.didFailToEditTodoItem(action: action, error: .generic(description: "failed to add todo")))
                        .eraseToAnyPublisher()
                }
                items.append(viewData)
                return Just(Event.didEditTodoItem(action: action, items: items))
                    .eraseToAnyPublisher()
            case .deleting(let id):
                guard let index = items.firstIndex(where: { $0.id == id} ) else {
                    return Just(Event.didFailToEditTodoItem(action: action,error: .generic(description: "failed to delete todo: this todo is not found")))
                        .eraseToAnyPublisher()
                }
                    guard coreDataStore.deleteTodoItemIfFound(id: id) == true else {
                    return Just(Event.didFailToEditTodoItem(action: action,error: .generic(description: "failed to delete todo")))
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

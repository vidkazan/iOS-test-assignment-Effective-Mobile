//
//  TodoListViewModel.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation
import Combine
import OSLog

class TodoListMainViewModel : TodoListViewModel {
    @Published private(set) var state : State {
        didSet {
            Self.log(state.status)
            Self.warning(state.status, ">>> \(state.todoItems.count)")
        }
    }

    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event,Never>()
    
    init(_ initaialStatus : Status = .start,coreDataStore : CoreDataStore) {
        self.state = State(
            status: initaialStatus,
            todoItems: []
        )
        Publishers.system(
            initial: state,
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                Self.userInput(input: input.eraseToAnyPublisher()),
                Self.whenEditing(coreDataStore: coreDataStore),
                Self.whenStart(coreDataStore: coreDataStore),
                Self.whenLoadingFromDB(coreDataStore: coreDataStore)
            ]
        )
        .assign(to: \.state, on: self)
        .store(in: &bag)
    }
    
    deinit {
        bag.removeAll()
    }

    func send(event: Event) {
        input.send(event)
    }
}

extension TodoListMainViewModel  {
    struct State : Equatable {
        let status : Status
        let todoItems : [TodoItemViewData]

        init(status: Status, todoItems : [TodoItemViewData]) {
            self.status = status
            self.todoItems = todoItems
        }
    }
    
    enum Status : TodoListStatus {
        var description: String {
            switch self {
                case .start:
                    "start"
                case .idle:
                    "idle"
                case .loadingFromAPI:
                    "loadingFromAPI"
                case .loadingFromDB:
                    "loadingFromDB"
                case .editing:
                    "editing"
                case .error:
                    "error"
            }
        }
        
        case start
        case idle
        case loadingFromAPI
        case loadingFromDB
        case editing(action : Action)
        case error
    }
    
    
    enum Action {
        case adding(data : TodoItemViewData)
        case deleting(id : Int)
        case updating(id : Int, data : TodoItemViewData)
    }

    enum Event : TodoListEvent {
        case didStart
        case didLoadInitialData(items : [TodoItemViewData])
        case didFailToLoadInitialData
        case didLoadFromAPI(items : [TodoItemViewData])
        case didFailToLoadFromAPI
        case didRequestTodoListFromAPI
        case didRequestEditTodoItem(action : Action)
        case didEditTodoItem(action : Action, items : [TodoItemViewData])
        case didFailToEditTodoItem(action : Action)
        
        var description : String {
            switch self {
                case .didStart:
                    "didStart"
                case .didLoadInitialData:
                    "didLoadInitialData"
                case .didFailToLoadInitialData:
                    "didFailToLoadInitialData"
                case .didLoadFromAPI:
                    "didLoadFromAPI"
                case .didFailToLoadFromAPI:
                    "didFailToLoadFromAPI"
                case .didRequestTodoListFromAPI:
                    "didRequestTodoListFromAPI"
                case .didRequestEditTodoItem:
                    "didRequestEditTodoItem"
                case .didEditTodoItem:
                    "didEditTodoItem"
                case .didFailToEditTodoItem:
                    "didFailToEditTodoItem"
            }
        }
    }
}


extension TodoListMainViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        Self.log(event, state.status)
        switch state.status {
            case .start:
                switch event {
                case .didStart:
                        return .init(status: .loadingFromDB,todoItems: state.todoItems)
                default:
                    return state
                }
            case .loadingFromDB:
                switch event {
                    case .didLoadInitialData(let items):
                        return .init(status: .idle,todoItems: items)
                    case .didFailToLoadInitialData:
                        return .init(status: .error,todoItems: state.todoItems)
                    default:
                        return state
                }
            case .idle,.error:
                switch event {
                    case .didRequestEditTodoItem(let action):
                        return .init(status: .editing(action: action), todoItems: state.todoItems)
                    case .didRequestTodoListFromAPI:
                        return .init(status: .loadingFromAPI, todoItems: state.todoItems)
                    default:
                        return state
                }
            case .loadingFromAPI:
                switch event {
                    case .didRequestEditTodoItem(let action):
                        return .init(status: .editing(action: action), todoItems: state.todoItems)
                    case .didFailToLoadFromAPI:
                        return .init(status: .error, todoItems: state.todoItems)
                    case .didLoadFromAPI(let items):
                        return .init(status: .idle, todoItems: items)
                    default:
                        return state
                }
            case .editing:
                switch event {
                    case let .didEditTodoItem(action, items):
                        return .init(status: .idle, todoItems: items)
                    case .didFailToEditTodoItem:
                        return .init(status: .error, todoItems: state.todoItems)
                    default:
                        return state
                }
        }
    }
}

extension TodoListMainViewModel {
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in
            return input
        }
    }
}


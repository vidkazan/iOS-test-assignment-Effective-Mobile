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
        }
    }

    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event,Never>()
    
    init(_ initaialStatus : Status = .start,coreDataStore : CoreDataStore) {
        self.state = State(
            status: initaialStatus,
            todoItems: [],
            didLoadFromAPI: false
        )
        Publishers.system(
            initial: state,
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                Self.userInput(input: input.eraseToAnyPublisher()),
                Self.whenEditing(coreDataStore: coreDataStore),
                Self.whenStart(coreDataStore: coreDataStore),
                Self.whenLoadingFromDB(coreDataStore: coreDataStore),
                Self.whenValidatingAPICallIfNeeded()
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
        let didLoadFromAPI : Bool
        let status : Status
        let todoItems : [TodoItemViewData]

        init(status: Status, todoItems : [TodoItemViewData], didLoadFromAPI : Bool) {
            self.status = status
            self.todoItems = todoItems
            self.didLoadFromAPI = false
        }
        
        init(state : Self,status: Status? = nil, todoItems : [TodoItemViewData]? = nil, didLoadFromAPI : Bool? = nil) {
            self.status = status ?? state.status
            self.todoItems = todoItems ?? state.todoItems
            self.didLoadFromAPI = didLoadFromAPI ?? state.didLoadFromAPI
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
                case .validatingIfLoadedFromAPI:
                    "validatingIfLoadedFromAPI"
            }
        }
        
        case start
        case idle
        case loadingFromAPI
        case loadingFromDB
        case editing(action : Action)
        case error
        case validatingIfLoadedFromAPI
    }
    
    
    enum Action {
        case adding(data : TodoItemViewData)
        case deleting(id : UUID)
        case updating(id : UUID, data : TodoItemViewData)
    }

    enum Event : TodoListEvent {
        case didStart
        case didLoadInitialData(items : [TodoItemViewData], didLoadFromAPI : Bool)
        case didFailToLoadInitialData
        case didLoadFromAPI(items : [TodoItemViewData])
        case didFailToLoadFromAPI(error : ApiError)
        case didRequestTodoListFromAPI
        case didRequestEditTodoItem(action : Action)
        case didEditTodoItem(action : Action, items : [TodoItemViewData])
        case didFailToEditTodoItem(action : Action)
        case didCancelledLoadingFromAPI
        
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
                case .didCancelledLoadingFromAPI:
                    "didCancelledLoadingFromAPI"
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
                        return .init(state: state, status: .loadingFromDB)
                default:
                    return state
                }
            case .loadingFromDB:
                switch event {
                    case let .didLoadInitialData(items, didLoadFromAPI):
                        return .init(state: state, status: .validatingIfLoadedFromAPI,todoItems: items)
                    case .didFailToLoadInitialData:
                        return .init(state: state, status: .error)
                    default:
                        return state
                }
            case .validatingIfLoadedFromAPI:
                switch event {
                    case .didCancelledLoadingFromAPI:
                        return .init(state: state, status: .idle)
                    case .didRequestTodoListFromAPI:
                        return .init(state: state, status: .loadingFromAPI)
                    case .didFailToLoadFromAPI(let error):
                        return .init(state: state, status: .error)
                    default:
                        return state
                }
            case .idle,.error:
                switch event {
                    case .didRequestEditTodoItem(let action):
                        return .init(state: state, status: .editing(action: action))
                    default:
                        return state
                }
            case .loadingFromAPI:
                switch event {
                    case .didFailToLoadFromAPI:
                        return .init(state: state, status: .error)
                    case .didLoadFromAPI(let items):
                        return .init(state: state, status: .idle,todoItems: items)
                    default:
                        return state
                }
            case .editing:
                switch event {
                    case let .didEditTodoItem(action, items):
                        return .init(state: state, status: .idle,todoItems: items)
                    case .didFailToEditTodoItem:
                        return .init(state: state, status: .error)
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


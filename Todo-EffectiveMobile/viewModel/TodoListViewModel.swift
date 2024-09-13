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
        didSet { Self.log(state.status) }
    }

    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event,Never>()
    
    init(_ initaialStatus : Status = .idle) {
        self.state = State(
            status: initaialStatus
        )
        Publishers.system(
            initial: state,
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                Self.userInput(input: input.eraseToAnyPublisher())
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
    struct State {
        let status : Status
        let todoItems : [TodoItemViewData]

        init(status: Status) {
            self.status = status
            self.todoItems = []
        }
    }
    
    enum Status : String,TodoListStatus {
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
        case editing
        case error
    }
    
    enum Event : TodoListEvent {
        case didStart
        case didLoadInitialData
        case didFailToLoadInitialData
        case didLoadFromAPI
        case didFailToLoadFromAPI
        case didRequestTodoListFromAPI
        case didRequestEditTodoItem
        case didEditTodoItem
        case didFailToEditTodoItem
        
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
        switch state.status {
            case .start:
                switch event {
                    case .didStart:
                        return .init(status: .loadingFromDB)
                    default:
                        return state
                }
            case .loadingFromDB:
                switch event {
                    case .didLoadInitialData:
                        return .init(status: .idle)
                    case .didFailToLoadInitialData:
                        return .init(status: .error)
                    default:
                        return state
                }
            case .idle,.error:
                switch event {
                    case .didRequestEditTodoItem:
                        return .init(status: .editing)
                    case .didRequestTodoListFromAPI:
                        return .init(status: .loadingFromAPI)
                    default:
                        return state
                }
            case .loadingFromAPI:
                switch event {
                    case .didRequestEditTodoItem:
                        return .init(status: .editing)
                    case .didFailToLoadFromAPI:
                        return .init(status: .error)
                    case .didLoadFromAPI:
                        return .init(status: .idle)
                    default:
                        return state
                }
            case .editing:
                switch event {
                    case .didEditTodoItem:
                        return .init(status: .idle)
                    case .didFailToEditTodoItem:
                        return .init(status: .error)
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


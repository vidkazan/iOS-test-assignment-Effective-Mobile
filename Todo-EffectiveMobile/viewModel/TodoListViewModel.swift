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
    
    enum Status : TodoListStatus {
        case start
        case idle
        case loading
        case loaded
        case error
        
        var description : String {
            switch self {
            case .start:
                return "start"
            case .idle:
                return "idle"
            case .loading:
                return "loading"
            case .loaded:
                return "loaded"
            case .error:
                return "error"
            }
        }
    }
    
    enum Event : TodoListEvent {
        case didLoadInitialData
        case didTapLoading
        case didCancelLoading
        case didLoad
        case didFailToLoad
        
        var description : String {
            switch self {
            case .didLoadInitialData:
                return "didLoadInitialData"
            case .didTapLoading:
                return "didTapLoading"
            case .didCancelLoading:
                return "didCancelLoading"
            case .didFailToLoad:
                return "didFailToLoad"
            case .didLoad:
                return "didLoad"
            }
        }
    }
}


extension TodoListMainViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state.status {
        case .start:
            switch event {
            case .didLoadInitialData:
                return State(status: .idle)
            default:
                return state
            }
        case .idle:
            switch event {
            case .didTapLoading:
                return State(status: .loading)
            default:
                return state
            }
        case .loading:
            switch event {
            case .didTapLoading:
                return State(status: .loading)
            case .didCancelLoading:
                return State(status: .idle)
            case .didLoad:
                return State(status: .loaded)
            case .didFailToLoad:
                return State(status: .error)
            default:
                return state
            }
        case .loaded:
            switch event {
            case .didTapLoading:
                return State(status: .loading)
            default:
                return state
            }
        case .error:
            switch event {
            case .didTapLoading:
                return State(status: .loading)
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


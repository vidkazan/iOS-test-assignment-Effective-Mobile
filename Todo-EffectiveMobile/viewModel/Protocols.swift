//
//  viewModel.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation
import OSLog
import SwiftUI

protocol TodoListView : View {}

extension TodoListView {
    var log : Logger {
        Logger(category: .view)
    }
}


protocol TodoListEvent : Equatable {
    var description : String { get }
}

extension TodoListEvent {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description
    }
}
protocol TodoListStatus : Equatable {
    var description : String { get }
}

extension TodoListStatus {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description
    }
}

protocol TodoListViewModel : ObservableObject, Identifiable {
}

extension TodoListViewModel {
    static func log(
        _ status : any TodoListStatus
    ) {
        Logger.status("\(Self.self)", status: status)
    }
    static func warning(
        _ status : any TodoListStatus,
        _ msg: String
    ) {
        Logger.warning("\(Self.self)", status: status,msg: msg)
    }
    static func log(
        _ event : any TodoListEvent,
        _ status : any TodoListStatus
    ) {
        Logger.event("\(Self.self)", event: event,status: status)
    }
    static func logReducerWarning(
        _ event : any TodoListEvent,
        _ status : any TodoListStatus
    ) {
        Logger.reducer("\(Self.self)", event: event,status: status)
    }
}

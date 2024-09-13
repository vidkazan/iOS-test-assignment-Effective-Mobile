//
//  Logging.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation
import OSLog
import SwiftUI

struct TodoLogMessage : Codable {
    let category : LoggerCategories
    let subcategory : String
    let msg : String
}

enum LoggerCategories : String,Hashable,CaseIterable, Codable {
    case viewModel
    case viewData
    case status
    case event
    case reducer
    case coreData
    case networking
    case loadingsInitialData
    case view
}

extension Logger {
    static let coreData = Logger(category: .coreData)
    static let networking = Logger(category: .networking)
    static let loadingsInitialData = Logger(category: .loadingsInitialData)
    static let viewData = Logger(category: .viewData)
    
    static func create(category : String) -> Logger {
        Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: category
        )
    }
}

extension Logger {
    init(category: LoggerCategories) {
        self.init(
            subsystem: Bundle.main.bundleIdentifier!,
            category: category.rawValue
        )
    }
}

extension OSLogEntryLog {
    var color: Color {
        switch level {
        case .info:
            return .blue
        case .debug:
            return .gray
        case .notice:
            return .yellow
        case .error, .fault:
            return .red
        default:
            return .gray
        }
    }
}



extension Logger {
    static func status(
        _ viewModelName : String,
        status : any TodoListStatus
    ) {
        Logger(category: .status).trace("\(viewModelName): \(status.description)")
    }
    static func warning(
        _ viewModelName : String,
        status : any TodoListStatus,
        msg : String
    ) {
        Logger(category: .viewModel).warning("\(viewModelName): \(status.description): \(msg)")
    }
    static func event(
        _ viewModelName : String,
        event : any TodoListEvent,
        status : any TodoListStatus
    ) {
        Logger(category: .event).trace("🔥\(viewModelName): \(event.description) (for state:\(status.description))")
    }
    static func reducer(
        _ viewModelName : String,
        event : any TodoListEvent,
        status : any TodoListStatus
    ) {
        Logger(category: .reducer).warning("\(viewModelName): \(event.description) \(status.description)")
    }
}

//
//  coreDataStore.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//

import Foundation
import CoreData
import CoreLocation
import OSLog

final class CoreDataStore : ObservableObject {
    static let preview : CoreDataStore = CoreDataStore(container: PersistenceController.preview.container)
    
    var asyncContext: NSManagedObjectContext
    var user : CDUser? = nil

    init(container : NSPersistentContainer = PersistenceController.shared.container) {
        self.asyncContext = container.newBackgroundContext()
        self.asyncContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}

extension CoreDataStore {
    func saveAsyncContext(){
        guard asyncContext.hasChanges else { return }
        do {
            try asyncContext.save()
            Logger.coreData.debug("\(#function)")
        } catch {
            let nserror = error as NSError
            Logger.coreData.error("\(#function): \(nserror.description) \(nserror.userInfo)")
        }
    }
}


enum CoreDataError : Error {
    static func == (lhs: CoreDataError, rhs: CoreDataError) -> Bool {
        return lhs.description == rhs.description
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .failedToUpdate:
            break
        case .failedToAdd:
            break
        case .failedToDelete:
            break
        }
    }
    case failedToUpdate(type : NSManagedObject.Type)
    case failedToAdd(type : NSManagedObject.Type)
    case failedToDelete(type : NSManagedObject.Type)
    
    
    var description : String  {
        switch self {
        case .failedToUpdate(type: let type):
            return "failedToUpdate type: \(type)"
        case .failedToAdd(type: let type):
            return "failedToAddToDatabase type: \(type)"
        case .failedToDelete(type: let type):
            return "failedToAddToDelete type: \(type)"
        }
    }
}


// MARK: Fetch
extension CoreDataStore {
    func fetchUser() -> CDUser? {
        let user = self.fetchOrCreateUser()?.first
        self.user = user
        return user
    }
    
    
    func fetchTodoItems() -> [Stop]? {
        var todoItems = [Stop]()
        if let fetchResult = fetch(CDTodoItem.self) {
            asyncContext.performAndWait {
                fetchResult.forEach {
                    todoItems.append($0)
                }
            }
            return stops
        }
        return nil
    }
    
    
    func fetch<T : NSManagedObject>(_ t : T.Type) -> [T]? {
        var object : [T]? = nil
         asyncContext.performAndWait {
            guard let fetchRequest = T.fetchRequest() as? NSFetchRequest<T> else {
                Logger.coreData.error("fetch: \(T.self): generate fetch request error")
                return
            }
            do {
                let res = try self.asyncContext.fetch(fetchRequest)
                if !res.isEmpty {
                    Logger.coreData.trace("fetch: \(T.self) done")
                    object = res
                    return
                }
                object = []
                Logger.coreData.info(
                    "fetch: \(T.self): result is empty"
                )
            } catch {
                Logger.coreData.error("fetch: \(T.self) failed")
            }
        }
        return object
    }
}


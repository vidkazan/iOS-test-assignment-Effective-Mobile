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
    private func fetchOrCreateUser() -> [CDUser]? {
        if let res = fetch(CDUser.self), !res.isEmpty {
            return res
        }
         asyncContext.performAndWait {
            self.user = CDUser.createWith(using: self.asyncContext)
        }
        return fetch(CDUser.self)
    }
    
    func fetchUser() -> CDUser? {
        let user = self.fetchOrCreateUser()?.first
        self.user = user
        return user
    }
    
    func didLoadFromAPI() -> Bool? {
        var result : Bool? = nil
        if let user = self.fetchUser() {
            self.asyncContext.performAndWait {
                result = user.didLoadTodoItemsFromAPI
            }
        }
        return result
        
    }
    
    func fetchTodoItems() -> [TodoItemViewData]? {
        if let res = fetch(CDTodoItem.self)  {
            var items = [TodoItemViewData]()
            asyncContext.performAndWait {
                res.forEach {
                    if
                        let content = $0.content,
                        let contentDecoded = try? JSONDecoder().decode(CDTodoItem.TodoItemContent.self, from: content) {
                        items.append(TodoItemViewData(
                            id: $0.id,
                            title: contentDecoded.title,
                            description: contentDecoded.description,
                            creationDate: $0.creationDate,
                            todoDateStart: contentDecoded.todoDateStart,
                            todoDateEnd: contentDecoded.todoDateEnd,
                            isCompleted: $0.isCompleted
                        ))
                    }
                }
            }
            return items
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

// MARK: remove
extension CoreDataStore {
    func deleteTodoItemIfFound(id : UUID) -> Bool {
        var result = false
        if let objects = self.fetch(CDTodoItem.self) {
             asyncContext.performAndWait {
                if let res = objects.first(where: { obj in
                    return obj.id == id
                }) {
                    self.asyncContext.delete(res)
                    self.saveAsyncContext()
                    result = true
                } else {
                    Logger.coreData.error("\(#function): not found")
                }
            }
        } else {
            Logger.coreData.error("\(#function): fetch failed")
        }
        return result
    }
}


// MARK: add
extension CoreDataStore {
    func addTodoItem(todoItem : TodoItemViewData) -> Bool {
        var res = false
        guard let user = self.user else {
            Logger.coreData.error("\(#function): user is nil")
            return false
        }
        asyncContext.performAndWait {
            let _ = CDTodoItem(
                viewData: todoItem,
                user: user,
                using: self.asyncContext
            )
            self.saveAsyncContext()
            res = true
        }
        return res
    }
}

// MARK: update
extension CoreDataStore {
    func updateTodoItem(id: UUID,viewData : TodoItemViewData) -> Bool {
        if deleteTodoItemIfFound(id: id) {
            return addTodoItem(todoItem: viewData)
        }
        Logger.coreData.error("\(#function): update failed")
        return false
    }
    
    func updateUser(didLoadFromAPI : Bool) {
        guard let user = self.user else {
            Logger.coreData.error("\(#function): user is nil")
            return
        }
        
        asyncContext.performAndWait {
            user.didLoadTodoItemsFromAPI = didLoadFromAPI
            self.saveAsyncContext()
        }
    }
}

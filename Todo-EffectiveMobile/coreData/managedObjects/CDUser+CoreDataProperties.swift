//
//  CDUser+CoreDataProperties.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//
//

import Foundation
import CoreData
import OSLog

extension CDUser {
    static func createWith(using managedObjectContext: NSManagedObjectContext) -> CDUser? {
        managedObjectContext.performAndWait {
            let user = CDUser(entity: CDUser.entity(), insertInto: managedObjectContext)
            do {
                try managedObjectContext.save()
                return user
            } catch {
                let nserror = error as NSError
                Logger.coreData.error("cdUser: \(#function): \(nserror.description) \(nserror.userInfo)")
                return nil
            }
        }
    }
}

extension CDUser {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    @NSManaged public var didLoadTodoItemsFromAPI: Bool
    @NSManaged public var todoItems: Set<CDTodoItem>
}

// MARK: Generated accessors for todoItems
extension CDUser {

    @objc(addTodoItemsObject:)
    @NSManaged public func addToTodoItems(_ value: CDTodoItem)

    @objc(removeTodoItemsObject:)
    @NSManaged public func removeFromTodoItems(_ value: CDTodoItem)

    @objc(addTodoItems:)
    @NSManaged public func addToTodoItems(_ values: NSSet)

    @objc(removeTodoItems:)
    @NSManaged public func removeFromTodoItems(_ values: NSSet)

}

extension CDUser : Identifiable {

}

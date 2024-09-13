//
//  CDUser+CoreDataProperties.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
//
//

import Foundation
import CoreData


extension CDUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    @NSManaged public var isFirstLaunch: Bool
    @NSManaged public var todoItems: Set<CDTodoItem>?

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

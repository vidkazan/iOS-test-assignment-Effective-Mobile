//
//  CDTodoItem+CoreDataProperties.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 12.09.24.
//
//

import Foundation
import CoreData


extension CDTodoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTodoItem> {
        return NSFetchRequest<CDTodoItem>(entityName: "CDTodoItem")
    }

    @NSManaged public var content: Data?
    @NSManaged public var creationDate: Date?
    @NSManaged public var id: Int64
    @NSManaged public var user: CDUser?

}

// MARK: Generated accessors for user
extension CDTodoItem {

    @objc(addUserObject:)
    @NSManaged public func addToUser(_ value: CDUser)

    @objc(removeUserObject:)
    @NSManaged public func removeFromUser(_ value: CDUser)

    @objc(addUser:)
    @NSManaged public func addToUser(_ values: NSSet)

    @objc(removeUser:)
    @NSManaged public func removeFromUser(_ values: NSSet)

}

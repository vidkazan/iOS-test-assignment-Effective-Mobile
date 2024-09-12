//
//  CDUser+CoreDataProperties.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 12.09.24.
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

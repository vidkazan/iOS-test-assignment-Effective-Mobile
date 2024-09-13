//
//  CDTodoItem+CoreDataProperties.swift
//  Todo-EffectiveMobile
//
//  Created by Dmitrii Grigorev on 13.09.24.
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

extension CDTodoItem : Identifiable {

}

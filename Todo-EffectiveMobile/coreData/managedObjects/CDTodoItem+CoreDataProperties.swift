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
    @NSManaged public var creationDate: Date
    @NSManaged public var id: Int64
    @NSManaged public var user: CDUser?
    @NSManaged public var isCompleted: Bool

}

extension CDTodoItem : Identifiable {
    
}

extension CDTodoItem {
    struct TodoItemContent : Codable {
        let title : String
        let description : String
        let todoDateStart : Date?
        let todoDateEnd : Date?
    }
}

extension CDTodoItem {
    convenience init(
        viewData : TodoItemViewData,
        user : CDUser,
        using managedObjectContext: NSManagedObjectContext) {
            self.init(entity: CDTodoItem.entity(), insertInto: managedObjectContext)
            self.id = id
            self.creationDate = viewData.creationDate
            self.isCompleted = viewData.isCompleted
            
            let content = Self.TodoItemContent(
                title: viewData.title,
                description: viewData.title,
                todoDateStart: viewData.todoDateStart,
                todoDateEnd: viewData.todoDateEnd
            )
            if let content = try? JSONEncoder().encode(content) {
                self.content = content
            }
            user.addToTodoItems(self)
        }
}

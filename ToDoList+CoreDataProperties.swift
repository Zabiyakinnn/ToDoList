//
//  ToDoList+CoreDataProperties.swift
//  ToDo List
//
//  Created by Дмитрий Забиякин on 14.09.2024.
//
//

import Foundation
import CoreData

@objc(ToDoList)
public class ToDoList: NSManagedObject {

}

extension ToDoList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoList> {
        return NSFetchRequest<ToDoList>(entityName: "ToDoList")
    }

    @NSManaged public var todo: String?
    @NSManaged public var comment: String?
    @NSManaged public var date: Date?
    @NSManaged public var completed: Bool

}

extension ToDoList : Identifiable {

}

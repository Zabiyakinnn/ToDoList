//
//  Todos.swift
//  ToDo List
//
//  Created by Дмитрий Забиякин on 12.09.2024.
//

import Foundation

struct Todo: Codable {
    var todos: [Todos]?
}

struct Todos: Codable {
    var id: Int?
    var comment: String?
    var todo: String?
    var completed: Bool?
    var date: Date?
    var userId: Int?
}

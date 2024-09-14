//
//  NetworkService.swift
//  ToDo List
//
//  Created by Дмитрий Забиякин on 12.09.2024.
//

import Foundation

public final class NetworkService {
    
    static let shared = NetworkService()
    
    // Запрос на получение списка задач
    func requestToDoList(completion: @escaping ([Todos]) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }
        
        let request = URLRequest(url: url)
        
        // Парсим данные
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data returned")
                return
            }
            do {
                // Декодируем ответ в структуру Todo
                let toDoData = try JSONDecoder().decode(Todo.self, from: data)
                // Если получили данные, вызываем completion с массивом Todos
                if let todos = toDoData.todos {
                    print(todos)  // Для отладки
                    completion(todos)
                } else {
                    print("No todos in response")
                }
                
            } catch let decodingError {
                print("Failed to decode JSON: \(decodingError.localizedDescription)")
            }
            
        }.resume()
    }
}

//
//  APIService.swift
//  Habits
//
//  Created by Eric Davis on 29/11/2021.
//

import Foundation

struct HabitRequest: APIRequest {
    
    typealias Response = [String: Habit]
    
    var habitName: String?
    
    var path: String { "/habits" }
    
    var filename: String { "habits" }
}

struct UserRequest: APIRequest {
    typealias Response = [String: User]
    
    var path: String { "/users" }
    
    var filename: String { "users" }
    
}

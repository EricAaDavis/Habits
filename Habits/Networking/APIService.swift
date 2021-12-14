//
//  APIService.swift
//  Habits
//
//  Created by Eric Davis on 29/11/2021.
//

import UIKit

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

struct HabitStatisticsRequest: APIRequest {
    typealias Response = [HabitStatistics]
    
    var habitNames: [String]?
    
    var path: String { "/habitStats" }
    
    var queryItems: [URLQueryItem]? {
        if let habitNames = habitNames {
            return [URLQueryItem(name: "names", value: habitNames.joined(separator: ","))]
        } else {
            return nil
        }
    }
    
    var filename: String
}

struct UserStatisticsRequest: APIRequest {
    
    //Why do we typealias this?
    typealias Response = [UserStatistics]
    
    var userIDs: [String]?
    
    var path: String { "/userStats" }
    
    var queryItems: [URLQueryItem]? {
        if let userIDs = userIDs {
            return [URLQueryItem(name: "ids", value: userIDs.joined(separator: ","))]
        } else {
            return nil
        }
    }
    
    var filename: String
    
}

struct HabitLeadStatisticsRequest: APIRequest {
    typealias Response = UserStatistics
    
    var userID: String
    
    var path: String { "/userLeadingStats/\(userID)" }
    
    var filename: String 
    
}

struct ImageRequest: APIRequest {
    typealias Response = UIImage
    
    var imageID: String
    
    var path: String { "/images/\(imageID)" }
    
    var filename: String
}

struct LogHabitRequest: APIRequest {
    typealias Response = Void
    
    var trackedEvent: LoggedHabit
    
    var path: String { "/loggedHabit" }
    
    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try! encoder.encode(trackedEvent)
    }
    
    var filename: String { "loggedHabits" }
    
}


struct CombinedStatisticsRequest: APIRequest {
    typealias Response = CombinedStatistics
    
    var path: String { "/combinedStats" }
    
    var filename: String { "combinedStats" }
}

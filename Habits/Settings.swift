//
//  Settings.swift
//  Habits
//
//  Created by Eric Davis on 06/12/2021.
//

import Foundation

enum Setting {
    static let favoriteHabits = "favoriteHabits"
    static let followedUserIDs = "followedUserIDs"
}

struct Settings {
    static var shared = Settings()
    
    private let defaults = UserDefaults.standard
    
    private func archiveJSON<T: Encodable>(value: T, key: String) {
        let data = try! JSONEncoder().encode(value)
        let string = String(data: data, encoding: .utf8)
        defaults.set(string, forKey: key)
    }
    
    private func unarchiveJSON<T: Decodable>(key: String) -> T? {
        guard let string = defaults.string(forKey: key),
              let data = string.data(using: .utf8) else {
                  return nil
              }
        return try! JSONDecoder().decode(T.self, from: data)
                
    }
    
    var favoriteHabits: [Habit] {
        get {
            return unarchiveJSON(key: Setting.favoriteHabits) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.favoriteHabits)
        }
    }
    
    mutating func toggleFavorite(_ habit: Habit) {
        var favorites = favoriteHabits
        
        if favorites.contains(habit) {
            //If favorite already contains habit, remove it.
            favorites = favorites.filter{ $0 != habit }
        } else {
            //Otherwise add it to the favorites array
            favorites.append(habit)
        }
        
        favoriteHabits = favorites
    }
    
    var followedUserIDs: [String] {
        get {
            return unarchiveJSON(key: Setting.followedUserIDs) ?? []
        } set {
            archiveJSON(value: newValue, key: Setting.followedUserIDs)
        }
    }
    
    let currentUser = User(id: "activeUser", name: "Eric Davis", color: nil, bio: nil)
    
    mutating func toggleFollowed(user: User) {
        var updated = followedUserIDs
        
        if updated.contains(user.id) {
            updated = updated.filter { $0 != user.id }
        } else {
            updated.append(user.id)
        }
        
        followedUserIDs = updated
    }
    
}








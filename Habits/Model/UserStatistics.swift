//
//  UserStatistics.swift
//  Habits
//
//  Created by Eric Davis on 08/12/2021.
//

import Foundation

struct UserStatistics {
    let user: User
    let habitCounts: [HabitCount]
}

extension UserStatistics: Codable { }



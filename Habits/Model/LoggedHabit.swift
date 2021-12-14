//
//  LoggedHabit.swift
//  Habits
//
//  Created by Eric Davis on 13/12/2021.
//

import Foundation

struct LoggedHabit {
    let userID: String
    let habitName: String
    let timestamp: Date
}

extension LoggedHabit: Codable {  }

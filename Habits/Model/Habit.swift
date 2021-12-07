//
//  Habit.swift
//  Habits
//
//  Created by Eric Davis on 29/11/2021.
//

import Foundation

struct Habit {
    let name: String
    let category: Category
    let info: String
}

extension Habit: Codable { }

extension Habit: Comparable {
    static func < (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.name < rhs.name
    }
}

//Meaning that we only use tha name for comparison
extension Habit: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

